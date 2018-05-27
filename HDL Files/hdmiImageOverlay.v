//Overlay an image stored in DDR to be transmitted via HDMI

//Copyright (C) 2018 by Alexander Knapik and Keane-Gene Yew
//under the GNU General Public License v3.0 or any later version.
//03.05.2018

/*
    This file is part of FPGA-HDMI-Image-Overlay by Alexander Knapik and Keane-Gene Yew.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    this program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

//Real world inputs and outputs
module hdmiImageOverlay (
	input clock_50,	//50Mhz FPGA clock
	input key0,		//Push button. This is automatically latched by the DE-10 Nano development board.
	input key1,		//Push button. This is automatically latched by the DE-10 Nano development board.
	input [3:0] sw,	//4 Slide switches
	
	output DE,		//Data enable
	output VSYNC,	//Vertical sync
	output HSYNC	//Horizontal sync
);
	
	//Define resolution. Default 1280x720
	parameter hPixels = 1280;	//Horizontal pixel length
	parameter vPixels = 720;		//Vertical pixel length
	
	//Refresh rate
	parameter refreshRate = 30;	//Refresh rate. Default 30 frames a second.
	
	//Define the bus widths used for counting the horizontal and vertical pixels.
	//12 bits is 4096 x 4096 maximum.
	parameter hBusWidth = 12;
	parameter vBusWidth = 12;
	
	//Registers used for storing the pixel count
	reg [ ( hBusWidth - 1 ) : 0 ] hCount = 0;	//Horizontal pixel count
	reg [ ( vBusWidth - 1 ) : 0 ] vCount = 0;	//Vertical pixel count	
	
	//Registers used for resetting the horizontal and vertical counters.
	reg hReset_n = 1'b0;
	reg vReset_n = 1'b0;
	
	//Horizontal pixel counter, hBusWidth bits long.
	counter #( hBusWidth )
	(
		.clock				( clock_50 ),	//Clock input clock
		.D					( 1'b0 ),		//Set the data input to 0 always. No preloading of the counter.
		.parallelEnable_n 	( 1'b1 ),		//Disable the parallel loading ability!!!
		.countEnable		( 1'b1 ),		//Always have the counting ability enabled.
		.masterReset_n		( 1'b0 ),		//Reset the counter, active low.
		.Q					( hCount )		//The horizontal counter value.
	);
	
	//Vertical pixel counter, vBusWidth bits long.
	counter #( hBusWidth )
	(
		.clock				( clock_50 ),	//Clock input clock
		.D					( 1'b0 ),		//Set the data input to 0 always. No preloading of the counter.
		.parallelEnable_n 	( 1'b1 ),		//Disable the parallel loading ability!!!
		.countEnable		( 1'b1 ),		//Always have the counting ability enabled.
		.masterReset_n		( 1'b0 ),		//Reset the counter, active low.
		.Q					( vCount )		//The vertical counter value.
	);
	
	
		
	
endmodule