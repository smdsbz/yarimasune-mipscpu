`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:  Yuhang Chen
// Version: 2.20 20:30
//
//
//////////////////////////////////////////////////////////////////////////////////


module CycleStatistic(
    input wire pcen,
    input wire Jmp,
    input wire clk,
    input wire rst,
    input wire pcsel,
    output reg [31:0] TotalCycle,
    output reg [31:0] CoBranchCycle,
    output reg [31:0] UnBranchCycle
    );
always @ ( posedge clk ) begin
    if(rst) begin
        TotalCycle <= 0;
        CoBranchCycle <= 0;
        UnBranchCycle <= 0;
    end
    else if(pcen) begin
        TotalCycle <= TotalCycle + 1;
        if(pcsel)
            CoBranchCycle <= CoBranchCycle + 1;
        if(Jmp)
            UnBranchCycle <= UnBranchCycle + 1;
    end
end
endmodule
