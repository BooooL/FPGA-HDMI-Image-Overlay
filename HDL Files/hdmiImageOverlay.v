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
	
	output DE,				//Data enable
	output VSYNC,			//Vertical sync
	output HSYNC,			//Horizontal sync
	output [23:0] data, 	//RGB Data output bus
	inout i2cSda,			//SDA Output of the i2c Controller
	output i2cScl			//SCL Output of the i2c Controller
);
	
	//Define resolution. Default 1920x1080.
	parameter hPixels = 720;	//Horizontal pixel length
	parameter vPixels = 1280;	//Vertical pixel length
	
	//Refresh rate
	parameter refreshRate = 30;	//Refresh rate. Default 30 frames a second.
	
	//Clock generator used for the pixel clock
	parameter inputSpeed		=	50 * ( 10 ** 6 ); //Input reference clock speed in Hz.
	parameter outputSpeed	=	hPixels * vPixels * refreshRate;	//Pixel clock speed
	wire pixelClock;
	clockGen #( inputSpeed, outputSpeed, 1 )
	pixelClockGen
	(
		.clockIn		( clock_50 		),
		.clockOut	( pixelClock 	)
	);
	
	//Define the bus widths used for counting the horizontal and vertical pixels.
	//12 bits is 4096 x 4096 maximum.
	//11 bits is 2048 x 2048 maximum.
	parameter hCountWidth = 12;
	parameter vCountWidth = 12;
	
	//Registers used for storing the pixel count
	wire [ ( hCountWidth - 1 ) : 0 ] hCount;	//Horizontal pixel counter
	wire [ ( vCountWidth - 1 ) : 0 ] vCount;	//Vertical pixel counter	
	
	//Registers used for resetting the horizontal and vertical counters.
	//reg hReset_n = 1'b0;
	//reg vReset_n = 1'b0;

	//Register Definitions
	//reg [23:0] dataReg; //Create 24 bit data register

	//Register Assignments
	//assign data = dataReg; //Assign data register to data output
	
	//Horizontal pixel counter, hCountWidth bits long.
	counter #( hCountWidth )
	hCounter
	(
		.clock				( pixelClock ),	//Clock input clock
		.D					( 1'b0 ),		//Set the data input to 0 always. No preloading of the counter.
		.parallelEnable_n 	( 1'b1 ),		//Disable the parallel loading ability!!!
		.countEnable		( 1'b1 ),		//Always have the counting ability enabled.
		//.masterReset_n		( hReset_n ),	//Reset the counter, active low.
		.masterReset_n		( 1'b1 ),	//Reset the counter, active low.
		.Q					( hCount )		//The horizontal counter value.
	);
	
	//Vertical pixel counter, vCountWidth bits long.
	counter #( vCountWidth )
	vCounter
	(
		.clock				( pixelClock ),	//Clock input clock
		.D					( 1'b0 ),		//Set the data input to 0 always. No preloading of the counter.
		.parallelEnable_n 	( 1'b1 ),		//Disable the parallel loading ability!!!
		.countEnable		( 1'b1 ),		//Always have the counting ability enabled.
		//.masterReset_n		( vReset_n ),	//Reset the counter, active low.
		.masterReset_n		( 1'b1 ),	//Reset the counter, active low.
		.Q					( vCount )		//The vertical counter value.
	);
	
	//Horizontal sync module
	hsync #( hCountWidth, hPixels )
	hSync
	(
		//.resHorizontal	( hPixels ),	//1920 pixels wide
		.counterVal			( hCount ),		//Send horizontal counter value to the hsync counterVal
		.clock 				( pixelClock ),	//Clock input clock
		.hSyncPulse 		( HSYNC )		//hSync pulse goes to HSYNC output, which is tied to a pin
		//.hCountReset_n 		( hReset_n )	//Maps the hSync counter reset to hReset_n register
		//.hCountReset_n 		( 1'b1 )	//Maps the hSync counter reset to hReset_n register
	);

	//Vertical sync module
	vsync #( vCountWidth, vPixels )
	vSync
	(
		//.resVertical 		( vPixels ),	//1080 pixels wide
		.counterVal 		( vCount ),		//Send vertical counter value to the vsync counterVal
		.clock 				( pixelClock ),	//Clock input clock
		.vSyncPulse 		( VSYNC )		//vSync pulse goes to VSYNC output, which is tied to a pin
		//.vCountReset_n 		( vReset_n )	//Maps the vSync counter reset to vReset_n register
		//.vCountReset_n 		( 1'b1 )	//Maps the vSync counter reset to vReset_n register
	);

	DE #( hCountWidth, hPixels, vPixels )
	de_module
	(
		.clock 				( pixelClock ), 	//Input clock
		//.resHorizontal		( hPixels ),	//Horizontal pixel count (1920)
		.hCount 			( hCount ), 	//Horizontal pixel counter
		//.resVertical 		( vPixels ),	//Vertical pixel count (1080)
		.vCount 			( vCount ), 	//Vertical pixel counter
		.deOut 				( DE )			//DE signal output
	);

	dataWrite dataWrite_module
	(
		.clock 				( pixelClock ), 	//Input clock
		//.dataOutput 		( dataReg ) 	//Data output
		.dataOutput 		( data 	) 	//Data output
	);
	
	wire i2cReady;			//Wire telling the ROM that the i2c state machine is idle, waiting for a new input.
	wire i2cWrite;			//Wire telling the i2c state machine to start
	wire [23:0] i2cData;	//Wire holding connecting a line of the i2c ROM to the state machine.
	
	//I2C configuration ROM Table
	i2cRegisterConfigure
	i2cROM (
		.i2cReady			( i2cReady 	),
		.writeOutput		( i2cWrite 	),
		.dataOut			( i2cData 	)
	);
	
	//The controller handling the i2c transfer of data.
	i2cInterface
	i2c (
		.refClock			( clock_50 	),
		.dataIn				( i2cData	),
		.i2cGo				( i2cWrite	),
		//.reset_n			( 1'b1 		),
		.sda				( i2cSda	),
		.scl				( i2cScl	),
		.i2cComplete		( i2cReady	)
	);
		
endmodule