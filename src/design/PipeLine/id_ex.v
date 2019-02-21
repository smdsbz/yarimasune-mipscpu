`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/20 18:56:26
// Design Name: 
// Module Name: ID_EX
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


module ID_EX#(parameter PC_BITS=32,parameter IR_BITS=32,parameter DATA_BITS=32)(
    input clk,
    input zero,
    input stall,
    input [PC_BITS-1:0] PC_in,
    input [IR_BITS-1:0] IR_in,
    input  Jmp,        //Jmp信号，用来控制PC跳转以及统计无条件跳转次数,PC = immediate
    input  Jr,         //Jr信号，用来控制PC跳转，此时PC=PC+REG[Rs]
    input  Jal,        //Jal信号，此时PC跳转和Jmp一样，但是要将下一条指令的地址存入ra(31号寄存器)
    input  Beq,        //Beq信号，控制有条件跳转
    input  Bne,        //Bne信号，控制有条件跳转
    input  MemToReg,   //寄存器堆写入数据的片选信号，为1选Memory，为0选Alu的结果
    input  MemWrite,   //Memory写使能
    input  [3:0]AluOP,      //Alu功能选择信号
    input  AluSrcB,    //Alu第二个操作数选择信号
    input  RegWrite,   //寄存器堆写使能
    input  Syscall,    //系统调用指令
    input  [1:0] ExtrWord,   //Din片选信号，为01时选择字扩展后的数输入寄存器堆，为10选择双字扩展后的数输入
    input  ToLH,       //HI,LO寄存器使能信号
    input  ExtrSigned,   //字扩展、双字扩展方式选择信号，为1时进行符号扩展，为0进行0扩展
    input  Sh,
    input  Sb,
    input  [1:0] ShamtSel, //Shamt字段选择信号，为10时输出16（0x10），为01时输出Rs后5位，否则为指令的shamt字段
    input  [1:0] LHToReg,  //Din片选信号，为01时输出LO寄存器数值，为10时输出HI寄存器数值
    input  Bltz,
    input  Blez,
    input  Bgez,
    input  Bgtz,
    input [15:0]imm_16,
    input [25:0]imm_26,
    input [DATA_BITS-1:0]regfile_out1,
    input [DATA_BITS-1:0]regfile_out2,
    input write,    //regfileinputAdapter中的w
    input [DATA_BITS-1:0]a0,
    input [DATA_BITS-1:0]v0,
    input [DATA_BITS-1:0]ra,
    input [4:0]shamt,
    input SignedExt,
    input [DATA_BITS - 1:0] lo,
    input [DATA_BITS - 1:0] hi,
    input ld;
    output reg ld;
    output reg SignedExt_out,
    output reg [4:0] shamt_out,
    output reg [15:0]imm_16_out,
    output reg [25:0]imm_26_out,
    output reg [DATA_BITS-1:0]regfile_out1_out,
    output reg [DATA_BITS-1:0]regfile_out2_out,
    output reg [DATA_BITS-1:0]a0_out,
    output reg [DATA_BITS-1:0]v0_out,
    output reg [DATA_BITS-1:0]ra_out,
    output reg [DATA_BITS - 1:0] lo_out,
    output reg [DATA_BITS - 1:0] hi_out,
    output reg write_out,
    output reg  Jmp_out,        //Jmp信号，用来控制PC跳转以及统计无条件跳转次数,PC = immediate
    output reg  Jr_out,         //Jr信号，用来控制PC跳转，此时PC=PC+REG[Rs]
    output reg  Jal_out,        //Jal信号，此时PC跳转和Jmp一样，但是要将下一条指令的地址存入ra(31号寄存器)
    output reg  Beq_out,        //Beq信号，控制有条件跳转
    output reg  Bne_out,        //Bne信号，控制有条件跳转
    output reg  MemToReg_out,   //寄存器堆写入数据的片选信号，为1选Memory，为0选Alu的结果
    output reg  MemWrite_out,   //Memory写使能
    output reg  [3:0]AluOP_out,      //Alu功能选择信号
    output reg  AluSrcB_out,    //Alu第二个操作数选择信号
    output reg  RegWrite_out,   //寄存器堆写使能
    output reg  Syscall_out,    //系统调用指令
    output reg  [1:0] ExtrWord_out,   //Din片选信号，为01时选择字扩展后的数输入寄存器堆，为10选择双字扩展后的数输入
    output reg  ToLH_out,       //HI,LO寄存器使能信号
    output reg  ExtrSigned_out,   //字扩展、双字扩展方式选择信号，为1时进行符号扩展，为0进行0扩展
    output reg  Sh_out,
    output reg  Sb_out,
    output reg  [1:0] ShamtSel_out, //Shamt字段选择信号，为10时输出16（0x10），为01时输出Rs后5位，否则为指令的shamt字段
    output reg  [1:0] LHToReg_out,  //Din片选信号，为01时输出LO寄存器数值，为10时输出HI寄存器数值
    output reg  Bltz_out,
    output reg  Blez_out,
    output reg  Bgez_out,
    output reg  Bgtz_out,
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
                    Syscall_out<=0;
                    Sh_out<=0;
                    Sb_out<=0;
                    RegWrite_out<=0;
                    MemWrite_out<=0;
                    MemToReg_out<=0;
                    Jr_out<=0;
                    Jmp_out<=0;
                    Jal_out<=0;
                    ExtrSigned_out<=0;
                    Bne_out<=0;
                    Bltz_out<=0;
                    Blez_out<=0;
                    Bgtz_out<=0;
                    Bgez_out<=0;
                    Beq_out<=0;
                    AluSrcB_out<=0;
                    v0_out<=0;
                    regfile_out2_out<=0;
                    regfile_out1_out<=0;
                    ra_out<=0;
                    a0_out<=0;
                    shamt_out<=0;
                    AluOP_out<=0;
                    imm_26_out<=0;
                    imm_16_out<=0;
                    ShamtSel_out<=0;
                    LHToReg_out<=0;
                    ExtrWord_out<=0;
                    SignedExt_out<=0;
                    lo_out <= 0;
                    hi_out <= 0;
                    ld_out <= 0;
                    end
                else  if(stall)
                    begin
                    PC_out<=PC_in;
                    IR_out<=IR_in;
                    write_out  <=  write;
                    ToLH_out  <=  ToLH;
                    Syscall_out  <=  Syscall;
                    Sh_out  <=  Sh;
                    Sb_out  <=  Sb;
                    RegWrite_out <= RegWrite;
                    MemWrite_out <= MemWrite;
                    MemToReg_out <= MemToReg;
                    Jr_out <= Jr;
                    Jmp_out <= Jmp;
                    Jal_out <= Jal;
                    ExtrSigned_out <= ExtrSigned;
                    Bne_out <= Bne;
                    Bltz_out <= Bltz;
                    Blez_out <= Blez;
                    Bgtz_out <= Bgtz;
                    Bgez_out <= Bgez;
                    Beq_out <= Beq;
                    AluSrcB_out     <= AluSrcB;
                    v0_out <= v0;
                    regfile_out2_out <= regfile_out2;
                    regfile_out1_out <= regfile_out1_out;
                    ra_out <= ra;
                    a0_out <= a0;
                    shamt_out <= shamt;
                    AluOP_out <= AluOP;
                    imm_26_out <= imm_26;
                    imm_16_out <= imm_16;
                    ShamtSel_out <= ShamtSel;
                    LHToReg_out <= LHToReg;
                    ExtrWord_out <= ExtrWord;
                    SignedExt_out<=SignedExt;
                    lo_out <= lo;
                    hi_out <= hi;
                    ld_out <= ld;
                    end
                else;
            end
    endmodule
