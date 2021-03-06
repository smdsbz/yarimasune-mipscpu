`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.20 16:56
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////

// [combinational logic]
// adapter between ~RegFile~ and ~ALU~
module ALUInputAdapter
#(
    parameter   DATA_BITS = 32
) (
    // data lines in
    input   wire    [DATA_BITS - 1:0]   RegOut1,
    input   wire    [DATA_BITS - 1:0]   RegOut2,
    input   wire    [15:0]              Immediate,
    input   wire    [4:0]               ShamtIn,
    // signals in
    input   wire                        AluSrcB,    // Note: probably needs more than 1 bit
    input   wire    [1:0]               ShamtSel,
    input   wire                        SignedExt,
    // real data out to ~ALU~
    output  wire    [DATA_BITS - 1:0]   AluA,
    output  reg     [DATA_BITS - 1:0]   AluB,
    output  reg     [4:0]               ShamtOut
);

assign AluA = RegOut1;

wire    [DATA_BITS - 1:0] immediate_extended;
assign immediate_extended = SignedExt ? { {16{Immediate[15]}}, Immediate } : Immediate;
always @ * begin
    case (AluSrcB)
        0:      AluB <= RegOut2;
        1:      AluB <= immediate_extended;
    endcase
end

always @ * begin
    case (ShamtSel)
        0:  ShamtOut <= ShamtIn;
        1:  ShamtOut <= RegOut1[4:0];
        2:  ShamtOut <= 16;
        3:  ShamtOut <= 0;  // undefined
    endcase
end

endmodule
