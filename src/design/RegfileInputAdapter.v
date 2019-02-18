`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.18 20:33
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////

// [combinational logic]
// deals with ~RegFile~'s data input selection
module RegfileInputAdapter
#(  parameter   DATA_BITS   = 32
) (
    // data lines in
    input   wire    [4:0]               rs,
    input   wire    [4:0]               rt,
    input   wire    [4:0]               rd,
    input   wire    [DATA_BITS - 1:0]   alu_out,    // number / memory address calculated
    input   wire    [DATA_BITS - 1:0]   mem_out,
    input   wire    [1:0]               addr_byte,  // lower 2 bits from address to memory
    input   wire    [DATA_BITS - 1:0]   pc,         // program counter (pointing to next instruction)
    // signals in
    input   wire                        Jal,
    input   wire                        RegDst,
    input   wire                        MemToReg,
    input   wire                        ExtrByte,   // extract byte from memory out (valid on `MemToReg` high)
    // real data / index out
    output  wire    [4:0]               IR1,
    output  wire    [4:0]               IR2,
    output  reg     [4:0]               W,          // index of reg to write to
    output  reg     [DATA_BITS - 1:0]   Din         // data to write
);

assign IR1 = rs;
assign IR2 = rt;

always @ * begin
    if (Jal) begin
        W <= 31;    // $ra: return address
        Din <= pc;
    end else begin
        W <= RegDst ? rd : rt;
        if (MemToReg) begin
            if (ExtrByte) begin
                case (addr_byte)
                    2'b00:  Din <= { 24'b0, mem_out[7:0] };
                    2'b01:  Din <= { 24'b0, mem_out[15:8] };
                    2'b10:  Din <= { 24'b0, mem_out[23:16] };
                    2'b11:  Din <= { 24'b0, mem_out[31:24] };
                endcase
            end else begin
                Din <= mem_out;
            end
        end else begin
            Din <= alu_out;
        end
    end
end

endmodule
