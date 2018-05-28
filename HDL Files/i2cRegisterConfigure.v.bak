module i2cRegisterConfigure #(
	parameter bitLength = 24,	//Length of ROM as pointed to by the address
	parameter addressWidth = 4	//Address pointer width. 2^x ROM locations.
)
(
	//State machine clock 
	//input clock,
	//Input telling that the the i2c writing has completed and is awaiting new data. 
	input i2cReady,
	//Output to signal i2c state machine to start writing data. 
	output writeOutput,
	//Data out from the ROM.
	output [ ( bitLength - 1 ) : 0 ] dataOut
);

	//Register used for assigning dataOut in an always block
	reg [ ( bitLength - 1 ) : 0 ] data = 0;
	assign dataOut = data;
	
	//Register used for telling the i2c state machine to start.
	reg i2cWrite 		= 1'b0;
	assign writeOutput 	= i2cWrite;
	
	//Counter used for stepping through the addresses one by one.
	reg [ ( addressWidth - 1 ) : 0 ] addressCounter = 0;
	
	reg [1:0] currentState = 2'b00;
	reg [1:0] nextState = 2'b00;
	
	localparam resetState 		= 0;
	localparam idleState		= 1;
	localparam writeState		= 2;
	localparam incrementState 	= 3;
	
	always @ ( * )
		begin
			//0x72 is ADV7513 write address
			case( addressCounter )
				0:			data = 24'h724110;	//power up. set sync polarity to positive.
				1:			data = 24'h729803;
				2:			data = 24'h729ae0;
				3:			data = 24'h729c30;
				4:			data = 24'h729d61;	//No internal clock divide.
				5:			data = 24'h72a2a4;
				6:			data = 24'h72a3a4;
				7:			data = 24'h72e0d0;
				8:			data = 24'h72f900;
				9:			data = 24'h7215f0;
				10:			data = 24'h721610;	//4:4:4, 8 bit colour, rgb, falling edge ddr.
				11:			data = 24'h721702;	//0x02 for 16:9, 0x00 for 4:3
				12:			data = 24'h721846;
				13:			data = 24'h72af06;	//[1]: 1 for HDMI, 0 for DVI
				default: 	data = 24'h000000;
			endcase
		end
		
	/*
		
	always @( posedge( clock ) )
		begin
			currentState <= nextState;
		end
		
	always @( posedge( clock ) )
		begin
			case( currentState )
				default:	
					begin
						nextState <= currentState;
					end
				resetState:
					begin
						nextState <= idleState;
					end
				idleState:
					begin
						if ( i2cReady )
							begin
								nextState <= writeState;
							end
						else
							begin
								nextState <= currentState;
							end
					end
				writeState:
					begin
						nextState <= incrementState;
					end
				incrementState:
					begin
						nextState <= idleState;
					end
			endcase
		end //always
		
	always @( * )
		begin
			
			case( currentState )
				default:
					begin
						addressCounter 	= 0;
						i2cWrite 		= 1'b0;
					end
				resetState:
					begin
						addressCounter 	= 0;
						i2cWrite 		= 1'b0;
					end
				idleState:
					begin
						addressCounter	= addressCounter;
						i2cWrite		= 1'b0;
					end
				writeState:
					begin
						addressCounter	= addressCounter;
						
						//If the counter value is greater than 13 (All registers have been written)
						//Then keep i2cWrite as zero.
						if( addressCounter > 13 )
							begin
								i2cWrite 	= 1'b0;
							end
						else
							begin
								i2cWrite 	= 1'b1;
							end
					end//writeState
				incrementState:
					begin
						//If the counter value is greater than 13 (All registers have been written)
						//Then keep the addressCounter the same value, and don't increment.
						if( addressCounter > 13 )
							begin
								addressCounter	= addressCounter;
							end
						else
							begin
								addressCounter	= addressCounter + 1'b1;
							end
						
						i2cWrite		= 1'b0;
					end //incrementState
			endcase		
		end //always
	*/
	
	//handling the value of the addressCounter.
	always @( posedge ( i2cReady ) )
		begin
			if( i2cReady )
				begin
					addressCounter <= addressCounter + 1'b1;
					
					//Code to stop writing once all the registers have been written.
					//If the addressCounter is 13 or greater (all registers have been written)
					//Then keep the values the same, and don't write. 
					if( addressCounter > 12 )
						begin
							addressCounter <= addressCounter;
							i2cWrite <= 1'b0;
						end
					else
						begin
							addressCounter <= addressCounter + 1'b1;
							i2cWrite <= 1'b1;
						end
				end
			else
				begin
					addressCounter <= addressCounter;
					i2cWrite <= 1'b0;
				end
		end
		
endmodule
			
			
			