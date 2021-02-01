module decoder_test;
    reg [5:0] opcode, funct;

    initial begin
        $dumpfile("decoder.vcd");
        $dumpvars(0, decoder_test);

        // Test R-type operations
             opcode = `OP_OTHER0; funct = `OP0_ADD; // try addition
        # 10 opcode = `OP_OTHER0; funct = `OP0_SUB; // try subtraction
        # 10 opcode = `OP_OTHER0; funct = `OP0_AND; // try and
        # 10 opcode = `OP_OTHER0; funct = `OP0_OR;  // try or
        # 10 opcode = `OP_OTHER0; funct = `OP0_NOR; // try nor
        # 10 opcode = `OP_OTHER0; funct = `OP0_XOR; // try xor
        # 10 opcode = `OP_OTHER0; funct = 6'h21;    // try except
        
        // Test I-type operations
        # 10 opcode = `OP_ADDI;
        # 10 opcode = `OP_ANDI;
        # 10 opcode = `OP_ORI;
        # 10 opcode = `OP_XORI;
        # 10 opcode = 6'h09;

        # 10 $finish;
    end

    // use gtkwave to test correctness
    wire [2:0] alu_op;
    wire       alu_src2, rd_src, writeenable, except;
    mips_decode decoder(alu_src2, rd_src, writeenable, alu_op, except,
                        opcode, funct);
endmodule // decoder_test
