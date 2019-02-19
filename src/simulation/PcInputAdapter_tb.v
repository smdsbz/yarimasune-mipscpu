`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yuhang Chen
// Version: 2.19 18：36
//
//
//////////////////////////////////////////////////////////////////////////////////


module PcInputAdapter_tb(
    );
    reg Jmp;
    reg Jr;
    reg pcsel;
    reg [31:0] pc;
    reg [15:0] imm_16;
    reg [25:0] imm_26;
    reg [31:0] regfile_out1;
    wire [31:0] pc_next;
    PcInputAdapter
    #(.ADDR_BITS(32))
    pcinputer
    (
        .Jmp(Jmp),
        .Jr(Jr),
        .pcsel(pcsel),
        .pc(pc),
        .imm_16(imm_16),
        .imm_26(imm_26),
        .regfile_out1(regfile_out1),
        .pc_next(pc_next)
    );
    initial begin
        pc <= 4;
        Jmp <= 0;
        pcsel <= 0;
        imm_16 <= 0;
        imm_26 <= 0;
        regfile_out1 <= 0;
        Jr <= 0;
        #10 pcsel <= 1;
        imm_16 <= 1;
        #10 pcsel <= 1;
        imm_16 <=  16'hffff;
        #10 pcsel <= 0;
        Jmp <= 1;
        imm_26 <= 1;
        #10 imm_26 <= 26'h3ffffff;
        #10 Jr <= 1;
        regfile_out1 <= 4;
    end
endmodule
