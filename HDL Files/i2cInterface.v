//Verilog i2c interface
//Copyright (C) 2018 Alexander Knapik & Keane-Gene Yew
//under the GNU General Public License v3.0 or any later version
//05.04.2018

/*
    This file is part of FPGA-HDMI-Image-Overlay. 
	https://github.com/AlexanderKnapik/FPGA-HDMI-Image-Overlay

    FPGA-HDMI-Image-Overlay is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FPGA-HDMI-Image-Overlay is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FPGA-HDMI-Image-Overlay.  If not, see <http://www.gnu.org/licenses/>.
*/

module i2cInterface 
//Parameters used for passing variables
#( 
	/*
	input parameter [7:0] data			= 8'hFF,	//Data used for communcations
	input parameter [7:0] slaveAddress	= 8'hFF,	//Address used for the I2C slave
	input parameter [7:0] dataAddress	= 8'hFF 	//Address used for writing to a particular register
	*/
	
	//24 Bit data used for storing the following:
	//[23:16] 	Slave Address
	//[15:8]	Register Address
	//[7:0]		Data to be written to register. 
	parameter [23:0] dataIn		= 24'hFFFFFF,	
	
	//Parameters used for calculating the values needed for creating the
	//state machine clock. Values are in Hz.
	parameter inputSpeed		= 5 	* ( 10 ** 6 ), 	//Input reference clock. 50MHz.
	parameter sclSpeed			= 400 	* ( 10 ** 3 )	//SCL communication speed. 400kHz.
)

(
	input clock50M,		//Input reference clock of 50MHz.
	input i2cStart,		//Input signal to start communications
	input reset_n,		//Active low reset
	inout sda,			//I2C SDA
	output reg scl		//I2C input communications reference clock. 400kHz
);

//==============================================================================
//				CLOCK GENERATOR USED FOR THE STATE MACHINE CLOCK
	
	//Set the state machine to run at double the speed of SCL.
	parameter stateSpeed = ( sclSpeed * 2 );
	
	//Define the bit width based on the clock speeds. .
	//log2( inputSpeed / stateSpeed ),				Round up.
	//ln( inputSpeed / stateSpeed ) / ln( 2 ),		Round up.
	parameter clockWidth = 3;
	
	//Wire used for connecting the state clock to the state machine.
	wire stateClock;
	
	clockGen 
	//Pass the parameters to the instantiated module.
	#( inputSpeed, stateSpeed, clockWidth )
		clockDivider
		(
			.clockIn	( clock50M ),
			.clockOut	( stateClock )
		);
		
//==============================================================================


	localparam bitLength	= 8;	//Local parameter holding the bit length of communications.
	
	reg currentState;
	reg nextState;
	reg ack;						//Register for state machine telling if the acknowledge bit is correct.
	reg endOK;						//Register for state machine telling if the i2c communcation is correct.
	reg counterValue	= 0;		//Counter for storing the 
	reg bytes 			= 2'b11;	//3 bytes. 1st is slave address, 2nd is register address, 3rd is register data.
	reg writeData;					//Value holding the address and data to be written. 
	
	reg i2cSDAOut;					//Tri-state control for SDA Pin. (output = 1).
	reg SDAOut;						//Internal module output bit for SDA. 
	
	assign sda = i2cSDAOut ? SDAOut : 1'bz;	//Tri state control for the i2c sda pin.
	
	localparam idleState		= 0;
	localparam idleWait			= 1;
	localparam i2cInitialise	= 1;
	localparam i2cGo			= 1;
	localparam dataState	 	= 1;
	localparam clockHighState	= 1;
	localparam clockLowState	= 1;
	localparam acknowledgeState	= 1;
	localparam stopState		= 1;
	
		
	//Logic to handle the currentState -> nextState transition.
	//Sensitivity list based on the SDA transition.
	always @( negedge( reset_n ) or posedge( clockIn ) )
		begin: currentStateLogic
			currentState = nextState;	
		end
		
	//Logic handling which state will transition into which.
	always @( negedge( reset_n ) or posedge( clockIn ) )
		begin: nextStateLogic
		
			if( reset_n == 1'b0 )
				begin
					nextState = idleState;
				end
			else
			
				case( currentState )
					idleState:
						begin
							//If the i2c interface gets a start signal, go to the idleWait state.
							if( i2cStart == 1'b1 )
								begin
									nextState = idleWait;
								end
							//Else stay in the idle state.
							else
								begin
									nextState = currentState;
								end
						end
						
					idleWait:
						begin
							//If the i2c start signal goes low, then go to the i2cIntialise
							if ( i2cStart == 1'b0 )
								begin
									nextState = i2cInitialise;
								end
							else
								begin
									nextState = currentState;
								end
						end
						
					i2cInitialise:
						begin
							//Go to the identify state
							nextState = i2cGo;
						end
						
					i2cGo:
						begin
							//Go to the identifyData state
							nextState = identifyData;
						end
						
					dataState:
						begin
							//Go to the clockHigh state
							nextState = clockHighState;
						end
						
					clockHighState:
						begin
							//Go to the clock Low state
							nextState = clockLowState;
						end
					
					clockLowState:
						begin
							//If the counter is zero, read an acknowledge bit
							if( counterValue == 'd8 ) 
								begin
									nextState = acknowledgeState;
								end
							//Else write the next bit of data
							else
								begin
									nextState = dataState;
								end
						end
					
					acknowledgeState:
						begin
							//Release SDA, and if the acknowledge register is low,
							//That means the slave has acknowledged the communication
							if ( ack == 1'b0 )
								begin
									//nextState = 
								end
							//Else stop communication, and go back to the stop state.
							else	
								begin
									nextState = stopState;
								end
						end
					
					
					
				endcase
		end//nextStateLogic
		
	always @( * )
		begin: currentStateAssignment
			case( currentState )
				
				idleState:
					begin
						//Idle, keep both SDA and SCL high.
						sda			<= 1'b1;
						scl			<= 1'b1;
						ack			<= 1'b0;
						endOK		<= 1'b0;
						writeData	<= 0;
						
					end
					
				idleWait:
					begin
						//Idle, keep both SDA and SCL high. Waiting for i2cStart to go low. 
						sda			<= 1'b1;
						scl			<= 1'b1;
						ack			<= 1'b0;
						endOK		<= 1'b0;
						writeData 	<= 0;
					end
					
				i2cInitialise:
					begin
						//Set SDA low while SCL is high to signalise the start of i2c communications.
						sda			<= 1'b0;
						scl			<= 1'b1;
						ack			<= 1'b0;
						endOK		<= 1'b0;
						writeData 	<= slaveAddress & 1'b0;	//Set to write always.
					end
				
				i2cGo:
					begin
						//Set SDA and SCL low to signal the upcoming communications.
						sda		<= 1'b0;
						scl		<= 1'b0;
					end

				dataState:
					begin
						//Transition the data without changing the clock
						sda 			<= writeData[ ( bitlength - counterValue ) ];
						//Increment the counterValue
						counterValue 	<= counterValue + 1'b1;
					end
					
				clockHighState:
					begin
						//Transition sclOut to high.
						scl		<= 1'b1;
					end
				
				clockLowState:
					begin
						//Transition sclOut to low.
						scl		<= 1'b0;
					end
				
				
					
			endcase
		end
		
endmodule