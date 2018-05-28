//Verilog i2c interface
//Copyright (C) 2018 Alexander Knapik & Keane-Gene Yew
//under the GNU General Public License v3.0 or any later version
//05.04.2018

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

module i2cInterface
//Parameters used for passing variables
#( 	
	//24 Bit data used for storing the following:
	//[23:16] 	Slave Address
	//[15:8]	Register Address
	//[7:0]		Data to be written to register. 
	//parameter [23:0] dataIn		= 24'hAFAFAF,
	
	//Parameters used for calculating the values needed for creating the
	//state machine clock. Values are in Hz.
	parameter inputSpeed		= 50 	* ( 10 ** 6 ), 	//Input reference clock in MHz
	parameter sclSpeed			= 100 	* ( 10 ** 3 )	//SCL communication speed in kHz
)
(
	input 	refClock,		//Input reference clock.
	input [23:0] dataIn,
	input 	i2cGo,			//Input signal to start communications
	//input 	reset_n,		//Active low reset
	inout 	sda,			//I2C SDA
	output	scl,			//I2C input communications reference clock. 400kHz
	output 	i2cComplete		//Output signal stating that the input data has successfully communicated.

);

//==============================================================================
//				CLOCK GENERATOR USED FOR THE STATE MACHINE CLOCK
	
	//Set the state machine to run at four times the speed of SCL.
	localparam stateSpeed = ( sclSpeed * 4 );
	
	//Define the bit width based on the clock speeds. .
	//log2( inputSpeed / stateSpeed ),				Round up.
	//ln( inputSpeed / stateSpeed ) / ln( 2 ),		Round up.
	localparam clockWidth = 7;
	
	//Wire used for connecting the state clock to the state machine.
	wire stateClock;
	
	clockGen 
	//Pass the parameters to the instantiated module.
	#( inputSpeed, stateSpeed, clockWidth )
		clockDivider
		(
			.clockIn	( refClock ),
			.clockOut	( stateClock )
		);
		
