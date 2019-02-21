`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:  Yuhang Chen
// Version: 2.21 8:09
//
//
//////////////////////////////////////////////////////////////////////////////////


module Controller
(
    input wire [5:0] OP,    //指令op字段
    input wire [5:0] Func,  //指令function字段
    input wire [4:0]Rt,          //指令的Rt字段，用来确定是哪一种跳转指令
    output wire Jmp,        //Jmp信号，用来控制PC跳转以及统计无条件跳转次数,PC = immediate
    output wire Jr,         //Jr信号，用来控制PC跳转，此时PC=PC+REG[Rs]
    output wire Jal,        //Jal信号，此时PC跳转和Jmp一样，但是要将下一条指令的地址存入ra(31号寄存器)
    output wire Beq,        //Beq信号，控制有条件跳转
    output wire Bne,        //Bne信号，控制有条件跳转
    output wire MemToReg,   //寄存器堆写入数据的片选信号，为1选Memory，为0选Alu的结果
    output wire MemWrite,   //Memory写使能
    output wire [3:0]AluOP,      //Alu功能选择信号
    output wire AluSrcB,    //Alu第二个操作数选择信号
    output wire RegWrite,   //寄存器堆写使能
    output wire RegDst,     //寄存器堆的写寄存器片选信号，为1时选Rd，为0时选Rt
    output wire Syscall,    //系统调用指令
    output wire SignedExt,  //控制立即数部分的有/无符号扩展
    output wire [1:0] ExtrWord,   //Din片选信号，为01时选择字扩展后的数输入寄存器堆，为10选择双字扩展后的数输入
    output wire ToLH,       //HI,LO寄存器使能信号
    output wire ExtrSigned,   //字扩展、双字扩展方式选择信号，为1时进行符号扩展，为0进行0扩展
    output wire Sh,
    output wire Sb,
    output wire [1:0] ShamtSel, //Shamt字段选择信号，为10时输出16（0x10），为01时输出Rs后5位，否则为指令的shamt字段
    output wire [1:0] LHToReg,  //Din片选信号，为01时输出LO寄存器数值，为10时输出HI寄存器数值
    output wire Bltz,
    output wire Blez,
    output wire Bgez,
    output wire Bgtz
);

// instruction hints (all-uppercase)
wire SLL,SRA,SRL,ADD,ADDU,SUB,AND,OR,NOR,SLT,SLTU,JR;
wire SYSCALL,J,JAL,BEQ,BNE,ADDI,ADDIU,SLTI,ANDI,ORI,LW,SW;
wire SRAV,SLTIU,SH,BLTZ,SLLV;
wire ShamtSel1,ShamtSel2,LHToReg1,LHToReg2,ExtrWord1,ExtrWord2;
wire S1,S2,S3,S0;

assign SLL = (OP == 6'd0) & (Func == 6'd0);
assign SRA = (OP == 6'd0) & (Func == 6'd3);
assign SRL = (OP == 6'd0) & (Func == 6'd2);
assign ADD = (OP == 6'd0) & (Func == 6'd32);
assign ADDU = (OP == 6'd0) & (Func == 6'd33);
assign SUB = (OP == 6'd0) & (Func == 6'd34);
assign AND = (OP == 6'd0) & (Func == 6'd36);
assign OR = (OP == 6'd0) & (Func == 6'd37);
assign NOR = (OP == 6'd0) & (Func == 6'd39);
assign SLT = (OP == 6'd0) & (Func == 6'd42);
assign SLTU = (OP == 6'd0) & (Func == 6'd43);
assign JR = (OP == 6'd0) & (Func == 6'd8);
assign SYSCALL = (OP == 6'd0) & (Func == 6'd12);
assign J = (OP == 6'd2);
assign JAL = (OP == 6'd3);
assign BEQ = (OP == 6'd4);
assign BNE = (OP == 6'd5);
assign ADDI = (OP == 6'd8);
assign ADDIU = (OP == 6'd9);
assign SLTI = (OP == 6'd10);
assign ANDI = (OP == 6'd12);
assign ORI = (OP == 6'd13);
assign LW = (OP == 6'd35);
assign SW = (OP == 6'd43);
assign SRAV = (OP == 6'd0) & (Func == 6'd7);
assign SLTIU = (OP == 6'd11);
assign SH = (OP == 6'd41);
assign SLLV = (OP == 6'd0) & (Func == 6'd4);
assign SRLV = (OP == 6'd0) & (Func == 6'd6);
assign SUBU = (OP == 6'd0) & (Func == 6'd35);
assign XOR = (OP == 6'd0) & (Func == 6'd38);
assign XORI = (OP == 6'd14);
assign LUI = (OP == 6'd15);
assign MULTU = (OP == 6'd0) & (Func == 6'd25);
assign DIVU = (OP == 6'd0) & (Func == 6'd27);
assign MFLO = (OP == 6'd0) & (Func == 6'd18);
assign MFHI = (OP == 6'd0) & (Func == 6'd16);
assign LB = (OP == 6'd32);
assign LH = (OP == 6'd33);
assign LBU = (OP == 6'd36);
assign LHU = (OP == 6'd37);
assign SB = (OP == 6'd40);
assign BGEZ = (OP == 6'd1) & (Rt == 5'd1);
assign BLEZ = (OP == 6'd6) & (Rt == 5'd0);
assign BGTZ = (OP == 6'd7) & (Rt == 5'd0);
assign BLTZ = (OP == 6'd1) & (Rt == 5'd0);

// generated signals (camelcase)
assign MemToReg = LW | LB | LH | LBU | LHU;
assign MemWrite = SW | SH | SB;
// Note: Syscall code pulled out from OR2 of ~RegFile~ should connect to
//       input #1 of ~ALU~ second input MUX, due to `SYSCALL` is included in
//       `AluSrcB`; otherwise, connect to input #0.
assign AluSrcB = SYSCALL | ADDI | ANDI | ADDIU | SLTI | ORI | LW | SW | SLTIU | SH | XORI | LUI | LB | LH | LBU | LHU | SB;
assign RegWrite = SLL | SRA | SRL | ADD | ADDU | SUB | AND | OR | NOR | SLT | SLTU | JAL | ADDI | ANDI | SLTI | ORI | LW | ADDIU | SRAV | SLTIU | SLLV | SRLV | SUBU | XOR | XORI | LUI | MFLO | MFHI | LB | LH | LBU | LHU;
assign Syscall = SYSCALL;
assign SignedExt = ADDI | ADDIU | SLTI | LW | SW | SLTIU | SH | LB | LH | LBU | LHU | SB;
assign RegDst = SLL | SRA | SRL | ADD | ADDU | SUB | AND | OR | NOR | SLT | SLTU | JAL | SRAV | SLLV | SRLV | SUBU | XOR | MULTU | DIVU;
assign Beq = BEQ;
assign Bne = BNE;
assign Jr = JR;
assign Jmp = JR | J | JAL;
assign Jal = JAL;
assign ExtrSigned = LBU | LHU;
assign Sh = SH;
assign Sb = SB;
assign ToLH = MULTU | DIVU;
assign Blez = BLEZ;
assign Bgtz = BGTZ;
assign Bgez = BGEZ;
assign Bltz = BLTZ;

assign ShamtSel1 = SRAV | SLLV | SRLV;
assign ShamtSel2 = LUI;
assign LHToReg1 = MFLO;
assign LHToReg2 = MFHI;
assign ExtrWord1 = LB | LBU;
assign ExtrWord2 =  LH | LHU;

assign ShamtSel = {ShamtSel2, ShamtSel1};
assign LHToReg = {LHToReg2, LHToReg1};
assign ExtrWord = {ExtrWord2, ExtrWord1};

assign S3 = OR | NOR | SLT | SLTU | SLTI | ORI | SLTIU | XOR | XORI;
assign S2 = ADD | ADDU | SUB | AND | SLTU | ADDI | ANDI | ADDIU | LW | SW | SH | SUBU | DIVU | LB | LH | LBU | LHU | SB;
assign S1 = SRL | SUB | AND | ANDI | NOR | SLT | SLTI | SLTIU | SUBU | MULTU;
assign S0 = SRA | ADD | ADDU | AND | SLT | ADDI | ANDI | ADDIU | SLTI | LW | SW | SRAV | SLTIU | SH | SRLV | XOR | XORI | MULTU | LB | LH | LBU | LHU | SB;
assign AluOP = {S3,S2,S1,S0};
endmodule
