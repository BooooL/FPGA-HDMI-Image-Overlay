//Text engine module

//Keep track of "cursor" location e.g. pixel location (238, 132) out of (1280, 720)
//Choose character
//Somehow link that chosen character to its data location in the lookup table
//Write first line of the character
//Move the cursor location down 1 pixel
//Repeat for the second line, and so on until the character is written
//Calculate new position of cursor 
//If cursor reaches end, go to new line
//
//Repeat 

///////Character system//////
//Press key0 to cycle through the alphabet
//Press key1 to select the character

module textEngine #(
	parameter 									hLength 			= 11,
	parameter 									vLength 			= 11, 
	parameter [ ( hLength - 1 ) : 0 ] 	resHorizontal 	= 1280,
	parameter [ ( vLength - 1 ) : 0 ] 	resVertical 	= 720
)
(

	input 				clock, 			//Input clock
	input 				key0, 			//Used to cycle through characters
	input 				key1, 			//Used to select the character
	input 				nextAddress,	//Flag to go increment address value
	//input 	[7:0] 	characterData, //8 bits of character info from the lookup table
	output 	[11:0] 	romAddress	 	//Used to select the location of the character

);

	//Register definitions
	reg [ ( hLength - 1 ) : 0 ] 	xLocation 		= 0; //X Cursor location
	reg [ ( vLength - 1 ) : 0 ] 	yLocation 		= 0; //Y Cursor location
	reg [5:0] 							alphabetCount 	= 0; //A = 0, B = 1, etc...
	reg [10:0] 							romAddressReg 	= 0;
	
	//Assignments
	assign romAddress = romAddressReg;
	
	always @( posedge(clock) )
	begin
		if(key0 == 0) //If key0 is pressed
		begin
			alphabetCount = alphabetCount + 1;
			romAddressReg = alphabetCount * 5; //Each character takes up 5 addresses. 0 = A, 5 = B, 10 = C, etc.
			//Begin character writing process
			//lookup character in the table
			//write character
			//new character position
		end
	end
	
	always @( posedge(clock) )
		begin
			if(nextAddress == 1'b1)
				begin
					romAddressReg = romAddressReg + 1; //Increment rom address
					
				end
		end
	

endmodule