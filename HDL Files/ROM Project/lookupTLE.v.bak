//lookup table TLE

module lookupTLE
(
	input  [10:0] 	romAddress, 	// 11‐bit ROM address
	input 			clock, 			//50MHz Reference Clock.
	output [7:0] 	romData 			// 8‐bit ROM data output
);

	// Create an instance of the ROM IP Block.
	lookupTable2 romLookup 
	(
		.address (romAddress), 	// Address Bus (latched)
		.clock 	(clock), 		// System Clock
		.q			(romData) 		// Output data (latched).
	);

endmodule