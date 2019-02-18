`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2019/02/18 17:12:41 
// Module Name: mem_test
//////////////////////////////////////////////////////////////////////////////////


module mem_test();
    reg [0:9]addr;
    reg [0:31]data_in;
    reg str,sel,clk,ld,clr;
    wire [0:31]data_out;
    
    initial
        begin
            addr=10'b0;
            data_in=32'b1;
            str=1;
            sel=1;
            clk=0;
            ld=1;
            clr=0;
            
        end
        always
            #5 clk=~clk;
        always
            #6 str=~str;
        always
            #7 sel=~sel;
        always
            #8 ld=~ld;
        always
            #100 clr=~clr;
        always
            #11 addr=addr+1;
        always
            #6 data_in=data_in+1;
        Mem mem(addr, data_in, str, sel, clk, ld, clr, data_out);
endmodule
