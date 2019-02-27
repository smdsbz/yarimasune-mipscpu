`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:  Yuhang Chen
// Version: 2.20 21:00
//
//
//////////////////////////////////////////////////////////////////////////////////

module LedSwitcher(
    input wire [31:0] LedData,
    input wire [31:0] TotalCycle,
    input wire [31:0] CoBranchCycle,
    input wire [31:0] UnBranchCycle,
    input wire CLK,
    input wire RST,
    input wire Change,
    output reg [31:0] LedShow
    );
    reg [1:0]status,flag;
    always@(posedge CLK)begin
        if(RST) begin
            flag <= 0;
            status <= 2'b00;
        end
        else begin
            if(Change && !flag) begin
                flag <= 1;
                status <= status + 2'b01;
            end
            else if(!Change)begin
                flag <= 0;
            end
        end
    end
//    always @(posedge Change or ) begin
//        status <= status + 2'b01;
//    end
    always @(status) begin
        case(status)
            2'b00: LedShow <= LedData;
            2'b01: LedShow <= TotalCycle;
            2'b10: LedShow <= CoBranchCycle;
            2'b11: LedShow <= UnBranchCycle;
            default: LedShow <= LedData;
        endcase
    end
endmodule
