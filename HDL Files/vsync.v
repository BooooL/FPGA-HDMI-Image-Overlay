//Vertical Sync Module

module vsync #( 
	parameter busWidth = 11, 
	parameter [ ( busWidth - 1 ) : 0 ] resVertical = 1080
)
(
	//input [ (busWidth - 1) : 0] 	resVertical,		//Vertical Resolution e.g. 1080, 11 bits = 1024 - 2047 max
	input [ (busWidth - 1) : 0]		counterVal,			//Counter value to tell vsync when to pulse e.g. every 1080 pixels
	input							clock,
	output 							vSyncPulse,			//Output V Sync pulse
	output 							vCountReset_n		//Send a signal to reset the vSync counter to 0
);

	//Define Registers
	reg pulseReg = 1'b0;
	reg reset = 1'b1;				//Reset counter register (Active Low)
	
	//Define Assignments
	assign vSyncPulse = pulseReg;
	assign vCountReset_n = reset;
	
	always @( posedge(clock) )
	begin
	
		//If the end of the screen is reached, pulse vsync
		if(counterVal >= resVertical)
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