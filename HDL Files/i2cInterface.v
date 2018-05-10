//Verilog i2c interface
//Copyright (C) 2018 Alexander Knapik & Keane-Gene Yew
//under the GNU General Public License v3.0 or any later version
//05.04.2018

module i2cInterface 

//Parameters used for passing variables

#( 
	parameter [7:0] data			= 2'hFF,	//Data used for communcations
	parameter [7:0] slaveAddress	= 2'hFF,	//Address used for the I2C slave
	parameter [7:0] dataAddress		= 2'hFF 	//Address used for writing to a particular register
)

(
	input i2cStart,		//Input to start communications
	//input reset_n,		//Active low reset
	inout SCL,			//I2C input communications reference clock. 400kHz
	inout SDA			//I2C input data for communcations.
);

	localparam bitLength	= 8;		//Local parameter holding the bit length of communications.
	
	reg currentState;
	reg nextState;
	reg clockEnable;					//Register used for enabling the clock to pulse.
	reg i2cClock;
	reg i2cData;
	
	assign SCL = i2cClock;
	assign SDA = i2cData;
	
	localparam idleState		= 0;
	localparam identifyState 	= 1;
	localparam dataState 		= 2;
	localparam acknowledgeState	= 3;
		
	//Logic to handle the currentState -> nextState transition.
	//Sensitivity list based on the SDA transition.
	always @( SDA, SCL, i2cStart )
		begin: currentStateLogic
			currentState = nextState;	
		end
		
	//Logic handling which state will transition into which.
	always @( * )
		begin: nextStateLogic
			case( currentState )
			
				idleState:
					begin
						//If SDA transitions to low, while SCL is high, go to the identifyState
						if( SDA == 1'b0 && SCL == 1'b1)
							begin
								nextState = identifyState;
							end
						//Else stay in the idle state.
						else
							begin
								nextState = currentState;
							end
					end
					
				identifyState:
					begin
						//Start sending out the device ID information. Starting with bit 7.
					end
			endcase
		end//nextStateLogic
		
	always @( * )
		begin: currentStateAssignment
			case( currentState )
				
				idleState:
					begin
						i2cData = 1'b1;
						i2cClock = 1'b1;
						clockEnable = 1'b0;
					end
					
				identifyState:
					begin
						clockEnable = 1'b1;
					end
					
				acknowledgeState:
					begin
					end
					
				dataState:
					begin
					end
			endcase
		end
		
endmodule