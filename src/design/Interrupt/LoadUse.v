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
input wire LoadUse1,
input wire LoadUse2,
output wire [31:0] EXRegister1Data,
output wire [31:0] EXRegister2Data
);
reg [31:0] EXData1_next;
reg [31:0] EXData2_next;
reg LoadUse1_next;
reg LoadUse2_next;
assign EXRegister1Data = LoadUse2_next ? EXData1_next : EXData1;
assign EXRegister2Data = LoadUse1_next ? EXData2_next : EXData2;
always @ ( posedge clk ) begin
    if(rst) begin
        EXData1_next <= 0;
        EXData2_next <= 0;
        LoadUse1_next <= 0;
        LoadUse2_next <= 0;
    end
    else begin
        EXData1_next <= EXData1;
        EXData2_next <= EXData2;
        LoadUse1_next <= LoadUse1;
        LoadUse2_next <= LoadUse2;
    end
end
endmodule
