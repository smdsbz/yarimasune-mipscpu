`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yuhang Chen
// Version: 2.22 23:00
//
//
//////////////////////////////////////////////////////////////////////////////////


module LoadUse
(
input wire [31:0] EXData1,
input wire [31:0] EXData2,
input wire clk,
input wire rst,
input wire LoadStore1,
input wire LoadStore2,
output wire [31:0] EXRegister1Data,
output wire [31:0] EXRegister2Data
);
reg [31:0] EXData1_next;
reg [31:0] EXData2_next;
reg LoadStore1_next;
reg LoadStore2_next;
assign EXRegister1Data = LoadStore2_next ? EXData1_next : EXData1;
assign EXRegister2Data = LoadStore1_next ? EXData2_next : EXData2;
always @ ( posedge clk ) begin
    if(rst) begin
        EXData1_next <= 0;
        EXData2_next <= 0;
        LoadStore1_next <= 0;
        LoadStore2_next <= 0;
    end
    else begin
        EXData1_next <= EXData1;
        EXData2_next <= EXData2;
        LoadStore1_next <= LoadStore1;
        LoadStore2_next <= LoadStore2;
    end
end
endmodule
