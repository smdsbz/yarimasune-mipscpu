`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.18 16:30
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////

module Sim_InstructionWordSpliter
(
    output  wire    [5:0]       opcode,
    output  wire    [4:0]       rs,
    output  wire    [4:0]       rt,
    output  wire    [4:0]       rd,
    output  wire    [4:0]       shamt,
    output  wire    [5:0]       funct,
    output  wire    [15:0]      immediate
);

reg     [31:0]  instr_word;

initial begin
    // test opcode
    #0  instr_word = 0;
    #5  instr_word[31:26] = 6'b111111;
    // test shamt
    #5  instr_word = 0;
    #0  instr_word[10:6] = 5'b11111;
    // test immediate
    #5  instr_word = 0;
    #0  instr_word[15:0] = 16'hffff;
end

InstructionWordSpliter InstructionWordSpliter_TestUse (
    .instr_word(instr_word),
    .opcode(opcode),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .shamt(shamt),
    .funct(funct),
    .immediate(immediate)
);

endmodule
