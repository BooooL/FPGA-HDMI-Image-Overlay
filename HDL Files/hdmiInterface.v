//Verilog HDMI Interface
//Copyright (C) 2018 Alexander Knapik & Keane-Gene Yew
//under the GNU General Public License v3.0 or any later version
//29.05.2018

/*
    This file is part of FPGA-HDMI-Image-Overlay. 
	https://github.com/AlexanderKnapik/FPGA-HDMI-Image-Overlay

    FPGA-HDMI-Image-Overlay is free software: you can redistribute it and/or 
	modify it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FPGA-HDMI-Image-Overlay is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FPGA-HDMI-Image-Overlay.
	
	If not, see <http://www.gnu.org/licenses/>.
*/
`timescale 1 ps / 1 ps
module hdmiInterface 
//Parameters passed via the top level entity.
//The ones here defined are for 1920x1080p 60fps
//With an input pixel clock of 148.50MHz
#(
	//HSync parameters
	parameter hPlacement	= 88,	//How many pixel clocks HSync is set high after DE falls.
	parameter hDuration		= 44,	//How many pixel clocks HSync is held high for.
	parameter hDelay		= 192,	//How many pixel clocks DE goes high, after HSync goes high in the active video section.
	parameter hPolarity		= 1,	//VSync is active High for 1.
	//VSync parameters
	parameter vPlacement	= 4,	//How many HSync periods VSync is set high after DE falls.
	parameter vDuration		= 5,	//How many HSync periods VSync is held high for.
	parameter vDelay		= 41,	//How many HSync periods it takes for DE to go high once VSync has gone high. (DE still effected by hDelay).
	parameter vPolarity		= 1,	//VSync is active High for 1.
	//Active screen resolution.
	parameter width			= 1920,	//pixel width of the active video region.
	parameter height		= 1080	//pixel height of the active video region.
)
//Defining the inputs and outputs of the system.
(
	input 	pixelClock,				//Pixel clock used for the system. 148.5MHz.
	output	DE,						//Data Enable 	
	output 	HSYNC,					//Horizontal Sync
	output	VSYNC					//Vertical Sync
);
	localparam lineWidth	= width + hPlacement + hDelay;	//2200 Horizontal clocks per line.
	localparam lineHeight	= height + vPlacement + vDelay;	//1125 Vertical lines.

	//How many pixel clocks it takes for DE to go high after HSync goes low.
	localparam deDelay		= ( hDelay - ( hDuration + hPlacement ) );	//148 pixel clocks
	
	reg de		= 1'b0;
	reg hsync	= 1'b0;
	reg vsync	= 1'b0;
	
	assign DE 		= de;
	assign HSYNC	= hsync;
	assign VSYNC	= vsync;
	
	reg [11:0]	pCounter		= 0;	//Counting pixel clocks.
	reg [11:0]	hCounter 		= 1;	//Counting HSync pulses							//Count pixel clocks for pulsing HSync/DE
	//reg [11:0]	vCounter		= 0;	//Counting VSync pulses							//Count HSync pulses for pulsing VSync.
	
	localparam resetState			= 0;
	localparam startFrame			= 1;
	localparam vSyncState			= 2;
	localparam endBlankHSync		= 3;
	localparam activeVideo			= 4;
	localparam startBlankFrame		= 5;
	
	reg[4:0]	currentState	= 0;
	reg[4:0]	nextState		= 0;
	
	//Logic to handle the currentState -> nextState transition.
	//Sensitivity list based on the input clock.
	always @( posedge( pixelClock ) )
		begin: currentStateTransition
			currentState <= nextState;	
		end
		
	//Logic handling which state will transition into which.
	always @( * )
		begin: nextStateLogic
			case( currentState )
				default:
					begin
						nextState = startFrame;
					end
				
				startFrame:
					begin
						//If there has been an hDuration amount of pixel clocks,
						//Go onto the vSyncInitial state.
						//Else, stay in the same state. (Keep hSync high)
						if( pCounter == hDuration )
							begin
								nextState = vSyncState;
							end
						else if ( ( pCounter == hDuration ) && ( hCounter == vDuration ) )
							begin
								nextState = endBlankHSync;
							end
						else
							begin
								nextState = currentState;
							end
					end
					
				vSyncState:
					begin
						//If the hCounter is equal to the vDuration, then on the next posedge of hsync
						//Go to the endBlankLines state.
						//Else stay in the same state. 
						if ( ( hCounter == vDuration ) && ( pCounter == lineWidth ) )
							begin
								nextState = endBlankHSync;
							end
						else if ( ( pCounter == lineWidth ) && ( hCounter != vDuration ) )
							begin
								nextState = startFrame;
							end
						else
							begin
								nextState = currentState;
							end
					end
					
				endBlankHSync:
					begin
						//If there have been VSync delay amoung of hPulses, at pixel clock 2200 ( lineWidth ), go to activeVideo state.
						if ( ( pCounter == lineWidth ) && ( hCounter == vDelay ) )
							begin
								nextState = activeVideo;
							end
						else
							begin
								nextState = currentState;
							end
					end
					
				activeVideo:
					begin
						//On HSync pulse 1121 ( lineHeight - vPlacement ), go to the start of the blanking period.
						if( hCounter > ( lineHeight - vPlacement ) )
							begin
								nextState = startBlankFrame;
							end
						else
							begin
								nextState = currentState;
							end
					end
					
				startBlankFrame:
					begin
						//At the end of HSync pulse lineHeight, go to the startFrame state.
						if ( ( pCounter == lineWidth ) && ( hCounter == lineHeight ) )
							begin
								nextState = startFrame;
							end
						else
							begin
								nextState = currentState;
							end
					end
				
			endcase
		end //Always
			
	
	always @ ( posedge ( pixelClock ) )
		begin: currentStateLogic
			case( currentState )
				default:
					begin
						hsync 		<= 1'b0;
						vsync		<= 1'b0;
						de 			<= 1'b0;
						pCounter	<= 1'b0;
						hCounter	<= 1'b1;
					end
					
				startFrame:
					begin
						vsync		<= 1'b1;
						de 			<= 1'b0;
						//Increment the pixelClock counter every pixelClock Edge.
						//pCounter	= pCounter + 1'b1;
						
						//If the pixel clock counter is greater or equal to hDuration long, set HSync to low,
						//Otherwise keep it high.
						if ( pCounter >= hDuration )
							begin
								hsync 		<= 1'b0;
							end
						else
							begin
								hsync		<= 1'b1;
							end
							
						//If the pCounter is equal to the line width, then reset it, and increment hCounter.
						//otherwise increment it.
						if ( pCounter == lineWidth )
							begin
								pCounter <= 0;
								hCounter <= hCounter + 1'b1;
							end
						//For second frame and onwards.
						else if ( hCounter == ( lineHeight + 1 ) )
							begin
								pCounter <= 0;
								hCounter <= 1;
							end
						else
							begin
								pCounter <= pCounter + 1'b1;
								hCounter <= hCounter;
							end
						
						//If the hsync counter is greater than the vsync duration,
						//Set vsync low.
						//Else keep it high.
						if ( hCounter > vDuration )
							begin
								vsync		<= 1'b0;
							end
						else
							begin
								vsync		<= 1'b1;
							end
					end//StartFrame
				
			vSyncState:
				begin
					//hsync		<= 1'b0;
					vsync		<= 1'b1;
					de			<= 1'b0;
					
					
					//If the pixel clock counter is equal to the total drawn width (2200),
					//Increment the hsync counter,
					if( pCounter == lineWidth )
						begin
							hsync 		<= 1'b1;
							hCounter 	<= hCounter + 1'b1;
							pCounter	<= 0;
						end						
					else
						begin
							hsync 		<= 1'b0;
							hCounter 	<= hCounter;
							pCounter	<= pCounter + 1'b1;
						end
				end
				
			endBlankHSync:
				begin
					vsync		<= 1'b0;
					de			<= 1'b0;
					
						//If the pixel clock counter is greater or equal to hDuration long, set HSync to low,
						//Otherwise keep it high.
						if ( pCounter >= hDuration )
							begin
								hsync 		<= 1'b0;
							end
						else
							begin
								hsync		<= 1'b1;
							end
							
						//If the pCounter is equal to the line width, then reset it, and increment hCounter.
						//otherwise increment it.
						if ( pCounter == lineWidth )
							begin
								pCounter <= 0;
								hCounter <= hCounter + 1'b1;
							end
						else
							begin
								pCounter <= pCounter + 1'b1;
								hCounter <= hCounter;
							end
				end
				
			activeVideo:
				begin
					vsync		<= 1'b0;
					
						//If the pixel clock counter is greater or equal to hDuration long, set HSync to low,
						//Otherwise keep it high.
						if ( pCounter >= hDuration )
							begin
								hsync 		<= 1'b0;
							end
						else
							begin
								hsync 		<= 1'b1;
							end
							
						//If the pCounter is equal to the line width, then reset it, and increment hCounter.
						//otherwise increment it.
						if ( pCounter == lineWidth )
							begin
								pCounter 	<= 0;
								hCounter 	<= hCounter + 1'b1;
							end
						else
							begin
								pCounter <= pCounter + 1'b1;
								hCounter <= hCounter;
							end
							
						//if the pixel clock counter is greater than hDelay,
						//Then turn on the DE, as its now active video.
						//However DE must be set low hPlacement pixel clocks before the end of lineWidth.
						if ( ( pCounter < hDelay ) || ( pCounter >= ( ( lineWidth - hPlacement ) - 1 ) ) )
							begin
								de			<= 1'b0;
							end
						else
							begin
								de			<= 1'b1;
							end			
				end
					
			startBlankFrame:
				begin
					//Turn DE off for the blanking lines.
					de		<= 1'b0;
					//Turn off vsync as it is the start of the blanking lines at the bottom edge of the screen. 
					vsync	<= 1'b0;
					
					//Run hSync for up to 1125 vertical lines, to be reset at the new frame in the startFrame state.
					//If the pixel clock counter is greater or equal to hDuration long, set HSync to low,
					//Otherwise keep it high.
					if ( pCounter >= hDuration )
						begin
							hsync 		<= 1'b0;
						end
					else
						begin
							hsync 		<= 1'b1;
						end
						
					//If the pCounter is equal to the line width, then reset it, and increment hCounter.
					//otherwise increment it.
					if ( pCounter == lineWidth )
						begin
							pCounter 	<= 0;
							hCounter 	<= hCounter + 1'b1;
						end
					else
						begin
							pCounter <= pCounter + 1'b1;
							hCounter <= hCounter;
						end	
				end
			
			endcase
		end //Always		

endmodule