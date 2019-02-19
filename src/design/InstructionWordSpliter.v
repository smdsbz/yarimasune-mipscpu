`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.19 19:44
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////

// [combinational logic]
// splits instruction word (32 bit) for later use
module InstructionWordSpliter
(
    input   wire    [31:0]      instr_word, // instruction word
    output  wire    [5:0]       opcode,     // operation code (to ~controller~)
    output  wire    [4:0]       rs,         // source register
    output  wire    [4:0]       rt,         // target register
    output  wire    [4:0]       rd,         // destination register
    output  wire    [4:0]       shamt,      // misc parameter to ~ALU~
    output  wire    [5:0]       funct,      // function to ~controller~
    output  wire    [15:0]      immediate,  // immediate number
    output  wire    [25:0]      instr_idx   // for jump `J`
);

assign opcode   = instr_word[31:26];
assign rs       = instr_word[25:21];
assign rt       = instr_word[20:16];
assign rd       = instr_word[15:11];
assign shamt    = instr_word[10:6];
assign funct    = instr_word[5:0];
assign immediate = instr_word[15:0];
assign instr_idx = instr_word[25:0];

endmodule