//==============================================================================

	localparam bitLength	= 8;			//Local parameter holding the bit length of communications.
	localparam byteLength	= 3;			//Local parameter holding the byte length of communications.
	localparam dataLength 	= 24;			//Local parameter holding the length of the data input.
	
	reg ackOK;								//Register for state machine telling if the acknowledge bit is correct.
	reg endOK;								//Register for state machine telling if the i2c communcation has ended	
	reg i2cSDAOut;							//Tri-state control for SDA Pin. (output = 1).
	reg SDAOut;								//Internal module output bit for SDA.
	reg SCL;									//Register output for SCL.
	//reg [23:0] dataIn;					//I2C Data Register
	
	//wire [ ( dataLength - 1 ) : 0 ] data = dataIn;	//Wire used for holding the dataIn parameter.
	
	reg [1:0] byteCounter	= 2'b00;		//Counter used for storing the i2c tranmission bytes
	reg [3:0] bitCounter	= 3'b000;		//Counter used for storing the bits transmitted in said byte.
	reg [4:0] dataCounter 	= 4'b0000;		//Counter used for storing the location of the data register.
	
	assign sda 			= i2cSDAOut ? SDAOut : 1'bz;	//Tri state control for the i2c sda pin.
	assign scl 			= SCL;							//Register mapping for output.
	assign i2cComplete	= endOK;
	
	localparam idleState			= 0;	//Idle/Reset state. Stop i2c communications.
	localparam i2cInitialise		= 1;	//Set SDA low while SCL is high to initialise communications.
	localparam i2cInitialiseDelay	= 2;	//Delay state for an even clock period
	localparam i2cEnable			= 3;	//Set SCL low while SDA is low to start I2C communications.
	localparam i2cShift				= 4;	//Right shift the input data to a register to be written.
	localparam i2cClockHigh1		= 5;	//Set clock High
	localparam i2cClockHigh2		= 6;	//Delay state for an even clock period.
	localparam i2cClockLow			= 7;	//Set clock low
	localparam i2cAck1				= 8;	//If 8 bits of data have been written, set SDA to z for reading.
	localparam i2cAck2				= 9;	//Delay state for even clock period
	localparam i2cAck3				= 10;	//If acknowledge was received, keep SCL high
	localparam i2cAck4				= 11;	//Clock Low. Increment byte write counter.
	localparam i2cStop1				= 12;	//Set SCL and SDA low for initialising the stop of communications.
	localparam i2cStop2				= 13;	//Set SCL high while SDA is low to initialise stopping i2c communications
	
	reg [3:0] currentState;	//Storing current state. Default idle state.
	reg [3:0] nextState;					//Storing next state
		
	//Logic to handle the currentState -> nextState transition.
	//Sensitivity list based on the SDA transition.
	always @( posedge( stateClock ) )
		begin: nextStateTransition
			currentState <= nextState;	
		end
		
	//Logic handling which state will transition into which.
	always @( nextState, currentState, i2cGo, bitCounter, ackOK, byteCounter )
	//always@( posedge( stateClock ) )
		begin: nextStateLogic	
		/*
			if( reset_n == 1'b0 )
				begin
					nextState <= idleState;
				end
			else
		*/
				begin
					case( currentState )
						default:
							begin
								nextState <= idleState;
							end
							
						i2cStop1:
							begin
								nextState <= i2cStop2;
							end
							
						i2cStop2:
							begin
								nextState <= idleState;
							end
						
						idleState:
							begin
								if( i2cGo == 1 )
									begin
										nextState <= i2cInitialise;
									end
								else
									begin
										nextState <= currentState;
									end
							end
						
						i2cInitialise:
							begin
								nextState <= i2cInitialiseDelay;
							end
						
						i2cInitialiseDelay:
							begin
								nextState <= i2cEnable;
							end
						
						i2cEnable:
							begin
								nextState <= i2cShift;
							end
						
						i2cShift:
							begin
								nextState <= i2cClockHigh1;
							end
							
						i2cClockHigh1:
							begin
								nextState <= i2cClockHigh2;
							end
						
						i2cClockHigh2:
							begin
								nextState <= i2cClockLow;
							end
							
						i2cClockLow:
							begin
								//If the bitCounter is 8 ( The byte of data has been completely written )
								//Then handle the i2c slave acknowledge
								if ( bitCounter == ( bitLength ) )
									begin
										nextState <= i2cAck1;
									end
									//Else handle the next bit of data.
								else
									begin
										nextState <= i2cShift;
									end
							end
							
						i2cAck1:
							begin
								nextState <= i2cAck2;
							end
							
						i2cAck2:
							begin
								nextState <= i2cAck3;
							end
							
						i2cAck3:
							begin
								if( ackOK == 1'b1 )
									begin
										nextState <= i2cAck4;
									end
								else
									begin
										nextState <= i2cStop1;
									end
							end
							
						i2cAck4:
							begin
								//If the byteCounter is 3 ( i2c communications has completed )
								//Then handle stopping communications.
								if( byteCounter == ( byteLength ) )
									begin
										nextState <= i2cStop1;
									end
								//Else handle the next byte of data.
								else
									begin
										nextState <= i2cShift;
									end
							end
					endcase
				end//else
		end//nextStateLogic
		
	//always @( currentState, bitCounter, byteCounter, dataCounter, dataIn, sda, ackOK )
	always@( posedge( stateClock ) )
	//always @( currentState )
		begin: currentStateLogic
			
			case( currentState )
					default:
						begin
							SCL 		<= 1'b1;
							i2cSDAOut	<= 1'b1;
							SDAOut		<= 1'b1;
							endOK		<= 1'b0;
							ackOK		<= 1'b0;
							bitCounter	<= 1'b0;
							byteCounter	<= 1'b0;
							dataCounter	<= 1'b0;
						end
						
					i2cStop1:
						begin
							SCL			<= 1'b0;
							i2cSDAOut	<= 1'b1;
							SDAOut		<= 1'b0;
							endOK		<= 1'b0;
							ackOK		<= 1'b0;
							bitCounter	<= 1'b0;
							byteCounter	<= 1'b0;
							dataCounter	<= 1'b0;
						end
						
					i2cStop2:
						begin
							SCL			<= 1'b1;
							i2cSDAOut	<= 1'b1;
							SDAOut		<= 1'b0;
							endOK		<= 1'b1;
							ackOK		<= 1'b0;
							bitCounter	<= 1'b0;
							byteCounter	<= 1'b0;
							dataCounter	<= 1'b0;
						end
						
					idleState:
						begin
							SCL			<= 1'b1;
							i2cSDAOut	<= 1'b1;
							SDAOut		<= 1'b1;
							endOK		<= 1'b1;
							ackOK		<= 1'b0;
							bitCounter	<= 1'b0;
							byteCounter	<= 1'b0;
							dataCounter <= 1'b0;
						end
						
					i2cInitialise:
						begin
							SCL			<= 1'b1;
							i2cSDAOut	<= 1'b1;
							SDAOut		<= 1'b1;
							endOK		<= 1'b0;
							ackOK		<= 1'b0;
							bitCounter	<= bitCounter;
							byteCounter	<= byteCounter;
							dataCounter	<= dataCounter;

						end
						
					i2cInitialiseDelay:
						begin
							SCL			<= 1'b1;
							i2cSDAOut	<= 1'b1;
							SDAOut		<= 1'b0;
							endOK		<= 1'b0;
							ackOK		<= 1'b0;
							bitCounter	<= bitCounter;
							byteCounter	<= byteCounter;
							dataCounter	<= dataCounter;
						end
						
					i2cEnable:
						begin
							SCL			<= 1'b0;
							i2cSDAOut	<= 1'b1;
							SDAOut		<= 1'b0;
							endOK		<= 1'b0;
							ackOK		<= 1'b0;
							bitCounter	<= bitCounter;
							byteCounter	<= byteCounter;
							dataCounter	<= dataCounter;
						end
						
					i2cShift:
						begin
							SCL			<= 1'b0;
							i2cSDAOut	<= 1'b1;
							SDAOut		<= dataIn[ ( ( dataLength - 1 ) - dataCounter ) ]; //set SDAOut to the highest bit of the input data.
							endOK		<= 1'b0;
							ackOK		<= 1'b0;
							bitCounter	<= bitCounter;
							byteCounter	<= byteCounter;
							dataCounter	<= dataCounter;
						end
						
					i2cClockHigh1:
						begin
							SCL			<= 1'b1;
							i2cSDAOut	<= 1'b1;
							SDAOut		<= dataIn[ ( ( dataLength - 1 ) - dataCounter ) ]; //Keep SDAOut the same.
							endOK		<= 1'b0;
							ackOK		<= 1'b0;
							bitCounter	<= bitCounter;
							byteCounter	<= byteCounter;
							
						end
						
					i2cClockHigh2:
						begin
							SCL			<= 1'b1;
							i2cSDAOut	<= 1'b1;
							SDAOut		<= dataIn[ ( ( dataLength - 1 ) - dataCounter ) ]; //Keep SDAOut the same.
							endOK		<= 1'b0;
							ackOK		<= 1'b0;
							bitCounter	<= bitCounter + 1'b1; //Increment the bitCounter
							byteCounter	<= byteCounter;
							dataCounter	<= dataCounter;
							
							/* What is this doing? 
							//If the bitCounter is 7 ( The byte of data has been completely written )
							//Then left shift the data input by 1 bit.
							if(	bitCounter == ( bitLength - 1 ) )
								begin
									data [ dataLength - 1 ] = data [ dataLength - 2 ];
								end
							*/
						end
						
					i2cClockLow:
						begin
							SCL 		<= 1'b0;
							i2cSDAOut	<= 1'b1;
							//data		= data;
							//SDAOut		= data[ ( dataLength - 1 ) ];	//set SDAOut to the highest bit of the input data.
							SDAOut		<= dataIn[ ( ( dataLength - 1 ) - dataCounter ) ];
							endOK		<= 1'b0;
							ackOK		<= 1'b0;	
							bitCounter	<= bitCounter;
							byteCounter	<= byteCounter;
							dataCounter <= dataCounter + 1'b1;

							
							/*
							//If the bitCounter is not 8, then increment the dataCounter
							if( bitCounter != 8 )
								begin
									dataCounter = dataCounter + 1'b1;
								end
							//Else keep it the same.
							else
								begin
									dataCounter = dataCounter;
								end
							*/
						end

					i2cAck1:
						begin
							SCL			<= 1'b0;
							i2cSDAOut	<= 1'b0;	//Set i2cSDAOut low to enable reading of sda inout value.
							SDAOut		<= 1'bz;	//Ignored as sda is high impedance anyways.
							endOK		<= 1'b0;
							ackOK		<= 1'b0;
							bitCounter	<= 1'b0;
							byteCounter	<= byteCounter;
							dataCounter	<= dataCounter;
						end
						
					i2cAck2:
						begin
							SCL			<= 1'b1;
							i2cSDAOut	<= 1'b0;	//Set i2cSDAOut low to enable reading of sda inout value.
							SDAOut		<= 1'bz;	//Ignored as sda is high impedance anyways.
							endOK		<= 1'b0;
							bitCounter	<= bitCounter;
							byteCounter	<= byteCounter;
							dataCounter	<= dataCounter;
							
							//If SDA has been set high by the i2c slave, then set ackOK high.
							if( sda == 1'b1 )
								begin
									ackOK <= 1'b1;
								end
							else
								begin
									ackOK <= ackOK;
								end
						end
						
					i2cAck3:
						begin
							SCL			<= 1'b1;
							i2cSDAOut	<= 1'b0;	//Set i2cSDAOut low to enable reading of sda inout value.
							SDAOut		<= 1'bz;	//Ignored as sda is high impedance anyways.
							endOK		<= 1'b0;
							bitCounter	<= bitCounter;
							byteCounter	<= byteCounter + 1'b1; //Increment byteCounter
							dataCounter	<= dataCounter;

							//If SDA has been set high by the i2c slave
							//then set ackOK high
							if( sda == 1'b1 )
								begin
									ackOK <= 1'b1;
								end
							else
								begin
									ackOK <= ackOK;
								end
						end

					i2cAck4:
						begin
							SCL			<= 1'b0;
							i2cSDAOut	<= 1'b0;	//Set i2cSDAOut low to enable reading of sda inout value.
							SDAOut		<= 1'bz;	//Ignored as sda is high impedance anyways.
							ackOK		<= 1'b0;
							endOK		<= 1'b0;
							bitCounter	<= bitCounter;
							byteCounter	<= byteCounter;
							dataCounter	<= dataCounter;
						end
				endcase
		end//currentStateLogic
		
endmodule