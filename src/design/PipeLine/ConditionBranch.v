`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yuhang Chen
// Version: 2.19 18:45
//
//
//////////////////////////////////////////////////////////////////////////////////


module ConditionBranch
    #(parameter DATA_BITS = 32)
    (
    input wire Beq, //Beq信号
    input wire Bne,
    input wire Equal,   //Alu输出的equal信号
    input wire Bltz,
    input wire Bgtz,
    input wire Blez,
    input wire Bgez,
    input wire [DATA_BITS - 1:0] regfile_out1,    //regfile的第一个输出
    output wire pcsel
    );
    wire bltz,bgtz,blez,bgez;
    assign pcsel = (Beq & Equal) | (Bne & (!Equal)) | bltz | bgtz | blez | bgez;
    assign bltz = (Bltz & ( $signed(regfile_out1) < $signed(0) ));
    assign bgtz = (Bgtz & ( $signed(regfile_out1) > $signed(0) ));
    assign blez = (Blez &(( $signed(regfile_out1) < $signed(0) ) | ( $signed(regfile_out1) == $signed(0) )));
    assign bgez = (Bgez &( ( $signed(regfile_out1) > $signed(0) ) | ( $signed(regfile_out1) == $signed(0) )));
endmodule
