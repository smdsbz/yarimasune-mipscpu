`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2019 11:19:45 AM
// Design Name: 
// Module Name: Sim_LHSpecialRegisters
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Sim_LHSpecialRegisters (
    output  wire    [31:0]  lo,
    output  wire    [31:0]  hi
);

reg             clk;
reg     [63:0]  result;
reg             ready;

initial begin
    #0      clk = 0;
    #0      ready = 0;
    #0      result = 0;
    // floating result, should have no effets on lo and hi
    #5      result = 64'h1122334455667788;
    // give ready, lo, hi should be refreshed, result should be hold
    #5      ready = 1;
    // retrieve ready
    #13     ready = 0;
    #5      result = 0;
end

always @ * #3 clk <= ~clk;

LHSpecialRegisters LHSpecialRegisters_TestMod (
    .clk(clk),
    .result(result),
    .ready(ready),
    .lo(lo),
    .hi(hi)
);

endmodule
