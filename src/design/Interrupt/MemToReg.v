`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module MemToReg
#(
parameter   DATA_BITS   = 32
) (
// data lines in
input   wire    [DATA_BITS - 1:0]   alu_out,    // number / memory address calculated
input   wire    [DATA_BITS - 1:0]   mem_out,
input   wire    [DATA_BITS - 1:0]   lo,         // from individual multiplier / divider
input   wire    [DATA_BITS - 1:0]   hi,
input   wire    [1:0]               addr_byte,  // lower 2 bits from address to memory (aligned)
input   wire    [DATA_BITS - 1:0]   pc,         // program counter (pointing to next instruction)
// signals in
input   wire                        Jal_out_4,
input   wire                        MemToReg,
input   wire    [1:0]               ExtrWord,   // extract from memory out @mem_out (valid on `MemToReg` high)
                                                //    0 - don't extract fields
                                                //    1 - extract 8-bit byte at given @addr_byte
                                                //    2 - extract 16-bit halfword at given @addr_byte (aligned)
                                                //    3 - undefined
input   wire                        ExtrSigned, // extract (byte or halfword) as signed or unsigned
input   wire    [1:0]               LHToReg,    // get input from LO / HI special registers
input   wire                        CP0ToReg,
input   wire    [31:0]              CP0_out,
// real data / index out
output  reg     [DATA_BITS - 1:0]   Din         // data to write
);
always @ * begin
    if(CP0ToReg) begin
        Din <= CP0_out;
    end
    else if (MemToReg) begin
        case (ExtrWord)
            0:  Din <= mem_out;
            1:  begin
                case (addr_byte)
                    0:  Din <= ExtrSigned ? {{24{mem_out[7]}}, mem_out[7:0]} : mem_out[7:0];
                    1:  Din <= ExtrSigned ? {{24{mem_out[15]}}, mem_out[15:8]} : mem_out[15:8];
                    2:  Din <= ExtrSigned ? {{24{mem_out[23]}}, mem_out[23:16]} : mem_out[23:16];
                    3:  Din <= ExtrSigned ? {{24{mem_out[31]}}, mem_out[31:24]} : mem_out[31:24];
                endcase
            end
            2:  begin
                case (addr_byte[1])
                    0:  Din <= ExtrSigned ? {{16{mem_out[15]}}, mem_out[15:0]} : mem_out[15:0];
                    1:  Din <= ExtrSigned ? {{16{mem_out[31]}}, mem_out[31:16]} : mem_out[31:16];
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
    end else if(Jal_out_4)begin
        Din <= pc + 4;
    end else begin
        Din <= alu_out;
    end
end

endmodule
