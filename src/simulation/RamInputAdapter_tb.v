`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yuhang Chen
// Version: 2.19 16:45
//
//
//////////////////////////////////////////////////////////////////////////////////


module RamInputAdapter_tb(
    );
    reg [31:0] result1;
    reg [31:0] regfile_out2;
    reg Sh;
    reg Sb;
    wire [9:0] addr;
    wire [31:0] mem_in;
    wire [3:0] mem_sel;
    RamInputAdapter #(
        .ADDR_BITS(32),  //Ram地址位宽
        .DATA_BITS(32)   //Ram数据位宽
    )
    raminputer
    (
        .result1(result1),  //Alu的第1个运算结果
        .regfile_out2(regfile_out2), //Regfile的第二个输出
        .Sh(Sh),  //Sh信号
        .Sb(Sb),  //Sb信号
        .addr(addr), //Ram的输入地址
        .mem_in(mem_in),    //Ram的输入数据
        .mem_sel(mem_sel)    //Ram的片选信号
    );
    initial begin
        result1 <= 0;
        regfile_out2 <= 0;
        Sh <= 0;
        Sb <= 0;
        #10
        Sh <= 1;
        result1 <= 32'b10;
        regfile_out2 <= 32'b01;
        #20
        Sh <= 0;
        Sb <= 1;
        result1 <= 32'b100;
        regfile_out2 <= 32'h1234;
    end
endmodule
