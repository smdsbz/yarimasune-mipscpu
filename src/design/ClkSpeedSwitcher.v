`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.20 19:31
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////


module ClkSpeedSwitcher
#(
    parameter   LEVEL_1_INDEX   = 49_999_999,   // 1 Hz
    parameter   LEVEL_2_INDEX   = 24_999_999,   // 2 Hz
    parameter   LEVEL_3_INDEX   = 12_499_999,   // 4 Hz
    parameter   LEVEL_4_INDEX   =  6_249_999,   // 8 Hz
    parameter   LEVEL_5_INDEX   =  3_124_999,   // 16 Hz
    parameter   LEVEL_6_INDEX   =  1_562_499,   // 32 Hz
    parameter   LEVEL_TOP_INDEX = 1             // 0 seems to be unstable
) (
    input   wire            clk,        // fastest system clock available
    input   wire            btn_faster, // buttons for going faster / slower
    input   wire            btn_slower,
    output  reg             clk_N,      // divided clock
    // debug outputs
    output  reg     [3:0]   curr_level
);

initial curr_level = 0;
initial clk_N = 0;

// level config parameter syncing
reg     [31:0]  counter_max;
initial counter_max = 0;    // simulation hint
always @ * begin
    case (curr_level)
        0:  counter_max <= LEVEL_1_INDEX;
        1:  counter_max <= LEVEL_2_INDEX;
        2:  counter_max <= LEVEL_3_INDEX;
        3:  counter_max <= LEVEL_4_INDEX;
        4:  counter_max <= LEVEL_5_INDEX;
        5:  counter_max <= LEVEL_6_INDEX;
        default: counter_max <= LEVEL_TOP_INDEX;
    endcase
end

// level switcher
reg     pressed;
initial pressed = 0;
always @ (posedge clk) begin
    if (!pressed) begin
        if (btn_faster) begin
            curr_level <= ((curr_level == 6) ? 6 : (curr_level + 1));
            pressed <= 1;
        end else if (btn_slower) begin
            curr_level <= ((curr_level == 0) ? 0 : (curr_level - 1));
            pressed <= 1;
        end
    end else begin
        if ({btn_faster, btn_slower} == 2'b00) begin
            pressed <= 0;
        end
    end
end

// counter
reg     [31:0]  counter;    // simulation hint
initial counter = 0;
always @ (posedge clk) begin
    if (counter >= counter_max) begin
        counter <= 0;
        clk_N <= ~clk_N;
    end else begin
        counter = counter + 1;
    end
end

endmodule
