// arith_machine: execute a series of arithmetic instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock  (input)  - the clock signal
// reset  (input)  - set to 1 to set all registers to zero, set to 0 for normal execution.

`define ALU_ADD    3'h2 // 0  / 0x20

`define ONE 1'h1



module arith_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst;  
    wire [31:0] PC;  
    wire [31:0] rsData;
    wire [31:0] rtData;
    wire [31:0] rdData;
    wire [31:0] B_final;
    wire [31:0] SignExtImm, ZeroExtImm, ExtImm;
    wire [4:0] rsNum;
    wire [4:0] rtNum;
    wire [4:0] rdNum;
    wire [5:0] opcode;
    wire [5:0] funct;
    wire [2:0] alu_op;
    wire [31:0] nextPC;
    wire [4:0] W_addr;

    wire UNUSED;
    
    wire alu_src2, rd_src, writeenable;

    assign SignExtImm = {{16{inst[15]}}, inst[15:0]};
    assign ZeroExtImm = {16'h0, inst[15:0]};
    
    assign rsNum = inst[25:21];
    assign rtNum = inst[20:16];
    assign rdNum = inst[15:11];
    assign opcode = inst[31:26];
    assign funct = inst[5:0];

    // DO NOT comment out or rename this module
    // or the test bench will break
    // module register(q, d, clock, enable, reset);
    register #(32) PC_reg(PC, nextPC, clock, `ONE, reset);

    // DO NOT comment out or rename this module
    // or the test bench will break
    // module instruction_memory(data, addr);
    instruction_memory im(inst, PC[31:2]);


    // DO NOT comment out or rename this module
    // or the test bench will break
    /* module regfile (rsData, rtData,
                rsNum, rtNum, rdNum, rdData, 
                rdWriteEnable, clock, reset);
    */
    regfile rf (rsData, rtData, rsNum, rtNum, W_addr, rdData, writeenable, clock, reset);


    /* add other modules */

    // ALU pc plus4
    // module alu32(out, overflow, zero, negative, inA, inB, control);
    alu32 pcplus4(nextPC, , , , PC, 32'h4, `ALU_ADD);

    // Instruction decoder
    // module mips_decode(alu_src2, rd_src, writeenable, alu_op, except, opcode, funct);
    mips_decode Instr_decoder(alu_src2, rd_src, writeenable, alu_op, except, opcode, funct);

    // Multiplexer shoosing extend "1" or extend "0" after Sign Extender.
    mux2v #(32) sign_extender(ExtImm, SignExtImm, ZeroExtImm, alu_op[2]);

    // Multiplexer choosing rd/rt address
    // module mux2v(out, A, B, sel);
    mux2v #(5) rd_rt_addr(W_addr, rdNum, rtNum, rd_src);

    // Multiplexer choosing rtData/imm_signed 
    mux2v #(32) rt_imm_signed_data(B_final, rtData, ExtImm, alu_src2);

    // ALU final compute
    alu32 #(32) alu_final(rdData, , , ,rsData, B_final, alu_op);
   
endmodule // arith_machine
