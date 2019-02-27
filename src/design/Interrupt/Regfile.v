`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:  Yuhang Chen
// Version: 2.19 10.50
//
//
//////////////////////////////////////////////////////////////////////////////////


module Regfile(
    IR1,IR2,W,Din,WE,CLK,RST,OR1,OR2,a0,v0,ra
    );
    input wire [4:0] IR1;   //Rs寄存器�?�择信号
    input wire [4:0] IR2;   //Rt寄存器�?�择信号
    input wire [4:0] W;     //写寄存器选择信号
    input wire [31:0] Din;  //写入数据
    input wire WE;          //写使能，��?1时写入数��?
    input wire CLK;
    input wire RST;
    output wire [31:0] OR1; //输出R1
    output wire [31:0] OR2; //输出R2
    output wire [31:0] a0;  //寄存器a0(4号寄存器)
    output wire [31:0] v0;  //寄存器v0(2号寄存器)
    output wire [31:0] ra;  //寄存器ra(31号寄存器)
    reg [31:0] REG [0:31];  //寄存器堆

    assign OR1 = REG[IR1];
    assign OR2 = REG[IR2];
    assign a0 = REG[4];
    assign v0 = REG[2];
    assign ra = REG[31];

    always @(negedge CLK) begin
        REG[0] = 0;
        if(WE & (W != 0)) begin
            REG[W] <= Din;
        end
        //OR1 <= REG[IR1];
        //OR2 <= REG[IR2];
    end
endmodule
