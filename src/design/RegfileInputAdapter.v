`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.20 17:05
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////

// [combinational logic]
// deals with ~RegFile~'s data input selection
module RegfileInputAdapter
#(
    parameter   DATA_BITS   = 32
) (
    // data lines in
    input   wire    [4:0]               rs,
    input   wire    [4:0]               rt,
    input   wire    [4:0]               rd,
    input   wire    [DATA_BITS - 1:0]   alu_out,    // number / memory address calculated
    input   wire    [DATA_BITS - 1:0]   mem_out,
    input   wire    [DATA_BITS - 1:0]   lo,         // from individual multiplier / divider
    input   wire    [DATA_BITS - 1:0]   hi,
    input   wire    [1:0]               addr_byte,  // lower 2 bits from address to memory (aligned)
    input   wire    [DATA_BITS - 1:0]   pc,         // program counter (pointing to next instruction)
    // signals in
    input   wire                        Jal,
    input   wire                        RegDst,
    input   wire                        MemToReg,
    input   wire    [1:0]               ExtrWord,   // extract from memory out @mem_out (valid on `MemToReg` high)
                                                    //    0 - don't extract fields
                                                    //    1 - extract 8-bit byte at given @addr_byte
                                                    //    2 - extract 16-bit halfword at given @addr_byte (aligned)
                                                    //    3 - undefined
    input   wire                        ExtrSigned, // extract (byte or halfword) as signed or unsigned
    input   wire    [1:0]               LHToReg,    // get input from LO / HI special registers
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
        W <= 31;    // $ra: return address register
        Din <= pc;
    end else begin
        W <= RegDst ? rd : rt;
        if (MemToReg) begin
            case (ExtrWord)
                0:  Din <= mem_out;
                1:  begin
                    case (addr_byte)
                        0:  Din <= ExtrSigned ? {{28{mem_out[7]}}, mem_out[6:0]} : mem_out[7:0];
                        1:  Din <= ExtrSigned ? {{28{mem_out[15]}}, mem_out[14:8]} : mem_out[15:8];
                        2:  Din <= ExtrSigned ? {{28{mem_out[23]}}, mem_out[22:16]} : mem_out[23:16];
                        3:  Din <= ExtrSigned ? {{28{mem_out[31]}}, mem_out[30:24]} : mem_out[31:24];
                    endcase
                end
                2:  begin
                    case (addr_byte[1])
                        0:  Din <= ExtrSigned ? {{16{mem_out[15]}}, mem_out[14:0]} : mem_out[15:0];
                        1:  Din <= ExtrSigned ? {{16{mem_out[31]}}, mem_out[30:16]} : mem_out[31:16];
                    endcase
                end
                3:  Din <= 0;   // undefined
            endcase
        end else if (LHToReg) begin
            case (LHToReg)
                0:  Din <= 0;   // unreachable
                1:  Din <= lo;
                2:  Din <= hi;
                3:  Din <= 0;   // undefined
            endcase
        end else begin
            Din <= alu_out;
        end
    end
end

endmodule
