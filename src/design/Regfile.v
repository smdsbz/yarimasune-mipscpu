`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/18 15:53:11
// Design Name: 
// Module Name: Regfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Regfile(
    IR1,IR2,W,Din,WE,CLK,RST,OR1,OR2
    );
    input wire [4:0] IR1;
    input wire [4:0] IR2;
    input wire [4:0] W;
    input wire [31:0] Din;
    input wire WE;
    input wire CLK;
    input wire RST;
    output wire [31:0] OR1;
    output wire [31:0] OR2;
    reg [31:0] REG [0:31];
    assign OR1 = REG[IR1];
    assign OR2 = REG[IR2];
    //…œ…˝—ÿ¥•∑¢
    always @(posedge CLK) begin
        if(RST) begin
            REG[0] <= 0;
            //reg«Â¡„
        end
        else begin
            if(WE & (W != 0)) begin
                REG[W] <= Din;
            end
        end
        //OR1 <= REG[IR1];
        //OR2 <= REG[IR2];  
    end
endmodule
