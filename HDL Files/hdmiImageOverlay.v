//Overlay an image stored in DDR to be transmitted via HDMI

//Copyright (C) 2018 by Alexander Knapik and Keane-Gene Yew
//under the GNU General Public License v3.0 or any later version.
//03.05.2018

/*
    This file is part of FPGA-HDMI-Image-Overlay by Alexander Knapik and Keane-Gene Yew.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    this program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

//Real world inputs and outputs
module HDMIOverlay (
	input clock_50,	//50Mhz FPGA clock
	input key0,		//Push button. This is automatically latched by the DE-10 Nano development board.
	input key1,		//Push button. This is automatically latched by the DE-10 Nano development board.
	input [3:0] sw,	//4 Slide switches
	
	output DE,		//Data enable
	output VSYNC,	//Vertical sync
	output HSYNC,	//Horizontal sync
	output [23:0] data //Data output bus
);
	
	//Define resolution. Default 1920x1080.
	parameter hPixels = 1920;	//Horizontal pixel length
	parameter vPixels = 1080;	//Vertical pixel length
	
	//Refresh rate
	parameter refreshRate = 30;	//Refresh rate. Default 30 frames a second.
	
	//Define the bus widths used for counting the horizontal and vertical pixels.
	//12 bits is 4096 x 4096 maximum.
	//11 bits is 2048 x 2048 maximum.
	parameter hCountWidth = 12;
	parameter vCountWidth = 12;
	
	//Registers used for storing the pixel count
	reg [ ( hCountWidth - 1 ) : 0 ] hCount = 0;	//Horizontal pixel counter
	reg [ ( vCountWidth - 1 ) : 0 ] vCount = 0;	//Vertical pixel counter	
	
	//Registers used for resetting the horizontal and vertical counters.
	reg hReset_n = 1'b0;
	reg vReset_n = 1'b0;

	//Register Definitions
	reg [23:0] dataReg; //Create 24 bit data register

	//Register Assignments
	assign data = dataReg; //Assign data register to data output
	
	//Horizontal pixel counter, hCountWidth bits long.
	counter #( hCountWidth )
	hCounter
	(
		.clock				( clock_50 ),	//Clock input clock
		.D					( 1'b0 ),		//Set the data input to 0 always. No preloading of the counter.
		.parallelEnable_n 	( 1'b1 ),		//Disable the parallel loading ability!!!
		.countEnable		( 1'b1 ),		//Always have the counting ability enabled.
		.masterReset_n		( hReset_n ),	//Reset the counter, active low.
		.Q					( hCount )		//The horizontal counter value.
	);
	
	//Vertical pixel counter, vCountWidth bits long.
	counter #( vCountWidth )
	vCounter
	(
		.clock				( clock_50 ),	//Clock input clock
		.D					( 1'b0 ),		//Set the data input to 0 always. No preloading of the counter.
		.parallelEnable_n 	( 1'b1 ),		//Disable the parallel loading ability!!!
		.countEnable		( 1'b1 ),		//Always have the counting ability enabled.
		.masterReset_n		( vReset_n ),	//Reset the counter, active low.
		.Q					( vCount )		//The vertical counter value.
	);
	
	//Horizontal sync module
	hsync #( hCountWidth, hPixels )
	hSync
	(
		//.resHorizontal		( hPixels ),	//1920 pixels wide
		.counterVal			( hCount ),		//Send horizontal counter value to the hsync counterVal
		.clock 				( clock_50 ),	//Clock input clock
		.hSyncPulse 		( HSYNC ),		//hSync pulse goes to HSYNC output, which is tied to a pin
		.hCountReset_n 		( hReset_n )	//Maps the hSync counter reset to hReset_n register
	);

	//Vertical sync module
	vsync #( vCountWidth, vPixels )
	vSync
	(
		//.resVertical 		( vPixels ),	//1080 pixels wide
		.counterVal 		( vCount ),		//Send vertical counter value to the vsync counterVal
		.clock 				( clock_50 ),	//Clock input clock
		.vSyncPulse 		( VSYNC ),		//vSync pulse goes to VSYNC output, which is tied to a pin
		.vCountReset_n 		( vReset_n )	//Maps the vSync counter reset to vReset_n register
	);

	DE #( hCountWidth, hPixels, vPixels )
	de_module
	(
		.clock 				( clock_50 ), 	//Input clock
		.resHorizontal		( hPixels ),	//Horizontal pixel count (1920)
		.hCount 			( hCount ), 	//Horizontal pixel counter
		.resVertical 		( vPixels ),	//Vertical pixel count (1080)
		.vCount 			( vCount ), 	//Vertical pixel counter
		.deOut 				( DE )			//DE signal output
	);

	dataWrite dataWrite_module
	(
		.clock 				( clock_50 ), 	//Input clock
		.dataOutput 		( dataReg ) 	//Data output
	);
		
	
endmodule