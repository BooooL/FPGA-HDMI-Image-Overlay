//Vertical Sync Module

module vsync
(
	input [10:0] 	resVertical,		//Vertical Resolution e.g. 1080, 11 bits = 1024 - 2047 max
	input [10:0]	counterVal,			//Counter value to tell vsync when to pulse e.g. every 1080 pixels
	input				clock,
	output 			vSyncPulse			//Output V Sync pulse
);

	//Define Registers
	reg pulseReg = 1'b0;
	
	//Define Assignments
	assign vSyncPulse = pulseReg;
	
	always @( posedge(clock) )
	begin
	
		//If the end of the screen is reached, pulse vsync
		if(counterVal == resVertical)
			pulseReg = 1'b1;
		else
			pulseReg = 1'b0;
		
	end
	
endmodule