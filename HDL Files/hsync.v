//Horizontal Sync Module

module hsync #( parameter busWidth = 11 )
(
	input [ (busWidth - 1) : 0] 	resHorizontal,		//Horizontal Resolution e.g. 1920, 11 bits = 2047 max
	input [ (busWidth - 1) : 0] 	counterVal,			//Counter value to tell hsync when to pulse e.g. every 1920 pixels
	input							clock,
	output 							hSyncPulse,			//Output H Sync pulse
	output 							hCountReset_n		//Send a signal to reset the hsync counter to 0
);

	//Define Registers
	reg pulseReg = 1'b0;			//hSync pulse register
	reg reset = 1'b1;				//Reset counter register (Active Low)
	
	//Define Assignments
	assign hSyncPulse = pulseReg;
	assign hCountReset_n = reset;
	
	always @( posedge(clock) )
	begin
	
		//If the end of the first line is reached, pulse the hsync
		if(counterVal >= resHorizontal)
			begin
				pulseReg = 1'b1;
				reset = 1'b0;
			end
		else
			begin
				pulseReg = 1'b0;
				reset = 1'b1;
			end
		
	end
	
endmodule