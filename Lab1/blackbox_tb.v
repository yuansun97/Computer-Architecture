module blackbox_test;

	reg h_in, f_in, g_in;                       // inputs of the circuit under test

	wire n_out;                                 // outputs of circuit under test

	blackbox blk1(n_out, h_in, f_in, g_in);     // the circuit under test

	initial begin

		$dumpfile("blackbox.vcd");
		$dumpvars(0,blackbox_test);

		h_in = 0; f_in = 0; g_in = 0; #10;
		h_in = 0; f_in = 0; g_in = 1; #10;
		h_in = 0; f_in = 1; g_in = 0; #10;
		h_in = 0; f_in = 1; g_in = 1; #10;
		h_in = 1; f_in = 0; g_in = 0; #10;
		h_in = 1; f_in = 0; g_in = 1; #10;
		h_in = 1; f_in = 1; g_in = 0; #10;
		h_in = 1; f_in = 1; g_in = 1; #10;

		$finish;
	end

	initial
		$monitor("At time %2t, h_in = %d f_in = %d g_in = %d n_out = %d",
					$time, h_in, f_in, g_in, n_out);

endmodule // blackbox_test
