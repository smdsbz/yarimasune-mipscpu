`timescale 1ns / 1ps

//time :2.25 18.51
//author: zjx qpz



module Interrupt(
        input wire clock,
        input wire[2: 0] IR,         // IR
		input wire [31:0]instructionword,
		
        input wire [31:0]data,
        input wire reset,
		output [2:0] IRout,
        output reg [31:0]dataout
	);
	wire IE;
	assign IE=cp0[0][0];
	assign IRout=IR&{3{IE}};
	
	
	reg [31:0]cp0[0:2];//status,cause,epc
	always @(*) begin
		if(reset)
		begin
			 cp0[0]<=0;
			 cp0[1]<=0;
			 cp0[2]<=0;
		end
		else begin
			if(instructionword[31:21]==11'b010_0000_0000)
			begin
				case(instructionword[15:11])
				5'b01100: begin dataout<=cp0[0]; end//status
				5'b01101: begin dataout<=cp0[1]; end//cause
				5'b01110: begin dataout<=cp0[2]; end//epc
				default: dataout<=0;
				endcase
			end
			else if(instructionword[31:21]==11'b010_0000_0100)
			begin
				case(instructionword[15:11])
				5'b01100: begin cp0[0]<=data; end//status
				5'b01101: begin cp0[1]<=data; end//cause
				5'b01110: begin cp0[2]<=data; end//epc
				default:;
				endcase
			end
			else begin
				dataout<=0;
			end
		end
	end
	endmodule
	
