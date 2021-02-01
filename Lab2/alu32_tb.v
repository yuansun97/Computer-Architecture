//implement a test bench for your 32-bit ALU
module alu32_test;
    reg [31:0] A = 0, B = 0;
    reg [2:0] control = 0;

    initial begin
        $dumpfile("alu32.vcd");
        $dumpvars(0, alu32_test);

             A = 8;          B = 4;          control = `ALU_ADD; // try adding 8 and 4
        # 10 A = 0;          B = 257;        control = `ALU_ADD;
        # 10 A = 'hfffffffe; B = 3;          control = `ALU_ADD; 
        # 10 A = 'h7fffffff; B = 2;          control = `ALU_ADD;
        # 10 A = 'hf0000000; B = 'h80000000; control = `ALU_ADD;
        # 10 A = 2;          B = 5;          control = `ALU_SUB; // try subtracting 5 from 2
        # 10 A = 7;          B = 7;          control = `ALU_SUB;
        # 10 A = 3;          B = 'h7ffffff0; control = `ALU_SUB;
        # 10 A = 7;          B = 'h80000000; control = `ALU_SUB;
        # 10 A = 17;         B = 356;        control = `ALU_AND;
        # 10 A = 17;         B = 356;        control = `ALU_OR;
        # 10 A = 17;         B = 356;        control = `ALU_NOR;
        # 10 A = 17;         B = 356;        control = `ALU_XOR;
        
        // add more test cases here!

        # 10 $finish;
    end

    wire [31:0] out;
    wire overflow, zero, negative;
    alu32 a(out, overflow, zero, negative, A, B, control);  
endmodule // alu32_test
