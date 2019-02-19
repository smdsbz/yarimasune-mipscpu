`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yuhang Chen
// Version: 2.19 18:45
//
//
//////////////////////////////////////////////////////////////////////////////////


module ConditionBranch_tb(
    );
    reg Beq, Bne, Equal, Bltz, Bgtz, Blez, Bgez;
    reg [31:0]regfile_out1;
    wire pcsel;
    ConditionBranch conbranch(
        .Beq(Beq), //Beq信号
        .Bne(Bne),
        .Equal(Equal),   //Alu输出的equal信号
        .Bltz(Bltz),
        .Bgtz(Bgtz),
        .Blez(Blez),
        .Bgez(Bgez),
        .regfile_out1(regfile_out1),    //regfile的第一个输出
        .pcsel(pcsel)
        );
    initial begin
        Beq <= 0;
        Bne <= 0;
        Equal <= 0;
        Bltz <= 0;
        Blez <= 0;
        Bgtz <= 0;
        Bgez <= 0;
        regfile_out1 <= 0;
        #10 Beq <= 1;
        #5 Equal <= 1;
        #5 Equal <= 0;
        #5 Bne <= 1;
            Beq <= 0;
        #5 Bne <= 0;
        #5 Blez <= 1;
        #5 regfile_out1 <= 32'hffffffff;
        #5 Blez <= 0;
            Bltz <= 1;
        #5 Bltz <= 0;
            Bgtz <= 1;
        #5 Bgtz <= 0;
            Bgez <= 1;
        #5 regfile_out1 <= 0;
    end
endmodule
