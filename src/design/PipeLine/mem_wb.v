`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/20 21:03:11
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB#(parameter PC_BITS=32,parameter IR_BITS=32,parameter DATA_BITS=32)(
    input clk,
    input zero,
    input stall,
    input [PC_BITS-1:0] PC_in,
    input [IR_BITS-1:0] IR_in,
    input  Jal,        //Jal信号，此时PC跳转和Jmp一样，但是要将下一条指令的地址存入ra(31号寄存器)
    input  MemToReg,   //寄存器堆写入数据的片选信号，为1选Memory，为0选Alu的结果
    input  RegWrite,   //寄存器堆写使能
    input  [1:0] ExtrWord,   //Din片选信号，为01时选择字扩展后的数输入寄存器堆，为10选择双字扩展后的数输入
    input  ToLH,       //HI,LO寄存器使能信号
    input  ExtrSigned,   //字扩展、双字扩展方式选择信号，为1时进行符号扩展，为0进行0扩展
    input  [1:0] LHToReg,  //Din片选信号，为01时输出LO寄存器数值，为10时输出HI寄存器数值
    input   wire    [DATA_BITS - 1:0]   alu_out,    //  alu的运算结果，计算地址，应该在第五阶段数据重写完成   number / memory address calculated   
    input   wire    [DATA_BITS - 1:0]   alu_out2,
    input   wire    [DATA_BITS - 1:0]   mem_out,  //从数据存取器中取出的数据，应该在第五阶段数据重写完成
    input   wire    [DATA_BITS - 1:0]   lo,         // 从特殊寄存器读出的数据，在第五阶段数据重写完成from individual multiplier / divider
    input   wire    [DATA_BITS - 1:0]   hi,       // 从特殊寄存器读出的数据，在第五阶段数据重写完成from individual multiplier / divider
    input write,    //regfileinputAdapter中的w   
    input ld,
    output reg ld_out,
    output  reg    [DATA_BITS - 1:0]   alu_out_out,    //  alu的运算结果，计算地址，应该在第五阶段数据重写完成   number / memory address calculated   
    output  reg     [DATA_BITS - 1:0]   alu_out2_out,
    output  reg    [DATA_BITS - 1:0]   mem_out_out,  //从数据存取器中取出的数据，应该在第五阶段数据重写完成
    output  reg    [DATA_BITS - 1:0]   lo_out,         // 从特殊寄存器读出的数据，在第五阶段数据重写完成from individual multiplier / divider
    output  reg    [DATA_BITS - 1:0]   hi_out,       // 从特殊寄存器读出的数据，在第五阶段数据重写完成from individual multiplier / divider    
    output reg  write_out,    //regfileinputAdapter中的w  
    output reg  Jal_out,        //Jal信号，此时PC跳转和Jmp一样，但是要将下一条指令的地址存入ra(31号寄存器)
    output reg  MemToReg_out,   //寄存器堆写入数据的片选信号，为1选Memory，为0选Alu的结果
    output reg  RegWrite_out,   //寄存器堆写使能
    output reg  [1:0] ExtrWord_out,   //Din片选信号，为01时选择字扩展后的数输入寄存器堆，为10选择双字扩展后的数输入
    output reg  ToLH_out,       //HI,LO寄存器使能信号
    output reg  ExtrSigned_out,   //字扩展、双字扩展方式选择信号，为1时进行符号扩展，为0进行0扩展
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
                    RegWrite_out<=0;
                    MemToReg_out<=0;
                    Jal_out<=0;
                    ExtrSigned_out<=0;
                    LHToReg_out<=0;
                    ExtrWord_out<=0;
                    alu_out_out<=0;
                    alu_out2_out <= 0;
                    mem_out_out<=0;
                    lo_out<=0;
                    hi_out<=0;    
                    ld_out<=0;
                    end
                else  if(stall)
                    begin
                    PC_out<=PC_in;
                    IR_out<=IR_in;
                    write_out  <=  write;
                    ToLH_out  <=  ToLH;
                    RegWrite_out <= RegWrite;
                    MemToReg_out <= MemToReg;
                    Jal_out <= Jal;
                    ExtrSigned_out <= ExtrSigned;
                    LHToReg_out <= LHToReg;
                    ExtrWord_out <= ExtrWord;
                    alu_out_out<=alu_out;
                    alu_out2_out <= alu_out2;
                    mem_out_out<=mem_out;
                    lo_out<=lo;
                    hi_out<=hi;   
                    ld_out<=ld;
                    end
                else;
            end
endmodule
