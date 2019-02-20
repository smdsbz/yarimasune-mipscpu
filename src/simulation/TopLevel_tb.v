`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yuhang Chen
// Version: 2.20
//
//
//////////////////////////////////////////////////////////////////////////////////


module TopLevel_tb(
    );
    reg clk;
    reg rst;
    TopLevel
    #(.ROM_ADDR(10), .DATA_BITS(32) , .MEM_ADDR(10), .PC_ADDR(10))    //Rom的地�?线长、PC的数据位�?
    toplevel
    (
        .clk(clk),
        .btnL(rst),
        .seg(),    // segment driver signals, ordered { a, b, ..., g, dp }
        .dp(),
        .an()   // place enable signals, active on LOW
    );
    initial begin
        clk <= 0;
        rst <= 1;
        #20000 rst <= 0;
    end
    always begin
        #5 clk <= ~clk;
    end
endmodule
