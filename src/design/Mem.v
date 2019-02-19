`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2019/02/19 9:02:06
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


module Mem #(parameter MEM_ADDR_BITS=20,parameter MEM_DATA_BITS=32)(addr, data_in, str, sel, clk, ld, clr, data_out);
    input [MEM_ADDR_BITS-1:0]addr;
    input [MEM_DATA_BITS-1:0]data_in;
    input str,clk,ld,clr;
    input [3:0]sel;
    output reg [MEM_DATA_BITS-1:0]data_out;
    reg [MEM_DATA_BITS-1:0]memory[0:(1<<MEM_ADDR_BITS)-1];
    reg [31:0]data_in_;
    reg [31:0]data_reg;
    reg [31:0]sel_2;
    integer i;
    always @(posedge clk)
        begin
             if(clr)
                begin
                    for(i=0;i<(1<<MEM_ADDR_BITS);i=i+1)
                        memory[i]=32'h0;
                    data_out=32'd0;
                end//清零
             else
                begin
                    data_in_={(sel[3]!=0)?data_in[31:24]:memory[addr][31:24],
                            (sel[2]!=0)?data_in[23:16]:memory[addr][23:16],
                            (sel[1]!=0)?data_in[15:8]:memory[addr][15:8],
                            (sel[0]!=0)?data_in[7:0]:memory[addr][7:0]};
                    if(str)
                        memory[addr]=data_in_;
                    else;
                    sel_2={{7{1'b0}},sel[3],{7{1'b0}},sel[2],{7{1'b0}},sel[1],{7{1'b0}},sel[0]};
                    sel_2={($signed(sel_2[31:24]<<7)>>>7),
                            ($signed(sel_2[23:16]<<7)>>>7),
                            ($signed(sel_2[15:8]<<7)>>>7),
                            ($signed(sel_2[7:0]<<7)>>>7)};
                    data_reg=sel_2&memory[addr];
                    if(ld)
                        data_out=data_reg;
                    else
                        data_out=32'd0;
                end
        end
endmodule
