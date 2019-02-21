`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:  Yuhang Chen
// Version: 2.20 20:30
//
//
//////////////////////////////////////////////////////////////////////////////////



module Top
#(parameter ROM_ADDR = 10,  DATA_BITS = 32 , MEM_ADDR = 10, PC_ADDR = 10)    //Rom鐨勫湴锟斤拷?绾块暱銆丳C鐨勬暟鎹綅锟斤拷?
(
    input wire clk,
    input wire btnL,
    input wire btnR,
    //input wire btnU,
    //input wire btnD,
    //input wire btnC,
    //output wire myled,
    //output wire [6:0] seg,    // segment driver signals, ordered { a, b, ..., g, dp }
    //output wire dp,
    //output  wire [8 - 1:0] an   // place enable signals, active on LOW
    output [DATA_BITS - 1:0] regfile_in
);
    wire [DATA_BITS - 1:0] pc,PC_in;
	wire [DATA_BITS - 1:0]v0_out_2;
	wire Syscall_out_2;
	wire pcsel, pcen;
	wire rst,go;
    assign rst = btnL;
    assign go = btnR;
    assign PC_in = pc+4;    
	assign pcen = ( ~( (Syscall_out_2) & (v0_out_2 != 32'd34) ) ) | go;
    DRegister #(.DATA_BITS(DATA_BITS)) ProcesserCounter(.clk(clk), .rst(rst), .enable(pcen), .data_in(PC_in), .data_out(pc));   //data_in后续要改，暂时不考虑跳转
	
	
	wire [DATA_BITS - 1:0] IR_in;
    ROM #(.ADDR_BITS(ROM_ADDR),.DATA_BITS(DATA_BITS)) rom( .addr(pc[ROM_ADDR + 1:2]), .sel(1), .dout(IR_in) );
	
	
    wire [DATA_BITS - 1:0]PC_out_1,IR_out_1;
    IF_ID if_id(.clk(clk),.PC_in(PC_in),.IR_in(IR_in),.PC_out(PC_out_1),.IR_out(IR_out_1),.zero(0),.stall(1));
  
  
  
    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0]imm_16;
    wire [25:0]imm_26;
    InstructionWordSpliter InsWorSpl(.instr_word(IR_out_1), .opcode(opcode), .rs(rs), .rt(rt), .rd(rd), .shamt(shamt), .funct(funct), .immediate(imm_16), .instr_idx(imm_26));
	
	
	wire Jmp, Jr, Jal, Beq, Bne, MemToReg, MemWrite,  AluSrcB, RegWrite, RegDst, Syscall, SignedExt;  //鎺у埗鍣ㄨ緭鍑虹殑鎺у埗淇″彿锛屼笅锟斤拷?
    wire ToLH, ExtrSigned, Sh, Sb, Bltz, Blez, Bgez, Bgtz;
    wire [3:0] AluOP;
    wire [1:0] ExtrWord;
    wire [1:0] ShamtSel;
    wire [1:0] LHToReg;
    Controller  controller (.OP(opcode), .Func(funct), .Rt(rt), .Jmp(Jmp), .Jr(Jr), .Jal(Jal), .Beq(Beq), .Bne(Bne), .MemToReg(MemToReg), .MemWrite(MemWrite), .AluOP(AluOP), .AluSrcB(AluSrcB), .RegWrite(RegWrite),.RegDst(RegDst), .Syscall(Syscall), .SignedExt(SignedExt), .ExtrWord(ExtrWord), .ToLH(ToLH), .ExtrSigned(ExtrSigned), .Sh(Sh), .Sb(Sb), .ShamtSel(ShamtSel), .LHToReg(LHToReg), .Bltz(Bltz), .Blez(Blez), .Bgez(Bgez), .Bgtz(Bgtz));
	
	wire [DATA_BITS - 1:0]result_1_out_4;
	wire [DATA_BITS - 1:0] mem_out_out_4;
    wire [DATA_BITS - 1:0] lo_out_4;
    wire [DATA_BITS - 1:0] hi_out_4;
	wire [DATA_BITS - 1:0] PC_out_4;
	wire Jal_out_4,MemToReg_out_4,ExtrSigned_out_4;
	wire [1:0]ExtrWord_out_4;
	wire [1:0]LHToReg_out_4;
	wire [4:0] IR1;
    wire [4:0] IR2;
	wire [4:0] write;
	//wire [DATA_BITS - 1:0] regfile_in;
    RegfileInputAdapter #(.DATA_BITS(DATA_BITS)) regfileinput( .rs(rs), .rt(rt),.rd(rd), .alu_out(result_1_out_4), .mem_out(mem_out_out_4), .lo(lo_out_4), .hi(hi_out_4), .addr_byte(result_1_out_4[1:0]), .pc(PC_out_4), .Jal(Jal_out_4), .RegDst(RegDst), .MemToReg(MemToReg_out_4), .ExtrWord(ExtrWord_out_4), .ExtrSigned(ExtrSigned_out_4), .LHToReg(LHToReg_out_4), .IR1(IR1), .IR2(IR2), .W(write), .Din(regfile_in) );
	
	wire [4:0] write_out_4;
	wire RegWrite_out_4;
	wire [DATA_BITS - 1:0] regfile_out1;
	wire [DATA_BITS - 1:0] regfile_out2;
	wire [DATA_BITS - 1:0] a0;
	wire [DATA_BITS - 1:0] v0;
	wire [DATA_BITS - 1:0] ra;
    Regfile regfile (.IR1(IR1), .IR2(IR2), .W(write_out_4), .Din(regfile_in), .WE(RegWrite_out_4), .CLK(clk), .RST(rst), .OR1(regfile_out1), .OR2(regfile_out2), .a0(a0), .v0(v0), .ra(ra));

	
	wire [4:0]shamt_out_2;
	wire [15:0]imm_16_out_2;
	wire [25:0]imm_26_out_2;
	wire [DATA_BITS - 1:0]regfile_out1_out_2;
	wire [DATA_BITS - 1:0]regfile_out2_out_2;
	wire [DATA_BITS - 1:0]a0_out_2;
	wire [DATA_BITS - 1:0]ra_out_2;
	wire write_out_2;
	wire Jmp_out_2;
	wire Jr_out_2;
	wire Jal_out_2;
	wire Beq_out_2;
	wire Bne_out_2;
	wire MemToReg_out_2;
	wire MemWrite_out_2;
	wire [3:0]AluOP_out_2;
	wire AluSrcB_out_2;
	wire RegWrite_out_2;
	wire [1:0]ExtrWord_out_2;
	wire ToLH_out_2;
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
	wire [DATA_BITS - 1:0]PC_out_2;
	wire [DATA_BITS - 1:0]IR_out_2;
    ID_EX id_ex(
        .clk(clk),
        .zero(0),
        .stall(1),
        .PC_in(PC_out_1),
        .IR_in(IR_out_1),
        .Jmp(Jmp),        //Jmp信号，用来控制PC跳转以及统计无条件跳转次数,PC = immediate
        .Jr(Jr),         //Jr信号，用来控制PC跳转，此时PC=PC+REG[Rs]
        .Jal(Jal),        //Jal信号，此时PC跳转和Jmp一样，但是要将下一条指令的地址存入ra(31号寄存器)
        .Beq(Beq),        //Beq信号，控制有条件跳转
        .Bne(Bne),        //Bne信号，控制有条件跳转
        .MemToReg(MemToReg),   //寄存器堆写入数据的片选信号，为1选Memory，为0选Alu的结果
        .MemWrite(MemWrite),   //Memory写使能
        .AluOP(AluOP),      //Alu功能选择信号
        .AluSrcB(AluSrcB),    //Alu第二个操作数选择信号
        .RegWrite(RegWrite),   //寄存器堆写使能
        .Syscall(Syscall),    //系统调用指令
        .ExtrWord(ExtrWord),   //Din片选信号，为01时选择字扩展后的数输入寄存器堆，为10选择双字扩展后的数输入
        .ToLH(ToLH),       //HI,LO寄存器使能信号
        .ExtrSigned(ExtrSigned),   //字扩展、双字扩展方式选择信号，为1时进行符号扩展，为0进行0扩展
        .Sh(Sh),
        .Sb(Sb),
        .ShamtSel(ShamtSel), //Shamt字段选择信号，为10时输出16（0x10），为01时输出Rs后5位，否则为指令的shamt字段
        .LHToReg(LHToReg),  //Din片选信号，为01时输出LO寄存器数值，为10时输出HI寄存器数值
        .Bltz(Bltz),
        .Blez(Blez),        
        .Bgez(Bgez),
        .Bgtz(Bgtz),
        .SignedExt(SignedExt),
        .imm_16(imm_16),
        .imm_26(imm_26),
        .regfile_out1(regfile_out1),
        .regfile_out2(regfile_out2),
        .write(write),
        .a0(a0),
        .v0(v0),
        .ra(ra),
        .shamt(shamt),
        .shamt_out(shamt_out_2),
        .imm_16_out(imm_16_out_2),
        .imm_26_out(imm_26_out_2),
        .regfile_out1_out(regfile_out1_out_2),
        .regfile_out2_out(regfile_out2_out_2),
        .a0_out(a0_out_2),
        .v0_out(v0_out_2),
        .ra_out(ra_out_2),
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
        .IR_out(IR_out_2)
    );
	
	wire [DATA_BITS - 1:0] AluA;    //Alu的第???个操作数
    wire [DATA_BITS - 1:0] AluB;    //Alu的第二个操作???
    wire [4:0] ShamtOut;
    ALUInputAdapter #(.DATA_BITS(DATA_BITS)) aluinput(.RegOut1(regfile_out1_out_2), .RegOut2(regfile_out2_out_2), .Immediate(imm_16_out_2), .ShamtIn(shamt_out_2), .AluSrcB(AluSrcB_out_2), .ShamtSel(ShamtSel_out_2), .SignedExt(SignedExt_out_2), .AluA(AluA), .AluB(AluB), .ShamtOut(ShamtOut));
	
	wire [DATA_BITS - 1:0]result_1;
	wire [DATA_BITS - 1:0]result_2;
	wire Equal;
    ALU alu(.ALU_OP(AluOP_out_2), .X(AluA), .Y(AluB), .shamt(ShamtOut), .Result(result_1), .Result2(result_2), .equal(Equal), .overflow());
	
    ConditionBranch #(.DATA_BITS(DATA_BITS)) conbra(.Beq(Beq_out_2), .Bne(Bne_out_2), .Equal(Equal), .Bltz(Bltz_out_2), .Bgtz(Bgtz_out_2), .Blez(Blez_out_2), .Bgez(Bgez_out_2), .regfile_out1(regfile_out1_out_2), .pcsel(pcsel));
    
	
	
	
	wire [DATA_BITS-1:0]result_1_out_3;
	wire [DATA_BITS-1:0]result_2_out_3;
	wire [DATA_BITS-1:0]regfile_out2_out_3;
	wire write_out_3;
	wire Jal_out_3;
	wire MemToReg_out_3;
	wire MemWrite_out_3;
	wire RegWrite_out_3;
	wire [1:0]ExtrWord_out_3;
	wire ToLH_out_3;
	wire ExtrSigned_out_3;
	wire Sh_out_3;
	wire Sb_out_3;
	wire [1:0]LHToReg_out_3;
	wire [DATA_BITS-1:0]PC_out_3;
	wire [DATA_BITS-1:0]IR_out_3;
    EX_MEM ex_mem(
        .clk(clk),
        .zero(0),
        .stall(1),
        .PC_in(PC_out_2),
        .IR_in(IR_out_2),
        .Jal(Jal_out_2),
        .MemToReg(MemToReg_out_2),
        .MemWrite(MemWrite_out_2),
        .RegWrite(RegWrite_out_2),
        .ExtrWord(ExtrWord_out_2),
        .ToLH(ToLH_out_2),
        .ExtrSigned(ExtrSigned_out_2),
        .Sh(Sh_out_2),
        .Sb(Sb_out_2),
        .LHToReg(LHToReg_out_2),
        .regfile_out2(regfile_out2_out_2),
        .write(write_out_2),
        .result_1(result_1),
        .result_2(result_2),
        .result_1_out(result_1_out_3),
        .result_2_out(result_2_out_3),
        .regfile_out2_out(regfile_out2_out_3),
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
        .IR_out(IR_out_3)
    );
    
	wire [MEM_ADDR - 1:0] mem_addr;
    wire [DATA_BITS - 1:0] mem_in;    //Ram的输入数???
    wire [3:0] mem_sel;
    RamInputAdapter #(.ADDR_BITS(MEM_ADDR), .DATA_BITS(DATA_BITS)) raminput(.result1(result_1_out_3), .regfile_out2(regfile_out2_out_3), .Sh(Sh_out_3), .Sb(Sb_out_3), .addr(mem_addr), .mem_in(mem_in), .mem_sel(mem_sel));
    
	wire [DATA_BITS - 1:0] mem_out;
    wire [DATA_BITS - 1:0] lo;
    wire [DATA_BITS - 1:0] hi;
    Mem #(.MEM_ADDR_BITS(MEM_ADDR), .MEM_DATA_BITS(DATA_BITS)) mem (.addr(mem_addr), .data_in(mem_in), .str(MemWrite_out_3), .sel(mem_sel), .clk(clk), .ld(1), .clr(rst), .data_out(mem_out));
    
    LHSpecialRegisters #(.DATA_BITS(DATA_BITS)) lhreg(.clk(clk),.result({result_2_out_3,result_1_out_3}), .ready(1), .lo(lo), .hi(hi));
    
	wire ToLH_out_4;
	wire [DATA_BITS-1:0]IR_out_4;

    MEM_WB mem_wb(
        .clk(clk),
        .zero(0),
        .stall(1),
        .PC_in(PC_out_3),
        .IR_in(IR_out_3),
        .Jal(Jal_out_3),
        .MemToReg(MemToReg_out_3),
        .RegWrite(RegWrite_out_3),
        .ExtrWord(ExtrWord_out_3),
        .ToLH(ToLH_out_3),
        .ExtrSigned(ExtrSigned_out_3),
        .LHToReg(LHToReg_out_3),
        .alu_out(result_1_out_3),
        .mem_out(mem_out),
        .lo(lo),
        .hi(hi),
        .write(write_out_3),
        .alu_out_out(result_1_out_4),
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
        .IR_out(IR_out_4)
    );

    //PcInputAdapter #(.ADDR_BITS(DATA_BITS)) PcInput(.Jmp(Jmp), .Jr(Jr), .pcsel(pcsel), .pc(pc), .imm_16(imm_16), .imm_26(imm_26), .regfile_out1(regfile_out1), .pc_next(pc_next));

    //divider #(.N(100)) div(.clk(clk),.clk_N(clk_N));

    //DRegister led(.clk(clk_N), .rst(rst), .enable(Syscall && (reg_v0 == 32'd34)), .data_in(reg_a0), .data_out(led_out));

    //SevenSegmentDisplayDriver #(.DIGITS(8), .CLK_DIV(4000) ) display(.din(led_show),.clk(clk),.rst(rst),.seg({seg,dp}), .ansel(an));

    /*CycleStatistic
    statics
    (
        .pcen(pcen),
        .Jmp(Jmp),
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
    ClkSpeedSwitcher
    #(
        .LEVEL_1_INDEX(100),   // 1 Hz
        .LEVEL_2_INDEX(24_999_999),   // 2 Hz
        .LEVEL_3_INDEX(12_499_999),   // 4 Hz
        .LEVEL_4_INDEX(6_249_999),   // 8 Hz
        .LEVEL_5_INDEX(3_124_999),   // 16 Hz
        .LEVEL_6_INDEX(1_562_499),   // 32 Hz
        .LEVEL_TOP_INDEX(1)             // 0 seems to be unstable
    )
    clkswitcher
    (
        .clk(clk),        // fastest system clock available
        .btn_faster(btnU), // buttons for going faster / slower
        .btn_slower(btnD),
        .clk_N(clk_N),      // divided clock
        // debug outputs
        .curr_level()
    );*/
endmodule
