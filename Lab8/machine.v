module machine(clk, reset);
   input        clk, reset;

   wire [31:0]  PC;
   wire [31:2]  next_PC, PC_plus4, PC_target, EPC, new_next_PC, eret_out;
   wire [31:0]  inst;

   wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
   wire [4:0]   rs = inst[25:21];
   wire [4:0]   rt = inst[20:16];
   wire [4:0]   rd = inst[15:11];

   wire [4:0]   wr_regnum;
   wire [2:0]   ALUOp;

   wire         RegWrite, BEQ, ALUSrc, MemRead, new_MemRead, new_MemWrite, MemWrite, MemToReg, RegDst;
   wire         MFC0, MTC0, TakenInterrupt, ERET, TimerInterrupt, TimerAddress;
   wire         PCSrc, zero, negative, NotIO;
   wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;
   wire [31:0]  c0rd_data, c0wr_data, new_wr_data, taddress, tdata, cycle;


   register #(30, 30'h100000) PC_reg(PC[31:2], new_next_PC[31:2], clk, /* enable */1'b1, reset);
   assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
   adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
   adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);
   mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
   assign PCSrc = BEQ & zero;

   mux2v #(30) eret_mux(eret_out, next_PC, EPC, ERET);

   mux2v #(30) taken_mux(new_next_PC, eret_out, 30'b100000000000000000000001100000, TakenInterrupt);

   instruction_memory imem (inst, PC[31:2]);

   mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET,
                      inst);

   regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum, new_wr_data,
               RegWrite, clk, reset);

   mux2v #(32) imm_mux(B_data, rd2_data, imm, ALUSrc);
   alu32 alu(alu_out_data, zero, negative, ALUOp, rd1_data, B_data);

   data_mem data_memory(load_data, alu_out_data, rd2_data, new_MemRead, new_MemWrite, clk, reset);

   mux2v #(32) wb_mux(wr_data, alu_out_data, load_data, MemToReg);
   mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);

   assign c0wr_data = rd2_data;
   assign tdata = rd2_data;
   assign taddress = alu_out_data;

   mux2v #(32) new_wb_mux(new_wr_data, wr_data, c0rd_data, MFC0);

   not notTimerAddress(NotIO, TimerAddress);  
   and andMemRead(new_MemRead, MemRead, NotIO);
   and andMemWrite(new_MemWrite, NotIO, MemWrite);

   assign cycle = load_data;
   cp0 c1(c0rd_data, EPC, TakenInterrupt,
           c0wr_data, wr_regnum, next_PC,
           MTC0, ERET, TimerInterrupt, clk, reset);
   timer t1(TimerInterrupt, load_data, TimerAddress,
             tdata, taddress, MemRead, MemWrite, clk, reset);

endmodule // machine