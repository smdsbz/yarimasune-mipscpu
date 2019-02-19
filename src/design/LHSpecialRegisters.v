`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.19 11:26
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////

// LO / HI special registers as individual multiplier / divider output
//
// LHSpecialRegisters stores @result into @lo and @hi when a rising edge is given
// on @ready.
module LHSpecialRegisters
#(
    parameter   DATA_BITS   = 32
)(
    input   wire    [DATA_BITS * 2 - 1:0]   result,     // calculated result
    input   wire                            ready,      // is `result` ready ?
    output  wire    [DATA_BITS - 1:0]       lo,
    output  wire    [DATA_BITS - 1:0]       hi
);

reg     [DATA_BITS * 2 - 1:0]   hi_lo;

always @ (posedge ready) begin
    hi_lo <= result;
end

assign  lo = hi_lo[DATA_BITS - 1:0];
assign  hi = hi_lo[DATA_BITS * 2 - 1:DATA_BITS];

endmodule
