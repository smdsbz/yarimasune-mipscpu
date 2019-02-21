`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yuhang Chen
// Version: 2.21 10：00
//
//
//////////////////////////////////////////////////////////////////////////////////


module RamInputAdapter
#(
    parameter  ADDR_BITS = 32,  //Ram地址位宽
    parameter  DATA_BITS = 32   //Ram数据位宽
)
(
    input wire [31:0] result1,  //Alu的第一个运算结果
    input wire [31:0] regfile_out2, //Regfile的第二个输出
    input wire Sh,  //Sh信号
    input wire Sb,  //Sb信号
    output wire [ADDR_BITS - 1:0] addr, //Ram的输入地址
    output reg [DATA_BITS - 1:0] mem_in,    //Ram的输入数据
    output reg [3:0] mem_sel    //Ram的片选信号
);
    wire [1:0] HB;
    assign HB = {Sh, Sb};
    assign addr = (result1 >> 2);
    always @ * begin
        case(HB)
            2'b00:  mem_in <= regfile_out2;
            2'b01:  mem_in <= ( regfile_out2 << (8 * (result1[1:0]) ) );
            2'b10:  mem_in <= ( regfile_out2 << (16 * (result1[1]) ) );
            default: mem_in <= regfile_out2;
        endcase
    end
    always @ * begin
        case(HB)
            2'b00:  mem_sel <= 4'hf;
            2'b01:  mem_sel <= (1 << (result1[1:0]) );
            2'b10:  mem_sel <= (3 << (2 * (result1[1]) ) );
            default: mem_sel <= 4'hf;
        endcase
    end
endmodule
