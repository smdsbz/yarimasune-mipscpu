`timescale 1ns / 1ps
`define MEM_ADDR_BITS 10
`define MEM_DATA_BITS 32
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2019/02/18 15:12:06
// Module Name: Mem
// Description: 
//      input:
//          addr:地址,10位
//          data_in:输入的数据
//          str:为1时，将输入写入对应位置
//          sel:为0时，将addr和data_in输入无效
//          ld:为1时，将data_in输入到存储器
//          clr:同步清零
//      output:data_out
//////////////////////////////////////////////////////////////////////////////////


module Mem (addr, data_in, str, sel, clk, ld, clr, data_out);
    input [0:`MEM_ADDR_BITS-1]addr;
    input [0:`MEM_DATA_BITS-1]data_in;
    input str,sel,clk,ld,clr;
    output reg [0:`MEM_DATA_BITS-1]data_out;
    reg [0:`MEM_DATA_BITS-1]memory[0:1<<`MEM_ADDR_BITS-1];
    reg [0:3]control;
    integer i;
    initial
        begin
            for(i=0;i<(1<<`MEM_ADDR_BITS);i=i+1)
                memory[i]=`MEM_DATA_BITS'h0;
        end
    always @(posedge clk)
        begin
             control={clr,sel,str,ld};
             casez(control)
                4'b1zzz: 
                    begin
                        for(i=0;i<(1<<`MEM_ADDR_BITS);i=i+1)
                            memory[i]=`MEM_DATA_BITS'h0;
                    end//清零
                4'b00zz: 
                    data_out=`MEM_DATA_BITS'hzzzzzzzz;//无输出
                4'b0101: 
                    data_out=memory[addr];//输出地址上的数字
                4'b0110: 
                    begin
                        data_out=`MEM_DATA_BITS'hzzzzzzzz; 
                        memory[addr]=data_in;
                    end//无输出,将data上的数字输入到存储器中
                4'b0111: 
                    begin
                        memory[addr]=data_in;
                        data_out=data_in;
                    end//将data上的数字输入到存储器中，并将存储器上对应地址内容输出
                default: 
                    data_out=`MEM_DATA_BITS'hzzzzzzzz;//无输出
             endcase
        end
endmodule
