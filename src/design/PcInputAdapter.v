`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yuhang Chen
// Version: 2.19 17:10
//
//
//////////////////////////////////////////////////////////////////////////////////


module PcInputAdapter
#(parameter ADDR_BITS = 32)
(
    input wire Jmp,     //Jmp信号,当进行无条件跳转时该
    input wire Jr,      //Jr信号
    input wire pcsel,   //pcsel片选信号，当进行条件跳转时该信号有效
    input wire [ADDR_BITS - 1:0] pc,    //pc的当前值
    input wire [15:0] imm_16,
    input wire [25:0] imm_26,
    input wire [31:0] regfile_out1, //regfile的第一个输出
    output reg [ADDR_BITS - 1:0] pc_next    //下一个时钟上升沿来临时的pc的值
);
    wire [1:0]PJ;
    assign PJ = {pcsel, Jmp};
    always @ ( PJ or Jr or imm_16 or imm_26 or regfile_out1 or pc) begin
        case(PJ)
            2'b00:  pc_next <= pc + 4;
            2'b01:  pc_next <= (Jr ? regfile_out1 : ( { {( ADDR_BITS - 26){ imm_26[25] } }, imm_26 }<<2 ) );
            2'b10:  pc_next = pc + 4 + ( { {( ADDR_BITS - 16){ imm_16[15] } }, imm_16 }<<2 );
            default: pc_next <= pc + 4;
        endcase
    end
endmodule
