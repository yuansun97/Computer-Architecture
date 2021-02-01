
module arraySortCheck_control(sorted, done, load_input, load_index, select_index, go, inversion_found, end_of_array, clock, reset);
	output sorted, done, load_input, load_index, select_index;
	input go, inversion_found, end_of_array;
	input clock, reset;

	// 7 states----------------------------------------------------------------------
	wire wait_state, hold_for_begin, judge_end, judge_inversion, plusplus, end_unsorted, end_sorted;
	// 7 states----------------------------------------------------------------------
	wire hold_for_begin_next = ((~reset) && go && wait_state) || ((~reset) && go && hold_for_begin);
	wire wait_state_next = (wait_state && ~go || reset) || ((~reset) && go && end_sorted) || ((~reset) && go && end_unsorted);
	wire judge_end_next = ((~reset) && ~go && hold_for_begin)/*((~reset) && go && wait_state)*/ || ((~reset) && plusplus);
	wire plusplus_next = (~reset) && judge_inversion && ~inversion_found;
	wire end_unsorted_next = ((~reset) && judge_inversion && inversion_found) || ((~reset) && ~go && end_unsorted );
	wire judge_inversion_next = (~reset) && judge_end && ~end_of_array;
	wire end_sorted_next = ((~reset) && judge_end && end_of_array) || ((~reset) && ~go && end_sorted);
	//------------transition function------------------------------------------------
	dffe hold_for_begin_1(hold_for_begin,hold_for_begin_next, clock, 1'b1, 1'b0);
	dffe wait_state_1(wait_state, wait_state_next, clock, 1'b1, 1'b0);
	dffe judge_end_1(judge_end, judge_end_next, clock, 1'b1, 1'b0); 
	dffe plusplus_1(plusplus, plusplus_next, clock, 1'b1, 1'b0);
	dffe end_unsorted_1(end_unsorted, end_unsorted_next, clock, 1'b1, 1'b0);
	dffe judge_inversion_1(judge_inversion, judge_inversion_next, clock, 1'b1, 1'b0);
	dffe end_sorted_1(end_sorted, end_sorted_next, clock, 1'b1, 1'b0);
	//state expression && output-----------------------------------------------------
	assign sorted = end_sorted;                                //
	assign done = end_sorted || end_unsorted;                  //
	assign load_input = wait_state;                            //
	assign load_index = judge_inversion || wait_state;         //
	assign select_index = ~wait_state;                         //

endmodule
