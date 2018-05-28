//Data Enable module

module DE #( 
	parameter busWidth = 11,
	parameter [ ( busWidth - 1 ) : 0 ] resHorizontal 	= 1920,
	parameter [ ( busWidth - 1 ) : 0 ] resVertical		= 1080
)
(
	input 							hSync,				//Input clock
	//input [ (busWidth - 1) : 0] 	resHorizontal,		//Horizontal Resolution e.g. 1920, 11 bits = 2047 max
	//input [ (busWidth - 1) : 0]		hCount,				//hSync counter used to determine horizontal position
	//input [ (busWidth - 1) : 0] 	resVertical,		//Vertical Resolution e.g. 1080, 11 bits = 2047 max
	input [ (busWidth - 1) : 0]		vCount,				//vSync counter used to determine vertical position
	output 							deOut				//DE output signal
);

	//Define Registers
	reg deReg = 1'b0;								//Register used to store the value of DE.
	reg [ ( busWidth - 1 ) : 0 ] counter = 1'b0;	//Counter storing the horizontal pixel location.

	//Assign Registers to outputs
	assign deOut = deReg;

	always @( posedge( hSync ) )
		begin

			//If the pixel is at the last location in the horizontal position,
			//Set DE to low, and reset the counter. 
			if( counter == resHorizontal )
				begin
					deReg 	= 1'b0;
					counter	= 1'b0;
				end
			//Else, Set DE high, and increment the counter. 
			else
				begin
					deReg 	= 1'b1;
					counter = counter + 1'b1;
				end

			/*
			//deOut goes low at the end of the vertical count 
			if(vCount >= resVertical)
				deReg = 1'b0;
			else
				deReg = 1'b1;
			*/
		end
endmodule