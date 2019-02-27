`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:  Xiaoguang Zhu
// Version: 2.21 22:49
//
// Working in simulation.
//////////////////////////////////////////////////////////////////////////////////


module PipelineTopLevel
#(parameter ROM_ADDR = 10,  DATA_BITS = 32 , MEM_ADDR = 6, PC_ADDR = 10)
(
    input wire clk,
    input wire btnL,    // rst
    input wire btnR,    // go
    input wire btnU,    // freq up
    input wire btnD,    // freq down
    input wire btnC,    // disp cont switch
    input wire [15:0] sw,
    output wire [15:0] led,
    output wire [6:0] seg,    // segment driver signals, ordered { a, b, ..., g, dp }
    output wire dp,
    output wire [7:0] an   // place enable signals, active on LOW
);

wire [DATA_BITS-1:0]result_1_out_3;
wire [DATA_BITS-1:0]result_2_out_3;
wire [DATA_BITS-1:0]regfile_out2_out_3;
wire [5:0] write_out_3;
wire Jal_out_3;
wire Load_out_3;
wire MemToReg_out_3;
wire MemWrite_out_3;
wire RegWrite_out_3;
wire [1:0]ExtrWord_out_3;
wire ToLH_out_3;
wire ToLH_out_2;
wire ExtrSigned_out_3;
wire Sh_out_3;
wire Sb_out_3;
wire [1:0]LHToReg_out_3;
wire [DATA_BITS-1:0]PC_out_3;
wire [DATA_BITS-1:0]IR_out_3;
wire [DATA_BITS - 1:0] lo_out_3;
wire [DATA_BITS - 1:0] hi_out_3;
wire Load_out_4;
wire LoadUse1, LoadUse2, LoadUse;
assign LoadUse = LoadUse2 | LoadUse1 | ToLH_out_3 | CP0ToReg_out_3;
wire Syscall_out_3;
wire Syscall_out_4;
wire ToLH_out_4;
wire [31:0] EXRegister2Data_out3;
wire [31:0] EXRegister2Data_out4;
/******************* IF *********************/
wire [DATA_BITS-1:0]IR_out_4;
wire [DATA_BITS - 1:0] pc;
wire [DATA_BITS - 1:0]PC_out_2;
wire [DATA_BITS - 1:0] pc_next;
wire [DATA_BITS - 1:0]v0_out_2;
wire Syscall_out_2;
wire pcsel, pcen;
wire rst, go, clk_N;
assign rst = btnL;
assign go = btnR;
assign led[15] = clk_N;
assign led[14] = !pcen;
assign led[13] = Syscall_out_4;
assign led[0] = RegWrite_out_4;

//assign pc_next = pc+4;
assign pcen = ( ~( (Syscall_out_4) & ( v0 != 32'd34) ) ) | go;
wire [DATA_BITS - 1:0] EXRegister1Data;
wire [DATA_BITS - 1:0] EXRegister2Data;
wire Jmp, Jr;
wire Jmp_out_2;
wire Jr_out_2;
wire [15:0]imm_16_out_2;
wire [25:0]imm_26_out_2;
wire [15:0]imm_16;
wire [25:0]imm_26;
wire [DATA_BITS - 1:0]regfile_out1_out_2;

wire INT;
wire CP0ToReg;
wire CP0ToReg_out_2;
wire CP0ToReg_out_3;
wire CP0ToReg_out_4;
wire [31:0] CP0_out;
wire [31:0] CP0_out_2;
wire [31:0] CP0_out_3;
wire [31:0] CP0_out_4;
wire Eret;
wire [31:0] EPC_out;

PcInputAdapter #(.ADDR_BITS(DATA_BITS)) PcInput(
    .Jmp(Jmp_out_2), 
    .Jr(Jr_out_2), 
    .pcsel(pcsel), 
    .pc(pc), 
    .imm_16(imm_16_out_2), 
    .imm_26(imm_26_out_2), 
    .regfile_out1(EXRegister1Data), 
    .EPC_out(EPC_out),
    .INT(INT),
    .Eret(Eret),
    .pc_next(pc_next)
 );

DRegister #(.DATA_BITS(DATA_BITS)) ProcesserCounter(.clk(clk_N), .rst(rst),.enable(pcen&(~LoadUse)), .data_in(pc_next), .data_out(pc));   //data_in后续要改，暂时不考虑跳转

wire [DATA_BITS - 1:0] IR_in;
ROM #(.ADDR_BITS(ROM_ADDR),.DATA_BITS(DATA_BITS)) rom( .addr(pc[ROM_ADDR + 1:2]), .sel(1), .dout(IR_in) );
wire branch;

wire [DATA_BITS - 1:0] PC_out_1;
wire [DATA_BITS - 1:0] IR_out_1;
IF_ID if_id(
    .clk(clk_N),
    .PC_in(pc),
    .IR_in(IR_in),
    .zero(rst | branch | INT | Eret),
    .stall(pcen&(~LoadUse)),
    .PC_out(PC_out_1),
    .IR_out(IR_out_1)
);

/***************** ID ***********************/

wire [5:0] opcode;
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [4:0] shamt;
wire [5:0] funct;
wire [5:0] ReadRegister1Num;
wire [5:0] ReadRegister2Num;
wire [5:0] WriteRegisterNum;
wire [5:0] ReadRegister1Num_out_2;
wire [5:0] ReadRegister2Num_out_2;
InstructionWordSpliter InsWorSpl(.instr_word(IR_out_1), .opcode(opcode), .rs(rs), .rt(rt), .rd(rd), .shamt(shamt), .funct(funct), .immediate(imm_16), .instr_idx(imm_26));
ReadWriteRegister ReaWriReg(
    .OP(opcode),    //指令op字段
    .Func(funct),  //指令function字段
    .rs(rs),
    .rt(rt),          //指令的Rt字段，用来确定是哪一种跳转指��?
    .rd(rd),
    .ReadRegister1(ReadRegister1Num),
    .ReadRegister2(ReadRegister2Num),
    .WriteRegister(WriteRegisterNum)
    );
wire Jal, Beq, Bne, MemToReg, MemWrite,  AluSrcB, RegWrite, RegDst, Syscall, SignedExt;  //鎺у埗鍣ㄨ緭鍑虹殑鎺у埗淇�?�彿锛屼笅锟斤拷?
wire ToLH, ExtrSigned, Sh, Sb, Bltz, Blez, Bgez, Bgtz, Load;

wire [3:0] AluOP;
wire [1:0] ExtrWord;
wire [1:0] ShamtSel;
wire [1:0] LHToReg;
Controller  controller (.OP(opcode), .Func(funct), .Rt(rt), .Jmp(Jmp), .Jr(Jr), .Jal(Jal), .Beq(Beq), .Bne(Bne), .MemToReg(MemToReg), .MemWrite(MemWrite), .AluOP(AluOP), .AluSrcB(AluSrcB), .RegWrite(RegWrite),.RegDst(RegDst), .Syscall(Syscall), .SignedExt(SignedExt), .ExtrWord(ExtrWord), .ToLH(ToLH), .ExtrSigned(ExtrSigned), .Sh(Sh), .Sb(Sb), .ShamtSel(ShamtSel), .LHToReg(LHToReg), .Bltz(Bltz), .Blez(Blez), .Bgez(Bgez), .Bgtz(Bgtz), .Load(Load));
CP0 cp0(
    .clk(clk_N),
    .rst(rst),
    .id_instr(IR_out_1),   // instruction word from ID / EX
    .wb_instr(IR_out_4),
    .wb_din(EXRegister2Data_out4),
    .ex_pc(pc - 8),
    .intsrc(sw[2:0]),     // interrupt source
    .INT(INT),        // interrupt signal to CPU
    .CP0ToReg(CP0ToReg),
    .id_dout(CP0_out),    // [combinational]
    .epc_out(EPC_out),
    .eret(Eret)
);
wire [DATA_BITS - 1:0] result_1_out_4;
wire [DATA_BITS - 1:0] result_2_out_4;
wire [DATA_BITS - 1:0] mem_out_out_4;
wire [DATA_BITS - 1:0] lo_out_4;
wire [DATA_BITS - 1:0] hi_out_4;
wire [DATA_BITS - 1:0] PC_out_4;
wire Jal_out_4, MemToReg_out_4, ExtrSigned_out_4;
wire [1:0] ExtrWord_out_4;
wire [1:0] LHToReg_out_4;
wire [4:0] IR1;
wire [4:0] IR2;
wire [4:0] write;
wire [DATA_BITS - 1:0] regfile_in;
wire [DATA_BITS - 1:0] lo;
wire [DATA_BITS - 1:0] hi;
wire [DATA_BITS - 1:0] mem_to_reg;
RegfileInputAdapter #(.DATA_BITS(DATA_BITS)) regfileinput( 
    .rs(rs), 
    .rt(rt),
    .rd(rd),  
    .Jal(Jal), 
    .RegDst(RegDst), 
    .IR1(IR1), 
    .IR2(IR2), 
    .W(write)
 );
////Jal是当前Jal
wire [5:0] write_out_4;
wire RegWrite_out_4;
wire [DATA_BITS - 1:0] regfile_out1;
wire [DATA_BITS - 1:0] regfile_out2;
wire [DATA_BITS - 1:0] a0;
wire [DATA_BITS - 1:0] v0;
wire [DATA_BITS - 1:0] ra;
Regfile regfile (
    .IR1(IR1), 
    .IR2(IR2), 
    .W(write_out_4[4:0]), 
    .Din(mem_to_reg), 
    .WE(RegWrite_out_4 | CP0ToReg_out_4), //有RegWriter和CP0ToReg信号时往寄存器堆写数�? 
    .CLK(clk_N), 
    .RST(rst), 
    .OR1(regfile_out1), 
    .OR2(regfile_out2), 
    .a0(a0), 
    .v0(v0), 
    .ra(ra));


LHSpecialRegisters #(.DATA_BITS(DATA_BITS)) lhreg(.clk(clk_N),.result({result_2_out_4,result_1_out_4}), .ready(ToLH_out_4), .lo(lo), .hi(hi));

wire [4:0]shamt_out_2;

wire [DATA_BITS - 1:0]regfile_out2_out_2;
wire [DATA_BITS - 1:0]a0_out_2;
wire [DATA_BITS - 1:0]ra_out_2;
wire [5:0] write_out_2;

wire Load_out_2;
wire Jal_out_2;
wire Beq_out_2;
wire Bne_out_2;
wire MemToReg_out_2;
wire MemWrite_out_2;
wire [3:0]AluOP_out_2;
wire AluSrcB_out_2;
wire RegWrite_out_2;
wire [1:0]ExtrWord_out_2;
wire ExtrSigned_out_2;
wire Sh_out_2;
wire Sb_out_2;
wire [1:0]ShamtSel_out_2;
wire [1:0]LHToReg_out_2;
wire Bltz_out_2;
wire Blez_out_2;
wire Bgez_out_2;
wire Bgtz_out_2;
wire SignedExt_out_2;
wire [DATA_BITS - 1:0] lo_out_2;
wire [DATA_BITS - 1:0] hi_out_2;
wire [DATA_BITS - 1:0]IR_out_2;
ID_EX id_ex(
    .clk(clk_N),
    .zero(rst | branch | INT | Eret),
    .stall(pcen&(~LoadUse)),
    .PC_in(PC_out_1),
    .IR_in(IR_out_1),
    .Jmp(Jmp),        //Jmp信号，用来控制PC跳转以及统计无条件跳转次��?,PC = immediate
    .Jr(Jr),         //Jr信号，用来控制PC跳转，此时PC=PC+REG[Rs]
    .Jal(Jal),        //Jal信号，此时PC跳转和Jmp��?样，但是要将下一条指令的地址存入ra(31号寄存器)
    .Beq(Beq),        //Beq信号，控制有条件跳转
    .Bne(Bne),        //Bne信号，控制有条件跳转
    .MemToReg(MemToReg),   //寄存器堆写入数据的片选信号，��?1选Memory，为0选Alu的结��?
    .MemWrite(MemWrite),   //Memory写使��?
    .AluOP(AluOP),      //Alu功能选择信号
    .AluSrcB(AluSrcB),    //Alu第二个操作数选择信号
    .RegWrite(RegWrite),   //寄存器堆写使��?
    .Syscall(Syscall),    //系统调用指令
    .ExtrWord(ExtrWord),   //Din片�?�信号，��?01时�?�择字扩展后的数输入寄存器堆，为10选择双字扩展后的数输��?
    .ToLH(ToLH),       //HI,LO寄存器使能信��?
    .ExtrSigned(ExtrSigned),   //字扩展�?�双字扩展方式�?�择信号，为1时进行符号扩展，��?0进行0扩展
    .Sh(Sh),
    .Sb(Sb),
    .ShamtSel(ShamtSel), //Shamt字段选择信号，为10时输��?16��?0x10），��?01时输出Rs��?5位，否则为指令的shamt字段
    .LHToReg(LHToReg),  //Din片�?�信号，��?01时输出LO寄存器数值，��?10时输出HI寄存器数��?
    .Bltz(Bltz),
    .Blez(Blez),
    .Bgez(Bgez),
    .Bgtz(Bgtz),
    .SignedExt(SignedExt),
    .imm_16(imm_16),
    .imm_26(imm_26),
    .ld(Load),
    .ReadRegister1Num(ReadRegister1Num),
    .ReadRegister2Num(ReadRegister2Num),
    .regfile_out1(regfile_out1),
    .regfile_out2(regfile_out2),
    .write(WriteRegisterNum),
    .a0(a0),
    .v0(v0),
    .ra(ra),
    .lo(lo),
    .hi(hi),
    .shamt(shamt),
    .CP0ToReg(CP0ToReg),
    .CP0_out(CP0_out),
    .CP0_out_out(CP0_out_2),
    .CP0ToReg_out(CP0ToReg_out_2),
    .shamt_out(shamt_out_2),
    .imm_16_out(imm_16_out_2),
    .imm_26_out(imm_26_out_2),
    .regfile_out1_out(regfile_out1_out_2),
    .regfile_out2_out(regfile_out2_out_2),
    .a0_out(a0_out_2),
    .v0_out(v0_out_2),
    .ra_out(ra_out_2),
    .lo_out(lo_out_2),
    .hi_out(hi_out_2),
    .write_out(write_out_2),
    .Jmp_out(Jmp_out_2),
    .Jr_out(Jr_out_2),
    .Jal_out(Jal_out_2),
    .Beq_out(Beq_out_2),
    .Bne_out(Bne_out_2),
    .MemToReg_out(MemToReg_out_2),
    .MemWrite_out(MemWrite_out_2),
    .AluOP_out(AluOP_out_2),
    .AluSrcB_out(AluSrcB_out_2),
    .RegWrite_out(RegWrite_out_2),
    .Syscall_out(Syscall_out_2),
    .ExtrWord_out(ExtrWord_out_2),
    .ToLH_out(ToLH_out_2),
    .ExtrSigned_out(ExtrSigned_out_2),
    .Sh_out(Sh_out_2),
    .Sb_out(Sb_out_2),
    .ShamtSel_out(ShamtSel_out_2),
    .LHToReg_out(LHToReg_out_2),
    .Bltz_out(Bltz_out_2),
    .Blez_out(Blez_out_2),
    .Bgez_out(Bgez_out_2),
    .Bgtz_out(Bgtz_out_2),
    .SignedExt_out(SignedExt_out_2),
    .PC_out(PC_out_2),
    .IR_out(IR_out_2),
    .ld_out(Load_out_2),
    .ReadRegister1Num_out(ReadRegister1Num_out_2),
    .ReadRegister2Num_out(ReadRegister2Num_out_2)
);

/********************* EX ********************/

wire [DATA_BITS - 1:0] AluA;    //Alu的第???个操作数
wire [DATA_BITS - 1:0] AluB;    //Alu的第二个操作???

wire [4:0] ShamtOut;
wire [31:0] EXData1;
wire [31:0] EXData2;
RedirectionSel rd1 //寄存��?1的重定向
(
.ReadRegisterNumber(ReadRegister1Num_out_2),    //执行阶段的读寄存器编��?
.MEMRegisterNumber(write_out_3),     //访存阶段的写寄存器编��?
.WBRegisterNumber(write_out_4),      //写回阶段的读寄存器编��?
.ReadRegisterData(regfile_out1_out_2),     //执行阶段读寄存器的�??
.MEMAluResultData(result_1_out_3),     //访存阶段的Alu的结果�??
.WBAluResultData(result_1_out_4),      //写回阶段的Alu的结果�??
.WBReadData(mem_to_reg),           //写回阶段的mem中读取的��?
.MEMLoad(MemToReg_out_3|LHToReg_out_3),                     //访存阶段的指令的Load信号，为1时说明该指令为load指令
.WBLoad(MemToReg_out_4),                      //写回阶段的指令的Load信号，为1时说明该指令为load指令
.LoadUse(LoadUse1),                  //��?1时说明出现了LoadStore的情况，��?要把前三个流水锁存并把第四个流水清空
.EXRegisterData(EXData1)        //执行阶段的寄存器的最终�??
);
RedirectionSel rd2 //寄存��?1的重定向
(
.ReadRegisterNumber(ReadRegister2Num_out_2),    //执行阶段的读寄存器编��?
.MEMRegisterNumber(write_out_3),     //访存阶段的写寄存器编��?
.WBRegisterNumber(write_out_4),      //写回阶段的读寄存器编��?
.ReadRegisterData(regfile_out2_out_2),     //执行阶段读寄存器的�??
.MEMAluResultData(result_1_out_3),     //访存阶段的Alu的结果�??
.WBAluResultData(result_1_out_4),      //写回阶段的Alu的结果�??
.WBReadData(mem_to_reg),           //写回阶段的mem中读取的��?
.MEMLoad(MemToReg_out_3|LHToReg_out_3),                     //访存阶段的指令的Load信号，为1时说明该指令为load指令
.WBLoad(MemToReg_out_4),                      //写回阶段的指令的Load信号，为1时说明该指令为load指令
.LoadUse(LoadUse2),                  //��?1时说明出现了LoadStore的情况，��?要把前三个流水锁存并把第四个流水清空
.EXRegisterData(EXData2)        //执行阶段的寄存器的最终�??
);

LoadUse loaduse
(
.EXData1(EXData1),
.EXData2(EXData2),
.clk(clk_N),
.rst(rst),
.LoadUse1(LoadUse1),
.LoadUse2(LoadUse2),
.EXRegister1Data(EXRegister1Data),
.EXRegister2Data(EXRegister2Data)
);
//
// // assign led[4] = write_out_4[4];
// assign led[3] = EXRegister2Data[3];
// assign led[2] = EXRegister2Data[2];
// assign led[1] = EXRegister2Data[1];
// assign led[0] = EXRegister2Data[0];

ALUInputAdapter #(.DATA_BITS(DATA_BITS)) aluinput(.RegOut1(EXRegister1Data), .RegOut2(EXRegister2Data), .Immediate(imm_16_out_2), .ShamtIn(shamt_out_2), .AluSrcB(AluSrcB_out_2), .ShamtSel(ShamtSel_out_2), .SignedExt(SignedExt_out_2), .AluA(AluA), .AluB(AluB), .ShamtOut(ShamtOut));

wire [DATA_BITS - 1:0]result_1;
wire [DATA_BITS - 1:0]result_2;
wire Equal;

assign branch = pcsel | Jmp_out_2;
ALU alu(.ALU_OP(AluOP_out_2), .X(AluA), .Y(AluB), .shamt(ShamtOut), .Result(result_1), .Result2(result_2), .equal(Equal), .overflow());

ConditionBranch #(.DATA_BITS(DATA_BITS)) conbra(.Beq(Beq_out_2), .Bne(Bne_out_2), .Equal(Equal), .Bltz(Bltz_out_2), .Bgtz(Bgtz_out_2), .Blez(Blez_out_2), .Bgez(Bgez_out_2), .regfile_out1(EXRegister1Data), .pcsel(pcsel));


EX_MEM ex_mem(
    .clk(clk_N),
    .zero(rst | LoadUse),
    .stall(pcen),
    .PC_in(PC_out_2),
    .IR_in(IR_out_2),
    .Jal(Jal_out_2),
    .ld(Load_out_2),
    .Syscall(Syscall_out_2),
    .MemToReg(MemToReg_out_2),
    .MemWrite(MemWrite_out_2),
    .RegWrite(RegWrite_out_2),
    .ExtrWord(ExtrWord_out_2),
    .ToLH(ToLH_out_2),
    .ExtrSigned(ExtrSigned_out_2),
    .Sh(Sh_out_2),
    .Sb(Sb_out_2),
    .LHToReg(LHToReg_out_2),
    .regfile_out2(EXRegister2Data),
    .write(write_out_2),
    .result_1(result_1),
    .result_2(result_2),
    .lo(lo_out_2),
    .hi(hi_out_2),
    .CP0ToReg(CP0ToReg_out_2),
    .CP0_out(CP0_out_2),
    .CP0_out_out(CP0_out_3),
    .CP0ToReg_out(CP0ToReg_out_3),
    .result_1_out(result_1_out_3),
    .result_2_out(result_2_out_3),
    .EXRegister2Data(EXRegister2Data),
    .regfile_out2_out(regfile_out2_out_3),
    .lo_out(lo_out_3),
    .hi_out(hi_out_3),
    .write_out(write_out_3),
    .Jal_out(Jal_out_3),
    .MemToReg_out(MemToReg_out_3),
    .MemWrite_out(MemWrite_out_3),
    .RegWrite_out(RegWrite_out_3),
    .ExtrWord_out(ExtrWord_out_3),
    .ToLH_out(ToLH_out_3),
    .ExtrSigned_out(ExtrSigned_out_3),
    .Sh_out(Sh_out_3),
    .Sb_out(Sb_out_3),
    .LHToReg_out(LHToReg_out_3),
    .PC_out(PC_out_3),
    .IR_out(IR_out_3),
    .ld_out(Load_out_3),
    .Syscall_out(Syscall_out_3),
    .EXRegister2Data_out(EXRegister2Data_out3)
);

/********************* MEM ********************/

wire [MEM_ADDR - 1:0] mem_addr;
wire [DATA_BITS - 1:0] mem_in;    //Ram的输入数???
wire [3:0] mem_sel;
RamInputAdapter #(.ADDR_BITS(MEM_ADDR), .DATA_BITS(DATA_BITS)) raminput(.result1(result_1_out_3), .regfile_out2(regfile_out2_out_3), .Sh(Sh_out_3), .Sb(Sb_out_3), .addr(mem_addr), .mem_in(mem_in), .mem_sel(mem_sel));

wire [DATA_BITS - 1:0] mem_out;
Mem #(.MEM_ADDR_BITS(MEM_ADDR), .MEM_DATA_BITS(DATA_BITS)) mem (.addr(mem_addr), .data_in(mem_in), .str(MemWrite_out_3), .sel(mem_sel), .clk(clk_N), .ld(1), .clr(rst), .data_out(mem_out));


MEM_WB mem_wb(
    .clk(clk_N),
    .zero(rst),
    .stall(pcen),
    .PC_in(PC_out_3),
    .IR_in(IR_out_3),
    .Jal(Jal_out_3),
    .ld(Load_out_3),
    .Syscall(Syscall_out_3),
    .MemToReg(MemToReg_out_3),
    .RegWrite(RegWrite_out_3),
    .ExtrWord(ExtrWord_out_3),
    .ToLH(ToLH_out_3),
    .ExtrSigned(ExtrSigned_out_3),
    .LHToReg(LHToReg_out_3),
    .alu_out(result_1_out_3),
    .alu_out2(result_2_out_3),
    .mem_out(mem_out),
    .lo(lo_out_3),
    .hi(hi_out_3),
    .write(write_out_3),
    .EXRegister2Data(EXRegister2Data_out3),
    .CP0ToReg(CP0ToReg_out_3),
    .CP0_out(CP0_out_3),
    .CP0_out_out(CP0_out_4),
    .CP0ToReg_out(CP0ToReg_out_4),
    .EXRegister2Data_out(EXRegister2Data_out4),
    .alu_out_out(result_1_out_4),
    .alu_out2_out(result_2_out_4),
    .mem_out_out(mem_out_out_4),
    .lo_out(lo_out_4),
    .hi_out(hi_out_4),
    .write_out(write_out_4),
    .Jal_out(Jal_out_4),
    .MemToReg_out(MemToReg_out_4),
    .RegWrite_out(RegWrite_out_4),
    .ExtrWord_out(ExtrWord_out_4),
    .ToLH_out(ToLH_out_4),
    .ExtrSigned_out(ExtrSigned_out_4),
    .LHToReg_out(LHToReg_out_4),
    .PC_out(PC_out_4),
    .IR_out(IR_out_4),
    .ld_out(Load_out_4),
    .Syscall_out(Syscall_out_4)
);

MemToReg #(.DATA_BITS(DATA_BITS)) 
memtoreg (
    .alu_out(result_1_out_4), 
    .mem_out(mem_out_out_4), 
    .lo(lo),
    .hi(hi), 
    .addr_byte(result_1_out_4[1:0]), 
    .pc(PC_out_4), 
    .Jal_out_4(Jal_out_4), 
    .MemToReg(MemToReg_out_4), 
    .ExtrWord(ExtrWord_out_4), 
    .ExtrSigned(ExtrSigned_out_4), 
    .LHToReg(LHToReg_out_4), 
    .CP0_out(CP0_out_4),
    .CP0ToReg(CP0ToReg_out_4),
    .Din(mem_to_reg) 
 );
// TODO: syscall 指令涉及数据相关
wire [31:0] led_show;
wire [31:0] led_out;
wire [31:0] TotalCycle;
wire [31:0] CoBranchCycle;
wire [31:0] UnBranchCycle;
DRegister leddisp (.clk(clk_N), .rst(rst), .enable(Syscall_out_4 && (v0 == 32'd34)), .data_in(a0), .data_out(led_out));



SevenSegmentDisplayDriver #(.DIGITS(8), .CLK_DIV(4000) ) display(.din(led_show),.clk(clk),.rst(rst),.seg({seg,dp}), .ansel(an));

CycleStatistic statics (
    .pcen(pcen),
    .Jmp(Jmp_out_2),
    .clk(clk_N),
    .rst(rst),
    .pcsel(pcsel),
    .TotalCycle(TotalCycle),
    .CoBranchCycle(CoBranchCycle),
    .UnBranchCycle(UnBranchCycle)
);
LedSwitcher switcher(
    .LedData(led_out),
    .TotalCycle(TotalCycle),
    .CoBranchCycle(CoBranchCycle),
    .UnBranchCycle(UnBranchCycle),
    .CLK(clk_N),
    .RST(rst),
    .Change(btnC),
    .LedShow(led_show)
    );
ClkSpeedSwitcher #(
    .LEVEL_1_INDEX(100),   // 1 Hz
    .LEVEL_2_INDEX(24_999_999),   // 2 Hz
    .LEVEL_3_INDEX(12_499_999),   // 4 Hz
    .LEVEL_4_INDEX(6_249_999),   // 8 Hz
    .LEVEL_5_INDEX(3_124_999),   // 16 Hz
    .LEVEL_6_INDEX(1_562_499),   // 32 Hz
    .LEVEL_TOP_INDEX(1)             // 0 seems to be unstable
) clkswitcher (
    .clk(clk),        // fastest system clock available
    .btn_faster(btnU), // buttons for going faster / slower
    .btn_slower(btnD),
    .clk_N(clk_N),      // divided clock
    // debug outputs
    .curr_level()
);

endmodule
