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

module dataWrite
(
	input 			clock,
	output [23:0] 	dataOutput
);

	//State parameters
	parameter 	[1:0] 	state1 			= 2'b00;
	parameter 	[1:0] 	state2 			= 2'b01;
	parameter 	[1:0] 	state3 			= 2'b10;
	parameter 	[1:0] 	state4 			= 2'b11;

	//Register Definitions
	reg 		[1:0] 	currentState 	= state1;
	reg 		[1:0] 	nextState 		= state1;
	reg 		[23:0]	outputReg		= 24'h000000;

	//Assign Definitions
	assign dataOutput = outputReg;

	//Next state transition logic
	always @( posedge(clock) )
		begin: stateChange
			currentState <= nextState;
		end

	//State machine logic
	always @( posedge(clock) )
	begin: nextStateLogic
		
		case(currentState)
			//1st try to write a basic colour test to the screen (White)

			state1:
				begin
					outputReg = 24'hffffff; //White 256, 256, 256
					nextState = state1;
				end

			default: 
				begin
					outputReg = 24'hffffff; //White 256, 256, 256
					nextState = state1;
				end

		endcase

	end

endmodule