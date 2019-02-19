//////////////////////////////////////////////////////////////////////////////////
// Author:Peizhong Qiu
// Create Date: 2019/02/19 20:22
// Design Name: 
// Module Name: click
//////////////////////////////////////////////////////////////////////////////////

module click(clk,go,rst,out);
    input clk;
    input go;
    input rst;
    output out;
    wire zero;
    wire UsedOut;
    D_trigger GoPressd(go,1,zero,out);
    D_trigger GoUsed(clk,out,zero,UsedOut);
    D_trigger GoCancel(clk,UsedOut,rst,zero);
endmodule
//异步清零的D触发器
module D_trigger #(parameter width=1)(clk,data,zero,data_out);
    input clk;
    input [width:1]data;
    input zero;
    output reg [width:1]data_out;
    always @(posedge clk or posedge zero)
        begin
            if(zero)
                data_out=0;
            else 
                data_out=data;
        end
endmodule
