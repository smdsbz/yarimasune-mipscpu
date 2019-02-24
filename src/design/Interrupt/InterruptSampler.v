`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.24 14:58
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////


module InterruptSampler (
    input   wire    clk,
    input   wire    rst,    // clears @indication synchronously
    input   wire    int,    // external / internal interrupt signal
    output  reg     indication, // indicates whether interrupt has been signaled
    // debug output
    output  wire    debug_hint
);

// interrupt hint is implemented with an asynchronously cleared D-flipflop
reg     hint;
initial hint = 0;
always @ (posedge int, posedge indication) begin
    if (indication) begin
        hint <= 0;
    end else begin
        hint <= 1;
    end
end

wire    hint_holder;
assign  hint_holder = hint | indication;
always @ (posedge clk) begin
    indication <= hint_holder & ~rst;
end

// debug related
assign  debug_hint = hint;

endmodule
