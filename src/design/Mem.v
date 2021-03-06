`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2019/02/20 8:02:06
// Module Name: Mem
// Description: 
//      input:
//          addr:地址
//          data_in:输入的数据
//          str:为1时，将输入写入对应位置
//          sel:为0时，将addr和data_in输入无效
//          ld:为1时，将data_in输入到存储器
//          clr:同步清零
//      output:data_out
//////////////////////////////////////////////////////////////////////////////////


module Mem #(parameter MEM_ADDR_BITS=10,parameter MEM_DATA_BITS=32)(addr, data_in, str, sel, clk, ld, clr, data_out);
    input [MEM_ADDR_BITS-1:0]addr;
    input [MEM_DATA_BITS-1:0]data_in;
    input str,clk,ld,clr;
    input [3:0]sel;
    output [MEM_DATA_BITS-1:0] data_out;
    reg [MEM_DATA_BITS-1:0]memory[0:(1<<MEM_ADDR_BITS)-1];
    wire [MEM_DATA_BITS-1:0]data_out_;
    wire [31:0]data_in_;
    wire [31:0]data_reg;
    wire [31:0]sel_2;
    wire [31:0]ld_2;
    wire [31:0]clr_2;
    integer i;
    assign sel_2={{8{sel[3]}},{8{sel[2]}},{8{sel[1]}},{8{sel[0]}}};
    assign ld_2={32{ld}};
    assign clr_2={32{~clr}};
    assign data_in_={(sel[3]!=0)?data_in[31:24]:memory[addr][31:24],
                     (sel[2]!=0)?data_in[23:16]:memory[addr][23:16],
                     (sel[1]!=0)?data_in[15:8]:memory[addr][15:8],
                     (sel[0]!=0)?data_in[7:0]:memory[addr][7:0]};
    assign data_out=sel_2&memory[addr]&ld_2&clr_2;
    always @(posedge clk)
        begin
             if(clr)
                begin
                    for(i=0;i<(1<<MEM_ADDR_BITS);i=i+1)
                        memory[i]<=32'h0;
                    //data_out<=32'd0;
                end//清零
             else
                begin
                    if(str)
                        memory[addr]<=data_in_;
                    else;
                    //data_out<=sel_2&(str==1?data_in_:memory[addr])&ld_2;
                end
        end
endmodule
