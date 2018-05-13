//Data Enable module

module DE #( parameter busWidth = 11 )
(
	input 							clock,				//Input clock
	input [ (busWidth - 1) : 0] 	resHorizontal,		//Horizontal Resolution e.g. 1920, 11 bits = 2047 max
	input [ (busWidth - 1) : 0]		hCount,				//hSync counter used to determine horizontal position
	input [ (busWidth - 1) : 0] 	resVertical,		//Vertical Resolution e.g. 1080, 11 bits = 2047 max
	input [ (busWidth - 1) : 0]		vCount,				//vSync counter used to determine vertical position
	output 							deOut,				//DE output signal
);

	//Define Registers
	reg deReg = 1'b0;

	//Assign Registers to outputs
	assign deOut = deReg;

	always @( posedge(clock) )
		begin

			//deOut goes low at the end of the horizontal count 
			if(hCount >= resHorizontal)
				deReg = 1'b0;
			else
				deReg = 1'b1;

			//deOut goes low at the end of the vertical count 
			if(vCount >= resVertical)
				deReg = 1'b0;
			else
				deReg = 1'b1;

		end

endmodule