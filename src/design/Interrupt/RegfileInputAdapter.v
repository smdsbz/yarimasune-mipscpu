`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.20 17:05
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////

// [combinational logic]
// deals with ~RegFile~'s data input selection
module RegfileInputAdapter
#(
    parameter   DATA_BITS   = 32
) (
    // data lines in
    input   wire    [4:0]               rs,
    input   wire    [4:0]               rt,
    input   wire    [4:0]               rd,
    input   wire                        Jal,
    input   wire                        RegDst,
    output  wire    [4:0]               IR1,
    output  wire    [4:0]               IR2,
    output  reg     [4:0]               W         // index of reg to write to
);

assign IR1 = rs;
assign IR2 = rt;

always @ * begin
    if (Jal) begin
        W <= 31;    // $ra: return address register
    end else begin
        W <= RegDst ? rd : rt;
    end
end

endmodule
