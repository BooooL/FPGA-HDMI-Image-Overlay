//Variable bit length synchronous counter.
//Copyright (c) 2018 Alexander Knapik under the GNU General Public License v3.0 or any other later version
//19.04.2018

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

//Scale for simulation.
//Time step: 10ns
//with 1ns resolution.

//Variable bit wide counter.
module counter

//Bus width bit length
#( parameter busWidth = 4 ) //Redefinable parameter to make the whole counter x bits wide.
(

	//Define inputs
	input clock,								//Reference clock
	input [ ( busWidth - 1 ) : 0 ] D,	//Synchronous Parallel load value (active high).
													//Has precedence over enable
	input masterReset_n,						//Synchronous Master reset (active low)
	input countEnable,						//Counter enable
	input parallelEnable_n,					//Parallel load enable. Stops counting action (active low). 
	
	//Define outputs
	output [ ( busWidth - 1 ) : 0 ] Q,	//Current clock output array.
	output terminalCount						//An output going high once the counter has reached the maximum value.

);

	//Define register for the output
	reg [ ( busWidth - 1 ) : 0 ] counterValue;
	
	//Assign outputs
	assign Q 				= counterValue; 		//Q is the counterValue
	assign terminalCount = &( counterValue );	//termincalCount is when counterValue is max value.
	
	//Always block
	//All synchronous logic
	always @( posedge( clock ), negedge( masterReset_n ) )
		begin	
				
			//If masterReset_n is low, set the counterValue to zero.
			if ( masterReset_n == 1'b0 )
				begin	
					counterValue <= 0;
				end
				
			//if parallelEnable_n is high, set the output Q to the parallel load value.
			else if ( parallelEnable_n == 1'b0 )
				begin
					counterValue  <=  D;
				end
				
			//If countEnable is high, start counting
			else if ( countEnable == 1'b1 )
				begin
					
					//If counter has reached the max value, the output should equal the inverse of the preset_n value
					if( ( counterValue == ( 2**( busWidth ) - 1 ) ) ) //** is power of. 
						begin
							counterValue <= 0;
						end
											
					//Else increase the count value
					else
						begin
							counterValue <= counterValue + 1'b1;
						end
			
				end //Else if countEnable == 1'b1
				
			//Default condition, keep the output the same.
			else 
				begin
					counterValue <= counterValue;
				end
				
				
	end //Always
	

endmodule //counter