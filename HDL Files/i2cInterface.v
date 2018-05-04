//Verilog i2c interface
//Copyright (C) 2018 Alexander Knapik & Keane-Gene Yew
//under the GNU General Public License v3.0 or any later version
//05.04.2018

module i2cInterface 

//Parameters used for passing variables

#( 
	parameter data			= 2'hFF,	//Data used for communcations
	parameter slaveAddress	= 2'hFF,	//Address used for the I2C slave
	parameter dataAddress	= 2'hFF 	//Address used for writing to a particular register
)

(
	input i2cStart,		//Input to start communications
	input reset_n,		//Active low reset
	inout SCL,			//I2C input communications reference clock. 400kHz
	inout SDA			//I2C input data for communcations.
);

	localparam busWidth		= 8;		//Local parameter holding the busWidth of communications.
	
	
	
endmodule