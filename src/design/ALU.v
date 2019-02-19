`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:      JiaXing Zhang
// Version:     2.19 9:21
// Reviewer:
// Review Date:
//////////////////////////////////////////////////////////////////////////////////

// 
// ALU

module ALU(ALU_OP,X,Y,shamt,Result,Result2,equal,overflow);

parameter digit_number=32; //data length
input [3:0] ALU_OP;
input [digit_number-1:0] X;//operating nuber1
input [digit_number-1:0] Y;//operating nuber2
input [4:0] shamt;
output reg [digit_number-1:0] Result;
output reg [digit_number-1:0] Result2;
output  equal;
output  overflow;

assign equal=((X==Y)? 1:0);
assign overflow=0;
always @(*)
begin
	case(ALU_OP)
	4'b0000: begin
		Result=X<<shamt;
		Result2=0;
		end
    4'b0001: begin
		Result=X>>>shamt;
		Result2=0;
		end
    4'b0010: begin
		Result=X>>shamt;
		Result2=0;
		end
    4'b0011: {Result2,Result}=X*Y;
    4'b0100: begin
    	Result=X/Y;
    	Result2=X%Y;
    	end
    4'b0101: begin
    	Result=X+Y;
    	Result2=0;
    	end
    4'b0110: begin
    	Result=X-Y;
    	Result2=0;
    	end
    4'b0111: begin
    	Result=X&Y;
    	Result2=0;
    	end          
    4'b1000: begin
    	Result=X|Y;
    	Result2=0;
    	end
    4'b1001: begin
    	Result=X^Y;
    	Result2=0;
    	end
    4'b1010: begin
    	Result=~(X|Y);
    	Result2=0;
    	end
    4'b1011: begin
    	Result=(X<Y)? 1:0;
    	Result2=0;
    	end
    4'b1100: begin
            Result2=0;
            if((X[31]==1)&&(Y[31]==0))
                  Result=1;
             else if((X[31]==0)&&(Y[31]==1))
                   Result=0;
            // else if((X[31]==1)&&(Y[31]==1))
            //  Result = (X>Y) ? 1 : 0;
             else
                Result= (X<Y) ? 1 : 0 ;
             end
    default: begin
    	Result=0;
    	Result2=0;
    	end
	endcase
end
endmodule
