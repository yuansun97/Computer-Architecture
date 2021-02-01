`define STATUS_REGISTER 5'd12
`define CAUSE_REGISTER  5'd13
`define EPC_REGISTER    5'd14

`define ONE 1'h1 

module cp0(rd_data, EPC, TakenInterrupt,
           wr_data, regnum, next_pc,
           MTC0, ERET, TimerInterrupt, clock, reset);
    output [31:0] rd_data;
    output [29:0] EPC;
    output        TakenInterrupt;
    input  [31:0] wr_data;
    input   [4:0] regnum;
    input  [29:0] next_pc;
    input         MTC0, ERET, TimerInterrupt, clock, reset;

    // your Verilog for coprocessor 0 goes here

    wire [31:0] user_status, reg_addr, cause_reg, status_reg;
    wire [29:0] epc_out, epc_in;
    wire addr_12, addr_14, exception_level;
    wire epc_enable, ex_reset;

    assign addr_12 = reg_addr[`STATUS_REGISTER];
    assign addr_14 = reg_addr[`EPC_REGISTER];
    assign cause_reg = {{16'h0}, TimerInterrupt, {15'h0}};
    assign epc_enable = (addr_14 || TakenInterrupt);
    assign ex_reset = (reset || ERET);

    assign EPC = epc_out;

    assign status_reg = {{16'h0}, {user_status[15:8]}, {6'h0}, exception_level, user_status[0]};
    assign TakenInterrupt = (cause_reg[15] && status_reg[15]) && (~(status_reg[1]) && status_reg[0]);

    decoder32 regnum_decoder(reg_addr, regnum, MTC0);
    mux2v #(30)  epc_mux(epc_in, wr_data[31:2], next_pc, TakenInterrupt);

    register #(32) user_status_reg(user_status, wr_data, clock, addr_12, reset);
    register #(30) EPC_reg(epc_out, epc_in, clock, epc_enable, reset);
    dffe exception_level_ff(exception_level, `ONE, clock, TakenInterrupt, ex_reset);

    mux32v #(32) re_data_mux(rd_data, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 
        32'h0, 32'h0, 32'h0, 32'h0, 32'h0, status_reg, cause_reg, {epc_out, 2'h0}, 
        32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 
        32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0, regnum);
endmodule
