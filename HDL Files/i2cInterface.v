//Verilog i2c interface
//Copyright (C) 2018 Alexander Knapik & Keane-Gene Yew
//under the GNU General Public License v3.0 or any later version
//05.04.2018

module i2cInterface 

//Parameters used for passing variables

#( 
	input parameter [7:0] data			= 8'hFF,	//Data used for communcations
	input parameter [7:0] slaveAddress	= 8'hFF,	//Address used for the I2C slave
	input parameter [7:0] dataAddress	= 8'hFF 	//Address used for writing to a particular register
)

(
	input i2cStart,		//Input to start communications
	input reset_n,		//Active low reset
	input clockIn,		//Input clock to the controller. Double the speed of SCL.
	input reg sdaIn,	//I2C input data from master.
	output reg sdaOut,	//I2C output data to slave.
	output reg scl		//I2C input communications reference clock. 400kHz
);

	localparam bitLength	= 8;		//Local parameter holding the bit length of communications.
	
	reg currentState;
	reg nextState;
	reg ackOK;			//Register for state machine telling if the acknowledge bit is correct.
	reg endOK;			//Register for state machine telling if the i2c communcation is correct.
	reg counter;		//Counter for storing the 
	
	//assign SCL = i2cClock;
	//assign SDA = i2cData;
	
	localparam idleState		= 0;
	localparam idleWait			= 1;
	localparam i2cInitialise	= 1;
	localparam i2cGo			= 1;
	localparam dataState	 	= 1;
	localparam clockState		= 1;
	
		
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
						
						end
						
					clockState:
					
					
					
				endcase
		end//nextStateLogic
		
	always @( * )
		begin: currentStateAssignment
			case( currentState )
				
				idleState:
					begin
						//Idle, keep both SDA and SCL high.
						sdaOut	= 1'b1;
						scl		= 1'b1;
						ackOK	= 1'b0;
						endOK	= 1'b0;
					end
					
				idleWait:
					begin
						//Idle, keep both SDA and SCL high. Waiting for i2cStart to go low. 
						sdaOut	= 1'b1;
						scl		= 1'b1;
						ackOK	= 1'b0;
						endOK	= 1'b0;
					end
					
				i2cInitialise
					begin
						//Set SDA low while SCL is high to signalise the start of i2c communications.
						sdaOut	= 1'b0;
						scl		= 1'b1;
						ackOK	= 1'b0;
						endOK	= 1'b0;
					end
				
				i2cGo:
					begin
						//Set SDA and SCL low to signal the upcoming communications.
						sdaOut 	= 1'b0;
						scl		= 1'b0;
						ackOK	= 1'b0;
						endOK	= 1'b0;
					end

				dataState:
					begin
					end
					
				clockState:
					begin
					end
					
			endcase
		end
		
endmodule