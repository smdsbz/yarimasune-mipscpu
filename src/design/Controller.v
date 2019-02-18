`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/02/18 18:21:19
// Design Name:
// Module Name: Controller
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


module Controller
(
    input wire [5:0] OP,
    input wire [5:0] Func,
    output wire Jmp,
    output wire Jr,
    output wire Jal,
    output wire Beq,
    output wire Bne,
    output wire MemToReg,
    output wire MemWrite,
    output wire [3:0] AluOP,
    output wire AluSrcB,
    output wire RegWrite,
    output wire RegDst,
    output wire Syscall,
    output wire SignedExt
);

// instruction hints (all-uppercase)
wire SLL,SRA,SRL,ADD,ADDU,SUB,AND,OR,NOR,SLT,SLTU,JR;
wire SYSCALL,J,JAL,BEQ,BNE,ADDI,ADDIU,SLTI,ANDI,ORI,LW,SW;

assign SLL = (OP == 6'd0) & (Func == 6'd0);
assign SRA = (OP == 6'd0) & (Func == 6'd3);
assign SRL = (OP == 6'd0) & (Func == 6'd2);
assign ADD = (OP == 6'd0) & (Func == 6'd32);
assign ADDU = (OP == 6'd0) & (Func == 6'd33);
assign SUB = (OP == 6'd0) & (Func == 6'd34);
assign AND = (OP == 6'd0) & (Func == 6'd37);
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

// generated signals (camelcase)
assign MemToReg = LW;
assign MemWrite = SW;
// Note: Syscall code pulled out from OR2 of ~RegFile~ should connect to
//       input #1 of ~ALU~ second input MUX, due to `SYSCALL` is included in
//       `AluSrcB`; otherwise, connect to input #0.
assign AluSrcB = SYSCALL | ADDI | ANDI | ADDIU | SLTI | ORI | LW | SW;
assign RegWrite = (
    SLL | SRA | SRL | ADD | ADDU | SUB | AND | OR | NOR | SLT | SLTU
    | JAL | ADDI | ANDI | ADDIU | SLTI | ORI | LW
);
assign Syscall = SYSCALL;
// Note: `BNE`, `BEQ` and like should be handled individually in some other
//       module between ~RegFile~ and ~ALU~, thus not included here.
assign SignedExt = ADDI | ADDIU | SLTI | LW | SW;
assign RegDst = SLL | SRA | SRL | ADD | ADDU | SUB | AND | OR | NOR | SLT | SLTU;
assign Beq = BEQ;
assign Bne = BNE;
assign Jmp = JR | J | JAL;
assign Jr = JR;
assign Jal = JAL;

// ALU operation code
wire S0, S1, S2, S3;
assign S3 = OR | NOR | SLT | SLTU | SLTI | ORI;
assign S2 = ADD | ADDU | SUB | AND | SLTU | ADDI | ANDI | ADDIU | LW | SW;
assign S1 = SRL | SUB | AND | NOR | SLT | SLTI;
assign S0 = SRA | ADD | ADDU | AND | SLT | ADDI | ANDI | ADDIU | SLTI | LW | SW;
assign AluOP = { S3, S2, S1, S0};

endmodule
