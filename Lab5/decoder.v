// mips_decode: a decoder for MIPS arithmetic instructions
//
// alu_op       (output) - control signal to be sent to the ALU
// writeenable  (output) - should a new value be captured by the register file
// rd_src       (output) - should the destination register be rd (0) or rt (1)
// alu_src2     (output) - should the 2nd ALU source be a register (0) or an immediate (1)
// except       (output) - set to 1 when we don't recognize an opdcode & funct combination
// control_type (output) - 00 = fallthrough, 01 = branch_target, 10 = jump_target, 11 = jump_register 
// mem_read     (output) - the register value written is coming from the memory
// word_we      (output) - we're writing a word's worth of data
// byte_we      (output) - we're only writing a byte's worth of data
// byte_load    (output) - we're doing a byte load
// slt          (output) - the instruction is an slt
// lui          (output) - the instruction is a lui
// addm         (output) - the instruction is an addm
// opcode        (input) - the opcode field from the instruction
// funct         (input) - the function field from the instruction
// zero          (input) - from the ALU
//

// ALU op_code
`define ALU_ADD    3'h2 //  010
`define ALU_SUB    3'h3 //  011 
`define ALU_AND    3'h4 //  100
`define ALU_OR     3'h5 //  101
`define ALU_NOR    3'h6 //  110
`define ALU_XOR    3'h7 //  111

// MIPS arithmetic instructions 
// Opcodes and Function codes for R type (funct2 field; OP_OTHER0) 
`define OP0_R    6'h00

`define OP0_ADD     6'h20   // function code
`define OP0_SUB     6'h22
`define OP0_AND     6'h24
`define OP0_OR      6'h25
`define OP0_NOR     6'h27
`define OP0_XOR     6'h26
// Lab5 added operations
`define OP0_JR      6'h08   // jr  -- Jump Register
`define OP0_SLT     6'h2a   // slt -- Set Less Than
`define OP0_ADDM    6'h2c   // addm-- 

// Immediate opcodes (op field)
`define OP_ADDI     6'h08 // 00 1000
`define OP_ANDI     6'h0c // 00 1100
`define OP_ORI      6'h0d // 00 1101
`define OP_XORI     6'h0e // 00 1110
// Lab5 added operations
`define OP_BNE      6'h05   // bne -- Branch Not Equal
`define OP_BEQ      6'h04   // beq -- Branch Equal
`define OP_J        6'h02   // j   -- Jump
`define OP_LUI      6'h0f   // lui -- Load Upper Imm
`define OP_LW       6'h23   // lw  -- Load Word
`define OP_LBU      6'h24   // lbu -- Load Byte Unsigned
`define OP_SW       6'h2b   // sw  -- Store Word
`define OP_SB       6'h28   // sb  -- Store Byte



module mips_decode(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   opcode, funct, zero);
    output [2:0] alu_op;
    output       writeenable, rd_src, alu_src2, except;
    output [1:0] control_type;
    output       mem_read, word_we, byte_we, byte_load, slt, lui, addm;
    input  [5:0] opcode, funct;
    input        zero;

    wire ADD, ADDI, AND, ANDI, NOR, OR, ORI, SUB, validTypeI, validTypeR,
        XOR, XORI, JR, SLT, ADDM, BNE, BEQ, J, LUI, LW, LBU, SW, SB;

    // Valid R type operation inputs
    assign ADD = (opcode == `OP0_R) && (funct == `OP0_ADD);
    assign SUB = (opcode == `OP0_R) && (funct == `OP0_SUB);
    assign AND = (opcode == `OP0_R) && (funct == `OP0_AND);
    assign OR = (opcode == `OP0_R) && (funct == `OP0_OR);
    assign NOR = (opcode == `OP0_R) && (funct == `OP0_NOR);
    assign XOR = (opcode == `OP0_R) && (funct == `OP0_XOR);
    // Lab5 added R operations
    assign JR = (opcode == `OP0_R) && (funct == `OP0_JR);
    assign SLT = (opcode == `OP0_R) && (funct == `OP0_SLT);
    assign ADDM = (opcode == `OP0_R) && (funct == `OP0_ADDM);

    // Valid I type operation inputs
    assign ADDI = (opcode == `OP_ADDI);
    assign ANDI = (opcode == `OP_ANDI);
    assign ORI = (opcode == `OP_ORI);
    assign XORI = (opcode == `OP_XORI);
    //Lab5 added I operations
    assign BNE = (opcode == `OP_BNE);
    assign BEQ = (opcode == `OP_BEQ);
    assign J = (opcode == `OP_J);
    assign LUI = (opcode == `OP_LUI);
    assign LW = (opcode == `OP_LW);
    assign LBU = (opcode == `OP_LBU);
    assign SW = (opcode == `OP_SW);
    assign SB = (opcode == `OP_SB);

    assign validTypeR = ADD | SUB | AND | OR | NOR | XOR
        | JR | SLT | ADDM;
    assign validTypeI = ADDI | ANDI | ORI | XORI
        | BNE | BEQ | J | LUI | LW | LBU | SW | SB;

    assign except = ~(validTypeR | validTypeI);

    assign alu_op[2] = AND | ANDI | OR | ORI | NOR | XOR | XORI;
    assign alu_op[1] = ADD | SUB | NOR | XOR | ADDI | XORI | BEQ | BNE | JR | SLT | LW | LBU | SW | SB;
    assign alu_op[0] = SUB | OR | XOR | ORI | XORI | BEQ | BNE | JR | SLT;
     
    assign rd_src = ADDI | ANDI | ORI | XORI | LUI | LW | LBU;
    assign writeenable = ADD | SUB | AND | OR | NOR | XOR | ADDI | ANDI | ORI | XORI | LUI | SLT | LW | LBU | ADDM;
    assign alu_src2 = ADDI | ANDI | ORI | XORI | LW | LBU | SW | SB;

    assign control_type[1] = JR | J;
    assign control_type[0] = (BEQ & zero) | (BNE & ~zero) | JR; 
   
    assign mem_read = LW | LBU;
    assign word_we = SW;
    assign byte_we = SB;
    assign byte_load = LBU;

    assign lui = LUI;
    assign slt = SLT;
    assign addm = ADDM;
    

endmodule // mips_decode
