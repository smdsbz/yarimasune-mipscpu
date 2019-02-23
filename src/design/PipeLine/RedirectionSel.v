`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:  Yuhang Chen
// Version: 2.21 21:13
//
//
//////////////////////////////////////////////////////////////////////////////////


module RedirectionSel
(
input wire [5:0] ReadRegisterNumber,    //执行阶段的读寄存器编号
input wire [5:0] MEMRegisterNumber,     //访存阶段的写寄存器编号
input wire [5:0] WBRegisterNumber,      //写回阶段的读寄存器编号
input wire [31:0] ReadRegisterData,     //执行阶段读寄存器的值
input wire [31:0] MEMAluResultData,     //访存阶段的Alu的结果值
input wire [31:0] WBAluResultData,      //写回阶段的Alu的结果值
input wire [31:0] WBReadData,           //写回阶段的mem中读取的值
input wire MEMLoad,                     //访存阶段的指令的Load信号，为1时说明该指令为load指令
input wire WBLoad,                      //写回阶段的指令的Load信号，为1时说明该指令为load指令
output wire LoadStore,                  //为1时说明出现了LoadStore的情况，需要把前三个流水锁存并把第四个流水清空
output wire [31:0] EXRegisterData        //执行阶段的寄存器的最终值
);
wire sel1, sel2;
assign LoadStore = MEMLoad & sel1;
assign sel1 = ( ReadRegisterNumber != 0 ) & (ReadRegisterNumber == MEMRegisterNumber);
assign sel2 = ( ReadRegisterNumber != 0 ) & (ReadRegisterNumber == WBRegisterNumber);
assign EXRegisterData = sel1 ? MEMAluResultData :
                        (sel2 ? (WBLoad ? WBReadData : WBAluResultData) :
                        ReadRegisterData);
endmodule
