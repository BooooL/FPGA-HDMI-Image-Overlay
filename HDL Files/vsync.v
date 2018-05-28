//Vertical Sync Module

module vsync #( 
	parameter busWidth = 11, 
	parameter [ ( busWidth - 1 ) : 0 ] resVertical = 1080
)
(
	//input [ (busWidth - 1) : 0] 	resVertical,		//Vertical Resolution e.g. 1080, 11 bits = 1024 - 2047 max
	//input [ (busWidth - 1) : 0]	counterVal,			//Counter value to tell vsync when to pulse e.g. every 1080 pixels
	input							clock,				//Pixel clock speed
	output 							vSyncPulse			//Output V Sync pulse
	//output 						vCountReset_n		//Send a signal to reset the vSync counter to 0
);

	//Define Registers
	reg pulseReg = 1'b0;
	reg [ ( busWidth - 1 ) : 0 ] vCounter = 1'b0;	//Counter used to store the current value of the vertical pixel being drawn.

	//reg reset = 1'b1;				//Reset counter register (Active Low)
	
	//Define Assignments
	assign vSyncPulse = pulseReg;
	//assign vCountReset_n = reset;
	
	always @( posedge(clock) )
	begin
		//If the end of the first line is reached, pulse the hsync
		if( vCounter == resVertical)
			begin
				//Pulse HSync
				pulseReg = 1'b1;
				//Reset the counter.
				vCounter = 0;
			end
		else
			begin
				//Keep HSync low
				pulseReg = 1'b0;
				//Increment the counter.
				vCounter = vCounter + 1'b1;
				//reset = 1'b1;
			end
	end
	
endmodule