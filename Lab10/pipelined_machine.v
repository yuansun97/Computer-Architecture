module pipelined_machine(clk, reset);
    input        clk, reset;

    wire [31:0]  PC;
    wire [31:2]  next_PC, PC_plus4, PC_target;
    wire [31:0]  inst;

// Altered
    // wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
    // wire [4:0]   rs = inst[25:21];
    // wire [4:0]   rt = inst[20:16];
    // wire [4:0]   rd = inst[15:11];
    // wire [5:0]   opcode = inst[31:26];
    // wire [5:0]   funct = inst[5:0];

    wire [4:0]   wr_regnum;
    wire [2:0]   ALUOp;

    wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst;
    wire         PCSrc, zero;
    wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

// Adding code ---------------------------------
// (a) Implement pipeline regs.
    wire [31:0] inst_DE;
    wire Stall, Flush;
    // Pipe reg1 output for DE stage
    wire [31:0]  imm = {{ 16{inst_DE[15]} }, inst_DE[15:0] };  // sign-extended immediate
    wire [4:0]   rs = inst_DE[25:21];
    wire [4:0]   rt = inst_DE[20:16];
    wire [4:0]   rd = inst_DE[15:11];
    wire [5:0]   opcode = inst_DE[31:26];
    wire [5:0]   funct = inst_DE[5:0];
    wire [29:0]  PC_plus4_DE;
    // module register(q, d, clk, enable, reset)
    register #(32) IF_DE_reg1(inst_DE, inst, clk, ~Stall, (Flush | reset));
    register #(30) PC_plus4_reg(PC_plus4_DE, PC_plus4, clk, ~Stall, (Flush | reset));

    // Pipe reg2 output for MW stage
    wire RegWrite_MW, MemRead_MW, MemWrite_MW, MemToReg_MW;
    wire [4:0]  wr_regnum_MW;
    wire [31:0] alu_out_data_MW, rd2_data_MW;
    wire [31:0] rd1_data_forward, rd2_data_forward;
    // module register(q, d, clk, enable, reset)
    register #(1) MW_reg1(RegWrite_MW, RegWrite, clk, /* enable */1'b1, reset);
    register #(1) MW_reg2(MemRead_MW, MemRead, clk, /* enable */1'b1, reset);
    register #(1) MW_reg3(MemWrite_MW, MemWrite, clk, /* enable */1'b1, reset);
    register #(1) MW_reg4(MemToReg_MW, MemToReg, clk, /* enable */1'b1, reset);
    register #(5) MW_reg5(wr_regnum_MW, wr_regnum, clk, /* enable */1'b1, reset);
    register #(32) MW_reg6(alu_out_data_MW, alu_out_data, clk, /* enable */1'b1, reset);
    register #(32) MW_reg7(rd2_data_MW, rd2_data_forward, clk, /* enable */1'b1, reset);

// (b) Implement forwarding.
    // Forwarding Unit
    // input:   rt, rs, wr_regnum_MW, RegWrite_MW
    // output:  ForwardA, ForwardB
    wire ForwardA, ForwardB;
    assign ForwardA = (rs == wr_regnum_MW) && RegWrite_MW && ~(rs == 5'h0);
    assign ForwardB = (rt == wr_regnum_MW) && RegWrite_MW && ~(rt == 5'h0);
    // module mux2v(out, A, B, sel);
    mux2v #(32) forward_A_mux(rd1_data_forward, rd1_data, alu_out_data_MW, ForwardA);
    mux2v #(32) forward_B_mux(rd2_data_forward, rd2_data, alu_out_data_MW, ForwardB);

// (c) Implement stalling.
    // Hazard Unit
    // input: rs, rt, wr_regnum_MW, MemRead_MW, wr_regnum
    // output: Stall
    assign Stall = ((rs == wr_regnum_MW) || ((rt == wr_regnum_MW) && (rt != wr_regnum))) 
                    && RegWrite_MW && MemRead_MW && (wr_regnum_MW != 5'h0);

// (d) Implement flushing.
    assign Flush = PCSrc;

// (e) Implement final. 


//----------------------------------------------

    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, ~Stall, reset);

    assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
    adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
    adder30 target_PC_adder(PC_target, PC_plus4_DE, imm[29:0]);
    mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
    assign PCSrc = BEQ & zero;

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory imem(inst, PC[31:2]);

    mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst,
                      opcode, funct);

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum_MW, wr_data,
               RegWrite_MW, clk, reset);

    mux2v #(32) imm_mux(B_data, rd2_data_forward, imm, ALUSrc);
    alu32 alu(alu_out_data, zero, ALUOp, rd1_data_forward, B_data);

    // DO NOT comment out or rename this module
    // or the test bench will break
    data_mem data_memory(load_data, alu_out_data_MW, rd2_data_MW, MemRead_MW, MemWrite_MW, clk, reset);

    mux2v #(32) wb_mux(wr_data, alu_out_data_MW, load_data, MemToReg_MW);
    mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);

endmodule // pipelined_machine
