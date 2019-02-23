`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/02/20 10:48:37
// Design Name:
// Module Name: IF_ID
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


module IF_ID#(parameter PC_BITS=32,parameter IR_BITS=32)(valid,clk,PC_in,IR_in,PC_out,IR_out,zero,stall,valid_out);
        input valid;
        input clk;
        input [PC_BITS-1:0] PC_in;
        input [IR_BITS-1:0] IR_in;
        output reg [PC_BITS-1:0] PC_out;
        output reg [IR_BITS-1:0] IR_out;
        output reg valid_out;
        input zero;
        input stall;
        always @(posedge clk)
            begin
                if(zero | ~valid)begin
                    PC_out<=0;
                    IR_out<=0;
                    valid_out <= 0;
                    end
                else  if(stall)
                    begin
                    valid_out <= 1;
                    PC_out<=PC_in;
                    IR_out<=IR_in;
                    end
                else;
            end
    endmodule
