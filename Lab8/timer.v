`define ALU_ADD    3'h0
`define ONE 1'h1 

module timer(TimerInterrupt, cycle, TimerAddress,
             data, address, MemRead, MemWrite, clock, reset);
    output        TimerInterrupt;
    output [31:0] cycle;
    output        TimerAddress;
    input  [31:0] data, address;
    input         MemRead, MemWrite, clock, reset;

    // complete the timer circuit here
    wire [31:0] CurrCycle, NextCycle;
    wire [31:0] InterruptCycle;
    wire TimerWrite, TimerRead, inter_line_enable, inter_line_reset;
    wire readAddr, writeAddr, Acknowledge;

    assign readAddr = ({32'hffff001c} == address);
    assign writeAddr = ({32'hffff006c} == address);
    assign Acknowledge = writeAddr && MemWrite;
    assign TimerRead = readAddr && MemRead;
    assign TimerWrite = readAddr && MemWrite;
    assign TimerAddress = readAddr || writeAddr;

    // cycle counter part
    register #(32) cycle_counter_reg(CurrCycle, NextCycle, clock, `ONE, reset);
    alu32 #(32) cycle_plus(NextCycle, , ,`ALU_ADD, CurrCycle, {32'h1});
    tristate timer_read_tri(cycle, CurrCycle, TimerRead);

    // HINT: make your interrupt cycle register reset to 32'hffffffff
    //       (using the reset_value parameter)
    //       to prevent an interrupt being raised the very first cycle
    register #(32, 32'hffffffff) interrupt_cycle_reg(InterruptCycle, data, clock, TimerWrite, reset);

    assign inter_line_enable = (InterruptCycle == CurrCycle);
    assign inter_line_reset = (Acknowledge || reset);

    dffe interrupt_line(TimerInterrupt, `ONE, clock, inter_line_enable, inter_line_reset);

    

endmodule
