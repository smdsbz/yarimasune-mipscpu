`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.26 10:37
//////////////////////////////////////////////////////////////


module Sim_CP0 (
    output  wire                INT,
    output  wire                CP0ToReg,
    output  wire    [31:0]      id_dout,
    output  wire    [31:0]      epc_out,
    output  wire                eret
);

reg     [31:0]  id_instr;
reg     [31:0]  wb_instr;
reg     [31:0]  wb_din;
reg     [31:0]  ex_pc;
reg     [2:0]   intsrc;
reg             clk, rst;

always @ * #3 clk <= ~clk;

initial begin
    #0      clk = 0;
    #0      rst = 0;
    #0      id_instr = 0;   // ie. nop
    #0      wb_instr = 0;
    #0      wb_din = { 31'dx, 1'b1 };
    #0      ex_pc = 32'hdeadbeef;
    #0      intsrc = 3'b000;
    //// test sequence goes here ////
    // reset
    #5      rst = 1;
    #5      rst = 0;
    // enable interrupt
    #6      wb_instr = { 11'b010000_00100, 5'bxxxxx, 5'd12, 8'b0000_0000, 3'b000 };
    #6      wb_instr = 0;
    // trigger interrupt
    #6      intsrc = 3'b100;
    // Expecting: CauseIP == 3'b100
    #3      intsrc = 3'b000;
    // Expecting: IPService == 3'b100
    // low level interrupt during high level interrupt servicing
    #12     intsrc = 3'b001;
    // Expecting: CauseIP == 3'b101
    // Expecting: IPService == 3'b100
    // read Cause
    #6      id_instr = { 11'b010000_00000, 5'bxxxxx, 5'd13, 8'b0000_0000, 3'b000 };
    // Expecting: id_dout == { 16'dx, { 3'dx, 3'b100, 2'b00 }, 8'dx }
    // enable interrupt before returning from interrupt service
    #6      wb_instr = { 11'b010000_00100, 5'bxxxxx, 5'd12, 8'b0000_0000, 3'b000 };
    #6      wb_instr = 0;
    // return from high level interrupt service
    #30     id_instr = 32'b010000_1_000_0000_0000_0000_0000_011000;     // ie. eret
    #6      id_instr = 0;
    // Expecting: IPService == 3'b001
    // return from low level interrupt service
    #6      wb_instr = { 11'b010000_00100, 5'bxxxxx, 5'd12, 8'b0000_0000, 3'b000 };
    #6      wb_instr = 0;
    #30     id_instr = 32'b010000_1_000_0000_0000_0000_0000_011000;     // ie. eret
    #6      id_instr = 0;
    // Expecting: intsrc == 3'b001
    // Expecting: CauseIP == 3'b000
    // Expecting: IPService == 3'b000
end

CP0 CP0TestMod (
    .clk(clk),
    .rst(rst),
    .id_instr(id_instr),
    .wb_instr(wb_instr),
    .wb_din(wb_din),
    .ex_pc(ex_pc),
    .intsrc(intsrc),
    .INT(INT),
    .CP0ToReg(CP0ToReg),
    .id_dout(id_dout),
    .epc_out(epc_out),
    .eret(eret)
);

endmodule
