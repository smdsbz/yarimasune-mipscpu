`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.26 8:50
//////////////////////////////////////////////////////////////


module CP0 (
    input   wire                clk,
    input   wire                rst,
    input   wire    [31:0]      id_instr,   // instruction word from ID / EX
    input   wire    [31:0]      wb_instr,
    input   wire    [31:0]      wb_din,
    input   wire    [31:0]      ex_pc,
    input   wire    [2:0]       intsrc,     // interrupt source
    output  wire                INT,        // interrupt signal to CPU
    output  wire                RegToCP0,
    output  wire                CP0ToReg,
    output  reg     [31:0]      id_dout,    // [combinational]
    output  wire    [31:0]      epc_out,
    output  wire                eret
);

wire    [4:0]   RAddr;
wire    [4:0]   WAddr;
wire            CP0Write;
wire            EpcWrite;
wire            StatusWrite;
wire            Eret;
CP0_Controller ControllerMod (
    .id_instr(id_instr),
    .wb_instr(wb_instr),
    .RAddr(RAddr),
    .WAddr(WAddr),
    .CP0ToReg(CP0ToReg),
    .RegToCP0(RegToCP0),
    .CP0Write(CP0Write),
    .EpcWrite(EpcWrite),
    .StatusWrite(StatusWrite),
    .Eret(Eret)
);
assign  eret = Eret;

wire    [2:0]   CauseIP;    // ie. IR
wire    [2:0]   IPRst;
wire    [2:0]   IPService;
genvar  i;
generate
    for (i = 0; i < 3; i = i + 1) begin
        assign IPRst[i] = (Eret & IPService[i]);
        InterruptSampler CauseIPMod (
            .clk(clk),
            .rst(rst | IPRst[i]),
            .int(intsrc[i]),
            .indication(CauseIP[i])
        );
    end
endgenerate
// assign IPRst = (Eret & IPService);
// InterruptSampler CauseIP0Mod (
//     .clk(clk),
//     .rst(rst | IPRst[0]),
//     .int(intsrc[0]),
//     .indication(CauseIP[0]),
// );
// InterruptSampler CauseIP1Mod (
//     .clk(clk),
//     .rst(rst | IPRst[1]),
//     .int(intsrc[1]),
//     .indication(CauseIP[1]),
// );
// InterruptSampler CauseIP2Mod (
//     .clk(clk),
//     .rst(rst | IPRst[2]),
//     .int(intsrc[2]),
//     .indication(CauseIP[2]),
// );

CP0_IPService IPServiceMod (
    .clk(clk),
    .rst(rst),
    .INT(INT),
    .Eret(Eret),
    .CauseIP(CauseIP),
    .IPService(IPService)
);

wire    [31:0]  EPC;
CP0_EPC EPCMod (
    .clk(clk),
    .INT(INT),
    .EpcWrite(EpcWrite),
    .ex_pc(ex_pc),
    .din(wb_din),
    .epc(EPC)
);
assign  epc_out = EPC;

wire    [31:0]  IE;
CP0_IE IEMod (
    .clk(clk),
    .rst(rst),
    .INT(INT),
    .IeWrite(StatusWrite),
    .din(wb_din[0]),
    .IE(IE)
);

CP0_INT INTMod (
    .clk(clk),
    .rst(rst),
    .CauseIP(CauseIP),
    .IPService(IPService),
    .IE(IE),
    .INT(INT)
);

// @id_dout assignment
always @ * begin
    case (RAddr)
        12:     id_dout <= { 31'b0000_0000_0000_0000_0000_0000_0000_000, IE };
        13:     id_dout <= { 16'b0000_0000_0000_0000, { 3'b000, CauseIP, 2'b00}, 8'b0000_0000 };
        14:     id_dout <= EPC;
        default: id_dout <= 0;
    endcase
end

endmodule

///////////////////////////// Sub-Modules //////////////////////////////

module CP0_Controller (
    input   wire    [31:0]      id_instr,
    input   wire    [31:0]      wb_instr,
    output  wire    [4:0]       RAddr,
    output  wire    [4:0]       WAddr,      // valid on @CP0Write
    output  wire                CP0ToReg,
    output  wire                RegToCP0,
    output  wire                CP0Write,
    output  wire                EpcWrite,
    output  wire                StatusWrite,
    output  wire                Eret
);

// decoding
wire    MTC0, MFC0, ERET;
assign  MTC0 = (wb_instr[31:21] == 11'b010000_00100);
assign  MFC0 = (id_instr[31:21] == 11'b010000_00000);
assign  ERET = (id_instr == 32'b010000_1_000_0000_0000_0000_0000_011000);

assign  RAddr = id_instr[15:11];
assign  WAddr = wb_instr[15:11];

assign  CP0ToReg = (MFC0);
assign  RegToCP0 = (MTC0);
assign  CP0Write = (MTC0);
assign  EpcWrite = (MTC0 && (WAddr == 14));
assign  StatusWrite = (MTC0 && (WAddr == 12));
assign  Eret = (ERET);

endmodule


module CP0_IPService (
    input   wire                clk,
    input   wire                rst,
    input   wire                INT,
    input   wire                Eret,
    input   wire    [2:0]       CauseIP,
    output  reg     [2:0]       IPService
);

always @ (posedge clk) begin
    if (rst) begin
        IPService <= 0;
    end else if (Eret) begin
        IPService <= 0;
    end else if (INT) begin
        if (CauseIP[2]) begin
            IPService <= 3'b100;
        end else if (CauseIP[1]) begin
            IPService <= 3'b010;
        end else if (CauseIP[0]) begin
            IPService <= 3'b001;
        end else begin
            IPService <= 0;
        end
    end
end

endmodule


module CP0_EPC (
    input   wire                clk,
    input   wire                INT,
    input   wire                EpcWrite,
    input   wire    [31:0]      ex_pc,
    input   wire    [31:0]      din,
    output  reg     [31:0]      epc
);

always @ (posedge clk) begin
    if (EpcWrite) begin
        epc <= din;
    end else if (INT) begin
        epc <= ex_pc;
    end
end

endmodule


module CP0_IE (
    input   wire                clk,
    input   wire                rst,        // resets to interrupt disabled
    input   wire                INT,
    input   wire                IeWrite,
    input   wire                din,
    output  reg                 IE
);

always @ (posedge clk) begin
    if (rst) begin
        IE <= 0;
    end else if (IeWrite) begin
        IE <= din;
    end else if (INT) begin
        IE <= 0;
    end
end

endmodule


module CP0_INT (
    input   wire                clk,
    input   wire                rst,
    input   wire    [2:0]       CauseIP,
    input   wire    [2:0]       IPService,
    input   wire                IE,
    output  reg                 INT
);

always @ (posedge clk) begin
    if (rst) begin
        INT <= 0;
    end else if (IE) begin
        if (INT) begin
            INT <= 0;
        end else if ((CauseIP & ~IPService) > IPService) begin
            INT <= 1;
        end
    end else begin
        INT <= 0;
    end
end

endmodule
