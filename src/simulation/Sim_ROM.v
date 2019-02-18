`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.18 18:38
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////

module Sim_ROM
(
    output  wire    [31:0]   dout
);

reg     [3:0]       addr;
reg                 sel;

initial begin
    #0      addr = 5;
    #0      sel = 0;
    #5      sel = 1;
    #5      addr = 3;
end

ROM #(/*ADDR_BITS=*/4) ROM_TestUse (
    .addr(addr),
    .sel(sel),
    .dout(dout)
);

endmodule
