`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/20 20:04:08
// Design Name: 
// Module Name: EX_MEM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module EX_MEM#(parameter PC_BITS=32,parameter IR_BITS=32,parameter DATA_BITS=32)(
    input clk,
    input zero,
    input stall,
    input [PC_BITS-1:0] PC_in,
    input [IR_BITS-1:0] IR_in,
    input  Jal,        //Jal信号，此时PC跳转和Jmp一样，但是要将下一条指令的地址存入ra(31号寄存器)
    input  MemToReg,   //寄存器堆写入数据的片选信号，为1选Memory，为0选Alu的结果
    input  MemWrite,   //Memory写使能
    input  RegWrite,   //寄存器堆写使能
    input  [1:0] ExtrWord,   //Din片选信号，为01时选择字扩展后的数输入寄存器堆，为10选择双字扩展后的数输入
    input  ToLH,       //HI,LO寄存器使能信号
    input  ExtrSigned,   //字扩展、双字扩展方式选择信号，为1时进行符号扩展，为0进行0扩展
    input  Sh,
    input  Sb,
    input  [1:0] LHToReg,  //Din片选信号，为01时输出LO寄存器数值，为10时输出HI寄存器数值
    input [DATA_BITS-1:0]regfile_out2,
    input write,    //regfileinputAdapter中的w
    input [DATA_BITS-1:0]result_1,
    input [DATA_BITS-1:0]result_2,
    input [DATA_BITS - 1:0] lo,
    input [DATA_BITS - 1:0] hi,
    output reg[DATA_BITS-1:0]result_1_out,
    output reg[DATA_BITS-1:0]result_2_out,
    output reg [DATA_BITS-1:0]regfile_out2_out,
    output reg [DATA_BITS - 1:0] lo_out,
    output reg [DATA_BITS - 1:0] hi_out,
    output reg write_out,
    output reg  Jal_out,        //Jal信号，此时PC跳转和Jmp一样，但是要将下一条指令的地址存入ra(31号寄存器)
    output reg  MemToReg_out,   //寄存器堆写入数据的片选信号，为1选Memory，为0选Alu的结果
    output reg  MemWrite_out,   //Memory写使能
    output reg  RegWrite_out,   //寄存器堆写使能
    output reg  [1:0] ExtrWord_out,   //Din片选信号，为01时选择字扩展后的数输入寄存器堆，为10选择双字扩展后的数输入
    output reg  ToLH_out,       //HI,LO寄存器使能信号
    output reg  ExtrSigned_out,   //字扩展、双字扩展方式选择信号，为1时进行符号扩展，为0进行0扩展
    output reg  Sh_out,
    output reg  Sb_out,
    output reg  [1:0] LHToReg_out,  //Din片选信号，为01时输出LO寄存器数值，为10时输出HI寄存器数值
    output reg [PC_BITS-1:0] PC_out,
    output reg [IR_BITS-1:0] IR_out
);
        always @(posedge clk)
            begin
                if(zero)begin
                    PC_out<=0;
                    IR_out<=0;
                    write_out<=0;
                    ToLH_out<=0;
                    Sh_out<=0;
                    Sb_out<=0;
                    RegWrite_out<=0;
                    MemWrite_out<=0;
                    MemToReg_out<=0;
                    Jal_out<=0;
                    ExtrSigned_out<=0;
                    regfile_out2_out<=0;
                    LHToReg_out<=0;
                    ExtrWord_out<=0;
                    result_1_out<=0;
                    result_2_out<=0;
                    lo_out <= 0;
                    hi_out <= 0;
                    end
                else  if(stall)
                    begin
                    PC_out<=PC_in;
                    IR_out<=IR_in;
                    write_out  <=  write;
                    ToLH_out  <=  ToLH;
                    Sh_out  <=  Sh;
                    Sb_out  <=  Sb;
                    RegWrite_out <= RegWrite;
                    MemWrite_out <= MemWrite;
                    MemToReg_out <= MemToReg;
                    Jal_out <= Jal;
                    ExtrSigned_out <= ExtrSigned;
                    regfile_out2_out <= regfile_out2;
                    LHToReg_out <= LHToReg;
                    ExtrWord_out <= ExtrWord;
                    result_1_out<=result_1;
                    result_2_out<=result_2;
                    lo_out <= lo;
                    hi_out <= hi;
                    end
                else;
            end
endmodule
