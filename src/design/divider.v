`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:Peizhong Qiu
// Create Date: 2019/02/19 15:16:59
// Design Name: 
// Module Name: divider
//////////////////////////////////////////////////////////////////////////////////


module divider #(parameter N=4)(clk,clk_N);
    input clk;
    output reg clk_N;
    reg [31:0]counter;
    initial 
    begin
        counter=0;
    end
    always @(posedge clk)
    begin 
        counter=counter+1;
        if (counter==(N/2-1))
            begin
                clk_N=~clk_N;
                counter=0;
            end
        else 
            clk_N=clk_N;
    end
endmodule
