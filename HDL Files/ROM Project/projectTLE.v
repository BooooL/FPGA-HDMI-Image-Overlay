//TLE for this project
//Combines ROM lookup table module and data write modules together

module projectTLE
(
	input 				clock,
	input 				key0, 			//Used to cycle through characters
	input 				key1, 			//Used to select the character
	output 	[23:0] 	dataOutput
);

	//Wire definitions
	wire [7:0] n1_romData;
	wire [11:0] n2_romAddress;

	lookupTLE lookupTLE_module
	(
		.clock(clock),
		.romAddress(n2_romAddress),
		.romData(n1_romData)
	);
	
	dataWrite dataWrite_module
	(
		.clock(clock),
		.key0(key0),
		.key1(key1),
		.romData(n1_romData),
		.dataOutput(dataOutput),
		.romAddress(n2_romAddress)
	);

endmodule