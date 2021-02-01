// mips_decode: a decoder for MIPS arithmetic instructions
//
// alu_src2    (output) - should the 2nd ALU source be a register (0) or an immediate (1)
// rd_src      (output) - should the destination register be rd (0) or rt (1)
// writeenable (output) - should a new value be captured by the register file
// alu_op      (output) - control signal to be sent to the ALU
// except      (output) - set to 1 when the opcode/funct combination is unrecognized
// opcode      (input)  - the opcode field from the instruction
// funct       (input)  - the function field from the instruction
//
                        // op /funct
`define ALU_ADD    3'h2 //  010
`define ALU_SUB    3'h3 //  011 
`define ALU_AND    3'h4 //  100
`define ALU_OR     3'h5 //  101
`define ALU_NOR    3'h6
`define ALU_XOR    3'h7
  
// Opcodes and Function codes for R type (funct2 field; OP_OTHER0) 
`define OP0_R    6'h00

`define OP0_ADD     6'h20
`define OP0_SUB     6'h22
`define OP0_AND     6'h24
`define OP0_OR      6'h25
`define OP0_NOR     6'h27
`define OP0_XOR     6'h26

// Immediate opcodes (op field)
`define OP_ADDI     6'h08 // 00 1000
`define OP_ANDI     6'h0c // 00 1100
`define OP_ORI      6'h0d // 00 1101
`define OP_XORI     6'h0e // 00 1110

module mips_decode(alu_src2, rd_src, writeenable, alu_op, except, opcode, funct);
    output       alu_src2, rd_src, writeenable, except;
    output [2:0] alu_op;
    input  [5:0] opcode, funct;

    wire validADD, validADDI, validAND, validANDI, validNOR, validOR, validORI, validSUB, validTypeI, validTypeR,
        validXOR, validXORI;

    // Valid R type operation inputs
    assign validADD = (opcode == `OP0_R) && (funct == `OP0_ADD);
    assign validSUB = (opcode == `OP0_R) && (funct == `OP0_SUB);
    assign validAND = (opcode == `OP0_R) && (funct == `OP0_AND);
    assign validOR = (opcode == `OP0_R) && (funct == `OP0_OR);
    assign validNOR = (opcode == `OP0_R) && (funct == `OP0_NOR);
    assign validXOR = (opcode == `OP0_R) && (funct == `OP0_XOR);

    // Valid I type operation inputs
    assign validADDI = (opcode == `OP_ADDI);
    assign validANDI = (opcode == `OP_ANDI);
    assign validORI = (opcode == `OP_ORI);
    assign validXORI = (opcode == `OP_XORI);

    assign validTypeR = validADD || validSUB || validAND || validOR || validNOR || validXOR;
    assign validTypeI = validADDI || validANDI || validORI || validXORI;

    assign except = ~(validTypeR || validTypeI);
    assign alu_src2 = validTypeI;
    assign rd_src = validTypeI;
    assign writeenable = ~except;

    assign alu_op[0] = ~except & (validSUB | validOR | validXOR | validORI | validXORI);
    assign alu_op[1] = ~except & (validADD | validSUB | validNOR | validXOR | validADDI | validXORI);
    assign alu_op[2] = ~except & (validAND | validANDI | validOR | validORI | validNOR | validXOR | validXORI);


endmodule // mips_decode
