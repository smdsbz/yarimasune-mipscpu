`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.20 11:37
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////


module ClkSpeedSwitcher
#(
    parameter   LEVEL_1_INDEX   = 49_999_999,   // half-sec
    parameter   LEVEL_2_INDEX   = 24_999_999,
    parameter   LEVEL_3_INDEX   = 12_499_999,
    parameter   LEVEL_TOP_INDEX = 1
) (
    input   wire        clk,        // fastest system clock available
    input   wire        btn_faster, // buttons for going faster / slower
    input   wire        btn_slower,
    output  reg         clk_N       // divided clock
);

// level config parameter syncing
reg     [3:0]   curr_level;
reg     [31:0]  counter_max;
always @ * begin
    case (curr_level)
        0:  counter_max <= LEVEL_1_INDEX;
        1:  counter_max <= LEVEL_2_INDEX;
        2:  counter_max <= LEVEL_3_INDEX;
        default: counter_max <= LEVEL_TOP_INDEX;
    endcase
end

// level switer
always @ (posedge btn_faster, posedge btn_slower) begin
    if (btn_faster) begin
        curr_level <= curr_level + 1;
    end else begin
        curr_level <= ((curr_level == 0) ? 0 : (curr_level - 1));
    end
end

// counter
reg     [31:0]  counter;
always @ * begin
    if (counter >= counter_max) begin
        counter <= 0;
        clk_N <= ~clk_N;
    end else begin
        counter = counter + 1;
    end
end

endmodule
