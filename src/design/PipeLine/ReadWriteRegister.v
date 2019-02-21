`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yuhang Chen
// Version: 2.21 21:30
//
//
//////////////////////////////////////////////////////////////////////////////////


module ReadWriteRegister(
    input wire [5:0] OP,    //指令op字段
    input wire [5:0] Func,  //指令function字段
    input wire [4:0] rs,
    input wire [4:0] rt,          //指令的Rt字段，用来确定是哪一种跳转指令
    output wire [5:0] ReadRegister1,
    output wire [5:0] ReadRegister2,
    output wire [5:0] WriteRegister
    );
    wire SLL,SRA,SRL,ADD,ADDU,SUB,AND,OR,NOR,SLT,SLTU,JR;
    wire SYSCALL,J,JAL,BEQ,BNE,ADDI,ADDIU,SLTI,ANDI,ORI,LW,SRAV,SLTIU,SW;
    wire SH,SLLV,SRLV,SUBU,XOR,XORI,LUI,MULTU,DIVU,MFLO,MFHI,LB,LH,LBU,LHU,SB,BLEZ,BGTZ,BGEZ,BLTZ;

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


    wire rs_sel, rt_sel, w_rd, w_rt;
    wire rs_sel = ADD | ADDU | SUB | AND | OR | NOR | SLT | SLTU | JR | BEQ | BNE | ADDI | ANDI | ADDIU | SLTI | ORI | SRAV | SLTIU | SLLV | SRLV | SUBU | XOR | XORI | MULTU | DIVU | BLEZ | BGTZ | BGEZ | BLTZ;
    wire rt_sel = SLL | SRA | SRL | ADD | ADDU | SUB | AND | OR | NOR | SLT | SLTU | BEQ | BNE | SW | SRAV | SH | SLLV | SRLV | SUBU | XOR | MULTU | DIVU | SB;
    wire w_rd = SLL | SRA | SRL | ADD | ADDU | SUB | AND | OR | NOR | SLT | SLTU | SRAV | SLLV | SRLV | SUBU | XOR | MFLO | MFHI;
    wire w_rt = ADDI | ANDI | ADDIU | SLTI | ORI | LW | SLTIU | XORI | LUI | LB | LH | LBU | LHU;

    assign ReadRegister1 = rs_sel ? {0, rs} :
                        ( (MFLO | MFHI) ? {6'b100001} :
                        (SYSCALL ? 6'b000010 : 0) );
    assign ReadRegister2 = rt_sel ? {0, rt} :
                        (SYSCALL ? 6'b000100 : 0);
    assign WriteRegister = rt_sel ? {0, rt} :
                        ( rd_sel ? {0, rd} :
                        ( (MFLO | MFHI) ? {6'b100001} :
                        ( SYSCALL ? 6'b000010 :
                        ( JAL ? 6'b011111 : 0) ) ) );



endmodule
