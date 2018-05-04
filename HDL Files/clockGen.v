//Timer to slow down the 50Mhz reference clock down to 1hz.
//Copyright (c) 2018 Alexander Knapik under the GNU General Public License v3.0 or any other later version
//20.04.2018

/*
    This file is part of Alexander Knapik's Home Alarm Student Project.

    Alexander Knapik's Home Alarm Student Project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Alexander Knapik's Home Alarm Student Project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Alexander Knapik's Home Alarm Student Project.  If not, see <http://www.gnu.org/licenses/>.
	 
	 If you modify this Program, or any covered work, by linking or combining it with singlePLL 
	 (or a modified version of that library), containing parts covered by the terms of 
	 Altera Corporation, the licensors of this Program grant you 
	 additional permission to convey the resulting work.
*/

//Timescale for simulation.
//Time step: 10ms
//with 1ns resolution.
`timescale 100ns/100ns

module clockGen

	//Redfinable parameters when instantiated, used for setting input and output clock speeds. 
#(	
	parameter inputSpeed = 5000000,	//Input reference clock
	parameter outputSpeed = 1, 	//Output clock speed in Hz.
	parameter busWidth = 26		//Define the bit width based on the clockSpeed. 

)						
(
	//Define inputs
	input clockIn,	//Input clock. Speed defined in inputSpeed
	
	//Don't gate the clock! - Glenn Matthews
	//input enable,	//Enable timer to start counting (active high). If low, freeze the count value.
	//input reset_n,//Synchronous master reset (active low)
	
	output clockOut//Output clock. Speed defined in outputSpeed
	
);
	
	localparam [ ( busWidth - 1 ) : 0 ] clockSpeed = ( 0.5 * ( inputSpeed / outputSpeed ) );	//Value used for maths in the code based on the two clock speeds.
																															//Half due to the count value inverting at half the period. 
	//localparm clockSpeed	= 20; 																				//Debug value
	
	//parameter busWidth = 21; //debug value for modelSim
	
	reg [ ( busWidth - 1 ) : 0 ] count = 1'b0;	//Define counter register used to store the value for counting
	//initial count = 1'b0;					//Initial value for simulation only. (Non synthesisable).
	reg clk = 1'b0;										//Define register for assigning clockOut to 
	
	assign clockOut = clk;

	//Always block for counting
	//Sensitivity list
	always @( posedge( clockIn ) ) //Synchronous action only on a clock edge. 
		begin
		
			/*		
			//If reset_n is low, set the count value back to zero.
			if( reset_n == 1'b0 )
				begin
					count <= 1'b0;		//Reset count value
				end	
			
			//If enable is low, freeze the count value.
			if ( enable == 1'b0 )
				begin
					count <= count;	//Keep count value the same.
				end
			*/
			
			//If the count has reached the desired value, inverse the clock and reset the count
			if ( ( count == clockSpeed ) )
				begin
					clk <= ~clk;		//Invert the clock
					count <= 1'b0;		//Reset the count value.
				end

			//Else increment the count variable
			else
				begin
					count <= count + 1'b1;
				end
				
		end //Always
		
endmodule