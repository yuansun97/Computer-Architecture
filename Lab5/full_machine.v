// full_machine: execute a series of MIPS instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock   (input) - the clock signal
// reset   (input) - set to 1 to set all registers to zero, set to 0 for normal execution.

// ALU op_code
`define ALU_ADD    3'h2 //  010
`define ALU_SUB    3'h3 //  011 

module full_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst;  
    wire [31:0] PC;  

    wire [31:0] nextPC, PC_plus_four, Branch_addr, branch_offset, J_addres,
            rsData, rtData, rdData, ALU_B_src, pre_rdData, aluOut0, aluOut1,
            ExtImm, SignExtImm, ZeroExtImm,
            memOut0, memAddr, memData, addmData, mem_plus_rt, selectedByte;
    wire [4:0] rsNum, rtNum, rdNum, W_addr;
    wire [5:0] opcode, funct;
    wire [2:0] alu_op;
    wire [1:0] control_type;

    wire alu_src2, rd_src, writeenable, zero, mem_read, word_we, byte_we, 
            byte_load, slt, lui, addm, negative;


    assign branch_offset = ExtImm << 2;
    assign J_addres = {PC[31:28], inst[25:0], 2'h0};
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
    register #(32) PC_reg(PC, nextPC, clock, 1'h1, reset);

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
    regfile rf (rsData, rtData, rsNum, rtNum, W_addr, addmData, writeenable, clock, reset);




    /* add other modules */
    /*module mips_decode(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   opcode, funct, zero);
                   */
    mips_decode MIPS_decoder(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   opcode, funct, zero);

    //module data_mem(data_out, addr, data_in, word_we, byte_we, clk, reset);
    data_mem dm(memOut0, memAddr, rtData, word_we, byte_we, clock, reset);


    // module alu32(out, overflow, zero, negative, inA, inB, control);
    alu32 pc_plus4(PC_plus_four, , , , PC, 32'h4, `ALU_ADD);
    alu32 pc_plus_offset(Branch_addr, , , , PC_plus_four, branch_offset, `ALU_ADD);
    alu32 ALU_compute(aluOut0, , zero, negative,rsData, ALU_B_src, alu_op);
    alu32 addm_plus(mem_plus_rt, , , , memOut0, rtData, `ALU_ADD);

    //module mux4v(out, A, B, C, D, sel);
    // Multiplexer choosing control_type
    mux4v #(32) pc_control(nextPC, PC_plus_four, Branch_addr, J_addres, rsData, control_type);
    // Multiplexer choosing rd/rt address
    mux2v #(5) rd_rt_addr(W_addr, rdNum, rtNum, rd_src);
    // Multiplexer choosing R[rs]/aluOut0
    mux2v #(32) mux_addm_addr(memAddr, aluOut0, rsData, addm);
    // Multiplexer choosing LUI/pre_rdData
    mux2v #(32) mux_lui(rdData, pre_rdData, {inst[15:0], 16'h0}, lui);
    // Multiplexer choosing ADDM/other
    mux2v #(32) mux_addm_res(addmData, rdData, mem_plus_rt, addm);
    // Multiplexer shoosing extend "1" or extend "0" after Sign Extender.
    mux2v #(32) sign_extender(ExtImm, SignExtImm, ZeroExtImm, alu_op[2]);
    // Multiplexer choosing rtData/ExtImm
    mux2v #(32) mux_ALU_src2(ALU_B_src, rtData, ExtImm, alu_src2);
    // Multiplexer choosing outData/negative
    mux2v #(32) mux_ALU_slt(aluOut1, aluOut0, {31'h0, negative}, slt);
    // Multiplexer choosing ALU_out/memData
    mux2v #(32) mux_mem_read(pre_rdData, aluOut1, memData, mem_read);
    // Multiplexer choosing byte
    mux4v #(32) mux_sel_byte(selectedByte, {24'h0, memOut0[7:0]}, {24'h0, memOut0[15:8]}, {24'h0, memOut0[23:16]}, {24'h0, memOut0[31:24]}, aluOut0[1:0]);
    // Multiplexer choosing word/byte
    mux2v #(32) mux_byte_load(memData, memOut0, selectedByte, byte_load);
    


endmodule // full_machine
