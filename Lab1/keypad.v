module keypad(valid, number, a, b, c, d, e, f, g);
   output 	valid;
   output [3:0] number;
   input 	a, b, c, d, e, f, g;

   wire o1_wire, o2_wire, o3_wire, a11_wire, a12_wire, o5_wire, o6_wire, o9_wire, a1_wire, a2_wire, a3_wire, a4_wire, a5_wire, a6_wire, a7_wire;

   or o1(o1_wire, a, c);
   or o2(o2_wire, d, e, f);
   or o3(o3_wire, o2_wire, g);
   and a11(a11_wire, o1_wire, o2_wire);
   and a12(a12_wire, b, o3_wire);
   or o4(valid, a11_wire, a12_wire);

   or o5(o5_wire, b, c);
   or o6(o6_wire, o1_wire, b);
   and a1(number[3], o5_wire, f);
   and a2(a2_wire, o6_wire, e);
   and a3(a3_wire, a, f);
   or o7(number[2], a2_wire, a3_wire);
   and a4(a4_wire, c, e);
   and a5(a5_wire, o5_wire, d);
   or o8(number[1], a5_wire, a4_wire, a3_wire);

   or o9(o9_wire, d, f);
   and a6(a6_wire, o1_wire, o9_wire);
   and a7(a7_wire, b, e);
   or o10(number[0], a6_wire, a7_wire);

endmodule // keypad
