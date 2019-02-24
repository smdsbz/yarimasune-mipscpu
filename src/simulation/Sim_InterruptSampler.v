`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.24 15:16
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////


module Sim_InterruptSampler (
    output  wire    indication
);

reg     clk, rst;
reg     intsrc;

always @ * #3 clk <= ~clk;

initial begin
    // initializations
    #0      clk = 0;
    #0      rst = 0;
    #0      intsrc = 0;
    #5      rst = 1;
    #6      rst = 0;
    // yield single shot interrupt signal
    #6      intsrc = 1;
    #3      intsrc = 0;
    // clear
    #12     rst = 1;
    #3      rst = 0;
    // yield overlapped interrupt signal
    #6      intsrc = 1;
    #3      intsrc = 0;
    #6      rst = 1;
    // yield while clearing
    #3      intsrc = 1;
    #3      intsrc = 0;
    #0      rst = 0;
end

InterruptSampler IntSamp_TestMod (
    .clk(clk),
    .rst(rst),
    .int(intsrc),
    .indication(indication)
);

endmodule
