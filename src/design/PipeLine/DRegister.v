`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yuhang Chen
// Version: 2.19
//
//
//////////////////////////////////////////////////////////////////////////////////


module DRegister
#(parameter DATA_BITS = 32)
(
    input wire clk, //系统时钟
    input wire rst, //同步清零信号
    input wire enable,  //D寄存器使能信号
    input wire [DATA_BITS - 1:0] data_in,   //输入数据
    input wire valid,
    output wire [DATA_BITS - 1:0] data_out,  //输出数据
    output reg valid_out
);
    reg [DATA_BITS - 1:0] REG;
    assign data_out = REG;
    always @ ( posedge clk ) begin
        if(rst | ~valid) begin
            REG <= 0;
            valid_out <= 0;
        end
        else if(enable) begin
            REG <= data_in;
            valid_out <= 1;
        end
    end
endmodule
