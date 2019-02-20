`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:  Yuhang Chen
// Version: 2.19
//
//
//////////////////////////////////////////////////////////////////////////////////


module TopLevel
#(parameter ROM_ADDR = 10,  DATA_BITS = 32 , MEM_ADDR = 10, PC_ADDR = 10)    //Rom的地��?线长、PC的数据位��?
(
    input wire clk,
    input wire rst,
    output wire [6:0] seg,    // segment driver signals, ordered { a, b, ..., g, dp }
    output wire dp,
    output  wire [8 - 1:0] an   // place enable signals, active on LOW
);
    wire [DATA_BITS - 1:0] pc;
    wire pcsel, pcen;
    wire [DATA_BITS - 1:0] pc_next;   //分别为程序计数器，pc的片选信号，pc的使能信��?,下一个时钟周期来临时的PC��?
    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0]imm_16;
    wire [25:0]imm_26;  //程序分片后的字段
    wire Jmp, Jr, Jal, Beq, Bne, MemToReg, MemWrite,  AluSrcB, RegWrite, RegDst, Syscall, SignedExt;  //控制器输出的控制信号，下��?
    wire ToLH, ExtrSigned, Sh, Sb, Bltz, Blez, Bgez, Bgtz, Equal;
    wire [3:0] AluOP;
    wire [1:0] ExtrWord;
    wire [1:0] ShamtSel;
    wire [1:0] LHToReg;
    wire [ROM_ADDR - 1:0] rom_addr;    //Rom的地��?
    wire [DATA_BITS - 1:0] rom_out;  //Rom输出的数据（即指令）
    wire [4:0] IR1;
    wire [4:0] IR2;   //Regfile输入1、输��?2
    wire [4:0] regfile_w;
    wire [DATA_BITS - 1:0] regfile_in;  //写使能时regfile的输��?
    wire [DATA_BITS - 1:0] regfile_out1;    //regfile的第��?个输��?
    wire [DATA_BITS - 1:0] regfile_out2;
    wire [DATA_BITS - 1:0] reg_a0;
    wire [DATA_BITS - 1:0] reg_v0;
    wire [DATA_BITS - 1:0] reg_ra;
    wire [DATA_BITS - 1:0] AluA;    //Alu的第��?个操作数
    wire [DATA_BITS - 1:0] AluB;    //Alu的第二个操作��?
    wire [4:0] ShamtOut;    //Alu的shamt字段
    wire [DATA_BITS - 1:0] AluResult;   //Alu的第��?个计算结��?
    wire [DATA_BITS - 1:0] AluResult2;  //Alu的第二个计算结果
    wire [MEM_ADDR - 1:0] mem_addr;
    wire [DATA_BITS - 1:0] mem_in;    //Ram的输入数��?
    wire [3:0] mem_sel;    //Ram的片选信��?
    wire [DATA_BITS - 1:0] mem_out;
    wire [DATA_BITS - 1:0] lo;
    wire [DATA_BITS - 1:0] hi;
    wire [DATA_BITS - 1:0] led_out;
    assign pcen = ~( (Syscall) & (reg_v0 != 32'd34) );
    DRegister #(.DATA_BITS(DATA_BITS)) ProcesserCounter(.clk(clk_N), .rst(rst), .enable(pcen), .data_in(pc_next), .data_out(pc));   //pcen未写

    PcInputAdapter #(.ADDR_BITS(DATA_BITS)) PcInput(.Jmp(Jmp), .Jr(Jr), .pcsel(pcsel), .pc(pc), .imm_16(imm_16), .imm_26(imm_26), .regfile_out1(regfile_out1), .pc_next(pc_next));

    InstructionWordSpliter InsWorSpl(.instr_word(rom_out), .opcode(opcode), .rs(rs), .rt(rt), .rd(rd), .shamt(shamt), .funct(funct), .immediate(imm_16), .instr_idx(imm_26));

    Controller  controller (.OP(opcode), .Func(funct), .Rt(rt), .Jmp(Jmp), .Jr(Jr), .Jal(Jal), .Beq(Beq), .Bne(Bne), .MemToReg(MemToReg), .MemWrite(MemWrite), .AluOP(AluOP), .AluSrcB(AluSrcB), .RegWrite(RegWrite),.RegDst(RegDst), .Syscall(Syscall), .SignedExt(SignedExt), .ExtrWord(ExtrWord), .ToLH(ToLH), .ExtrSigned(ExtrSigned), .Sh(Sh), .Sb(Sb), .ShamtSel(ShamtSel), .LHToReg(LHToReg), .Bltz(Bltz), .Blez(Blez), .Bgez(Bgez), .Bgtz(Bgtz));

    ROM #(.ADDR_BITS(ROM_ADDR),.DATA_BITS(DATA_BITS)) rom( .addr(pc[ROM_ADDR + 1:2]), .sel(1), .dout(rom_out) );

    RegfileInputAdapter #(.DATA_BITS(DATA_BITS)) regfileinput( .rs(rs), .rt(rt),.rd(rd), .alu_out(AluResult), .mem_out(mem_out), .lo(lo), .hi(hi), .addr_byte(AluResult[1:0]), .pc(pc+4), .Jal(Jal), .RegDst(RegDst), .MemToReg(MemToReg), .ExtrWord(ExtrWord), .ExtrSigned(ExtrSigned), .LHToReg(LHToReg), .IR1(IR1), .IR2(IR2), .W(regfile_w), .Din(regfile_in) );

    Regfile regfile (.IR1(IR1), .IR2(IR2), .W(regfile_w), .Din(regfile_in), .WE(RegWrite), .CLK(clk_N), .RST(rst), .OR1(regfile_out1), .OR2(regfile_out2), .a0(reg_a0), .v0(reg_v0), .ra(reg_ra));

    ALUInputAdapter #(.DATA_BITS(DATA_BITS)) aluinput(.RegOut1(regfile_out1), .RegOut2(regfile_out2), .Immediate(imm_16), .ShamtIn(shamt), .AluSrcB(AluSrcB), .ShamtSel(ShamtSel), .SignedExt(SignedExt), .AluA(AluA), .AluB(AluB), .ShamtOut(ShamtOut));

    ALU alu(.ALU_OP(AluOP), .X(AluA), .Y(AluB), .shamt(ShamtOut), .Result(AluResult), .Result2(AluResult2), .equal(Equal), .overflow());

    ConditionBranch #(.DATA_BITS(DATA_BITS)) conbra(.Beq(Beq), .Bne(Bne), .Equal(Equal), .Bltz(Bltz), .Bgtz(Bgtz), .Blez(Blez), .Bgez(Bgez), .regfile_out1(regfile_out1), .pcsel(pcsel));

    RamInputAdapter #(.ADDR_BITS(MEM_ADDR), .DATA_BITS(DATA_BITS)) raminput(.result1(AluResult), .regfile_out2(regfile_out2), .Sh(Sh), .Sb(Sb), .addr(mem_addr), .mem_in(mem_in), .mem_sel(mem_sel));

    Mem #(.MEM_ADDR_BITS(MEM_ADDR), .MEM_DATA_BITS(DATA_BITS)) mem (.addr(mem_addr), .data_in(mem_in), .str(MemWrite), .sel(mem_sel), .clk(clk_N), .ld(1), .clr(rst), .data_out(mem_out));

    LHSpecialRegisters #(.DATA_BITS(DATA_BITS)) lhreg(.result({AluResult2,AluResult}), .ready(1), .lo(lo), .hi(hi));

    divider #(.N(400)) div(.clk(clk),.clk_N(clk_N),.rst(rst));

    DRegister led(.clk(clk_N), .rst(rst), .enable(Syscall && (reg_v0 == 32'd34)), .data_in(reg_a0), .data_out(led_out));

    SevenSegmentDisplayDriver #(.DIGITS(8), .CLK_DIV(10) ) display(.din(led_out),.clk(clk_N),.rst(rst),.seg({seg,dp}), .ansel(an));
endmodule
