//Horizontal Sync Module

module hsync #( 
	parameter busWidth = 11,
	parameter [ ( busWidth - 1 ) : 0 ] resHorizontal = 1920
)
(
	//input [ (busWidth - 1) : 0] 	resHorizontal,		//Horizontal Resolution e.g. 1920, 11 bits = 2047 max
	//input [ (busWidth - 1) : 0] 	counterVal,			//Counter value to tell hsync when to pulse e.g. every 1920 pixels
	input							clock,
	output 							hSyncPulse,			//Output H Sync pulse
	output							DE					//Data enable
	//output 						hCountReset_n	//Send a signal to reset the hsync counter to 0
);

	//Define Registers
	reg pulseReg 							= 1'b0; //hSync pulse register
	reg [ ( busWidth - 1 ) : 0 ] hCounter 	= 1'b0;	//Counter used to store the current value of the horizontal pixel being drawn.
	reg de 									= 1'b0;
	//reg reset = 1'b1;								//Reset counter register (Active Low)
	
	//Define Assignments
	assign hSyncPulse = pulseReg;
	assign DE = de;
	//assign hCountReset_n = reset;
	
	always @( posedge(clock) )
	begin
		//If the end of the first line is reached, pulse the hsync
		if( hCounter == resHorizontal)
			begin
				//Pulse HSync
				pulseReg	= 1'b1;
				de			= 1'b0;
				//Reset the counter.
				hCounter 	= 0;
			end
		else
			begin
				//Keep HSync low
				pulseReg 	= 1'b0;
				de			= 1'b1;
				//Increment the counter.
				hCounter = hCounter + 1'b1;
				//reset = 1'b1;
			end
	end
	
endmodule