//24-bit data output module - RGB format

//1st try to write a basic colour test to the screen
	//Continuously output a white screen (255, 255, 255)
//2nd try to read from the ROM and write to the screen
	//Create ROM module with MIF table containing random self inserted values
	//Use a counter to select each 24 bit address of the ROM and send the data to this module. 
	//Output the data to the HDMI module once per clock cycle
//3rd try to read an image from the ROM and write to the screen
	//Same as previous except we need to successfully convert an image to MIF format.
	// https://github.com/LonghornEngineer/img2mif contains a bmp to mif convertor and an example
	//1920 x 1080 x 24 bits = 49,766,400 bits = 6,220,800 bytes = 6,220.8 Kbytes = 6.22 Mbytes?

module dataWrite #(
	parameter 									hLength 			= 11,
	parameter 									vLength 			= 11, 
	parameter [ ( hLength - 1 ) : 0 ] 	resHorizontal 	= 1280,
	parameter [ ( vLength - 1 ) : 0 ] 	resVertical 	= 720
)
(
	input 				clock,
	input 				key0, 			//Used to cycle through characters
	input 				key1, 			//Used to select the character
	input 	[7:0] 	romData, 		//Data from lookup table
	output 	[23:0] 	dataOutput,
	output 	[10:0] 	romAddress	 	//Used to select the location of the character
);

	//State parameters
	parameter 	[1:0] 	keyState 			= 2'b00;
	parameter 	[1:0] 	romWrite 			= 2'b01;
	parameter 	[1:0] 	writeBlank 			= 2'b10;
	parameter 	[1:0] 	state4 				= 2'b11;

	//Register Definitions
	reg 		[1:0] 					currentState 	= romWrite;
	reg 		[1:0] 					nextState 		= romWrite;
	reg 		[23:0]					outputReg		= 24'h000000;
	reg [ ( hLength - 1 ) : 0 ] 	xLocation 		= 1'b0; //X Cursor location
	reg [ ( vLength - 1 ) : 0 ] 	yLocation 		= 1'b0; //Y Cursor location
	reg [3:0] 							dataLocation 	= 4'b1000; //index for romData (7 to 0). Go from 8 to 1 (8 bits)
	reg [11:0] 							pixelRemainder = 0; //Counter for the number of pixels left in the current line.
	reg [11:0] 							verticalPixelRemainder = resVertical; //Counter for the number of pixels left vertically. 
	reg [5:0] 							alphabetCount 	= 1'b0; //A = 0, B = 1, etc...
	reg [10:0] 							romAddressReg 	= 0;

	//Assign Definitions
	assign dataOutput = outputReg;
	assign romAddress = romAddressReg;

	//Next state transition logic
	always @( posedge(clock) )
		begin: stateChange
			currentState <= nextState;
		end

	//State machine logic
	always @( posedge(clock) )
	begin: currentStateLogic
		
		case(currentState)
			//Text engine
			
			keyState:
				begin
					
				end

			romWrite:
				begin
					
					if(dataLocation > 0) //If datalocation hasnt finished yet, continue
						begin
							
							if(romData[dataLocation-1] == 1'b1) //if bit = 1, output black
								begin
									outputReg = 24'h000000; //Black
									pixelRemainder = pixelRemainder + 1'b1;
									dataLocation = dataLocation - 1'b1; //decrement index value
								end
							else if(romData[dataLocation-1] == 1'b0) //if bit = 0, output white
								begin
									outputReg = 24'hffffff; //White
									pixelRemainder = pixelRemainder + 1'b1;
									dataLocation = dataLocation - 1'b1; //decrement index value
								end
							else
								outputReg = 24'hffffff; //White just in case
						end
						
				end
				
			writeBlank:
				begin
					if(pixelRemainder < resHorizontal) //If pixelRemainder <= 1280, output = white
						begin
							outputReg = 24'hffffff; //White
							pixelRemainder = pixelRemainder + 1'b1; //increment pixel remainder value by 1.
						end
					else if(pixelRemainder == resHorizontal) //If the end of the line is reached, increment the vertical pixel count by 1.
						begin
							verticalPixelRemainder = verticalPixelRemainder + 1'b1; //increment vertical pixel count by 1.
							pixelRemainder = 0; //Reset horizontal pixel count
							dataLocation = 4'b1000; //Reset dataLocation index
						end
				end

			default: 
				begin
					outputReg = 24'hffffff; //White 256, 256, 256
					//nextState = romWrite;
				end

		endcase

	end //end currentStateLogic
	
	//Next State Logic
	always @( posedge(clock) )
	begin: nextStateLogic
		
		case(currentState)
			default:
				begin
				end
				
			keyState:
				begin
					
				end
				
			//Write all 8 bits of the rom
			romWrite:
				begin
					if(key0 == 0) //If key0 is pressed
						begin
							alphabetCount = alphabetCount + 1'b1; //0 = A, 1 = B, 2 = C, etc.
							romAddressReg = alphabetCount * 3'b101; //Each character takes up 5 addresses. 0 = A, 5 = B, 10 = C, etc.
							nextState <= romWrite;
						end
					else if(dataLocation == 0) //If the 8 bits have been written, go to writeBlank state to write white pixels to the rest of the line
						begin
							nextState <= writeBlank;
						end
					else if(romAddressReg == (alphabetCount + 1'b1) * 3'b101) //If the 5 byte character has been written, continue to write white.
						begin
							nextState <= writeBlank;
						end
					else
						nextState <= romWrite;
				end
				
			writeBlank:
				begin
					if(key0 == 0) //If key0 is pressed
						begin
							alphabetCount = alphabetCount + 1'b1; //0 = A, 1 = B, 2 = C, etc.
							romAddressReg = alphabetCount * 3'b101; //Each character takes up 5 addresses. 0 = A, 5 = B, 10 = C, etc.
							nextState <= romWrite;
						end
					else if(pixelRemainder == resHorizontal) //if the line ends
						begin
							if(romAddressReg == (alphabetCount + 1'b1) * 3'b101) //If the 5 byte character has been written, continue to write white.
								begin
									nextState = writeBlank;
								end
							else //else (still writing the 5 byte character) go back to romWrite and increment the rom address
								begin
									nextState <= romWrite; //Go back to romWrite to start writing next line of character from the ROM
									romAddressReg = romAddressReg + 1'b1; //Increment rom address
								end
						end
					else
						nextState <= writeBlank; //Else, continue to write blank pixels
				end
		
		endcase
	end //nextStateLogic


	
	
	
	
	
	
	
	
	
	
endmodule