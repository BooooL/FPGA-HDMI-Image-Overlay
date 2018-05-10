//Horizontal Sync Module

module hsync
(
	input [10:0] 	resHorizontal,		//Horizontal Resolution e.g. 1920, 11 bits = 2047 max
	input [10:0]	counterVal,			//Counter value to tell hsync when to pulse e.g. every 1920 pixels
	input				clock,
	output 			hSyncPulse			//Output H Sync pulse
);

	//Define Registers
	reg pulseReg = 1'b0;
	
	//Define Assignments
	assign hSyncPulse = pulseReg;
	
	always @( posedge(clock) )
	begin
	
		//If the end of the first line is reached, pulse the hsync
		if(counterVal == resHorizontal)
			pulseReg = 1'b1;
		else
			pulseReg = 1'b0;
		
	end
	
endmodule