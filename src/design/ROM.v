`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.18 18:38
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////

// [combinational logic]
// (strictly) read-only memory
module ROM
#(
    parameter   ADDR_BITS   = 32,
    parameter   DATA_BITS   = 32
)
(
    input   wire    [ADDR_BITS - 1:0]       addr,   // address
    input   wire                            sel,    // enable signal
    output  wire    [DATA_BITS - 1:0]       dout    // data out
);

reg     [DATA_BITS - 1:0]   _mem_blk    [0:(1 << ADDR_BITS) - 1];

assign  dout = (
    sel ?
      _mem_blk[addr]
    : 0
);

initial $readmemh("/home/smdsbz/Downloads/benchmark.hex", _mem_blk);

endmodule
