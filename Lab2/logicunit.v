// 00 -> AND, 01 -> OR, 10 -> NOR, 11 -> XOR
module logicunit(out, A, B, control);
    output      out;
    input       A, B;
    input [1:0] control;
    wire and_out, or_out, nor_out, xor_out;

    and a1(and_out, A, B);
    or o1(or_out, A, B);
    nor no1(nor_out, A, B);
    xor xo1(xor_out, A, B);

    mux4 mux4_1(out, and_out, or_out, nor_out, xor_out, control);

endmodule // logicunit
