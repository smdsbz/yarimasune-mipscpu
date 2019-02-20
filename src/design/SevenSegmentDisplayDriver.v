`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      Xiaoguang Zhu
// Version:     2.19 11:26
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////


module SevenSegmentDisplayDriver
#(
    parameter   DIGITS  = 8,    // this parameter should NOT be changed
    parameter   CLK_DIV = 4095  // 4095 is fine, too small a value will cause display to overlap
) (
    input   wire    [DIGITS * 4 - 1:0]  din,    // hexadecimal input data
    input   wire                        clk,    // fastest system clock available
    input   wire                        rst,    // reset
    output  reg     [7:0]               seg,    // segment driver signals, ordered { a, b, ..., g, dp }
    output  wire    [DIGITS - 1:0]      ansel   // place enable signals, active on LOW
);

reg     [15:0]      _clk_counter;
reg     [15:0]      _curr_digit;
assign  ansel = ~(1 << _curr_digit);
always @ (posedge clk) begin
    if (rst) begin
        _curr_digit = 0;
        _clk_counter = 0;
    end else begin
        _clk_counter = _clk_counter + 1;
        if (_clk_counter == CLK_DIV) begin
            _curr_digit = (_curr_digit + 1) % DIGITS;
            _clk_counter = 0;
        end
    end
end

wire    [3:0]   disp_data;
assign  disp_data = din >> (_curr_digit << 2);
always @ * begin
    if (rst) begin
        seg <= -1;  // 11...111
    end else begin
        case (disp_data)
                         // { abc_defg_dp }
            4'h0:   seg <= 8'b000_0001_1;
            4'h1:   seg <= 8'b100_1111_1;
            4'h2:   seg <= 8'b001_0010_1;
            4'h3:   seg <= 8'b000_0110_1;
            4'h4:   seg <= 8'b100_1100_1;
            4'h5:   seg <= 8'b010_0100_1;
            4'h6:   seg <= 8'b010_0000_1;
            4'h7:   seg <= 8'b000_1111_1;
            4'h8:   seg <= 8'b000_0000_1;
            4'h9:   seg <= 8'b000_1100_1;
            4'ha:   seg <= 8'b000_1000_1;
            4'hb:   seg <= 8'b110_0000_1;
            4'hc:   seg <= 8'b111_0010_1;
            4'hd:   seg <= 8'b100_0010_1;
            4'he:   seg <= 8'b011_0000_1;
            4'hf:   seg <= 8'b011_1000_1;
        endcase
    end
end

endmodule
