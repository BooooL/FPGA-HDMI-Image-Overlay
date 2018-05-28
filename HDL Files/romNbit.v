module romNbit #(
	parameter bitLength = 24,	//Length of ROM as pointed to by the address
	parameter addressWidth = 4,	//Address pointer width. 2^x ROM locations.
)
(
	//input [ ( addressWidth - 1 ) : 0 ] address,
	//Input for incrementing the addressCounter. 
	input counterIncrement,
	//Output to signal i2c state machine to start writing data. 
	output writeEnable,
	output [ ( bitLength - 1 ) : 0 ] dataOut
);

	//Register used for assigning dataOut in an always block
	reg [ ( bitLength - 1 ) : 0 ] data;
	assign dataOut = data;
	
	//Register used for telling the i2c state machine to start.
	reg write = 1'b0;
	assign writeEnable = write;
	
	//Counter used for stepping through the addresses one by one.
	reg [ ( addressWidth - 1 ) : 0 ] addressCounter = 0;
	
	always @ ( posedge ( counterIncrement ) )
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
				14:			data = 24'h000000;
				15: 		data = 24'h000000;
				default: 	data = 24'h000000;
			endcase
		end
		
	//handling the value of the addressCounter.
	always @( posedge ( counterIncrement ) )
		begin
			if( counterIncrement )
				begin
					addressCounter <= address + 1'b1;
					write <= 1'b1;
				end
			else
				begin
					address <= address;
					write <= 1'b0;
				end
		end
endmodule
			
			
			