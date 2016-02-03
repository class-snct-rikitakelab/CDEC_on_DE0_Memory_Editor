/* ALU_func.v */
// {[10]S, [9]Z, [8]Cy, [7:0]result}

module alu(
	input	wire 	[7:0] x,
	input wire 	[7:0]	y,
	input wire 				cy,
	input wire 	[4:0]	op,
	output wire [2:0] flag,
	output wire [7:0] result);

	assign {flag, result} = ALU(x, y, cy, op);

	function [10:0] ALU;
		input [7:0] X;		// XBUS
		input [7:0] T;		// Treg
		input       Cy;		// Carry
		input [4:0] ALUop;	// ALU operation

	  reg [8:0] rslt;	// {SZCy, result[7:0]}

		begin
	    case (ALUop)
				5'b00000: rslt = 9'b0_0000_0000;	// zero
				5'b00001: rslt = {1'b0, X};		// pass X
				5'b00010: rslt = {1'b0, T};		// pass T
				5'b01000: rslt = X + T;			// X + T
				5'b01001: rslt = X + T + 8'h01;		// X + T + 1
				5'b01010: rslt = X + T + Cy;		// X + T + Cy
				5'b01011: rslt = X + (~T & 8'hFF) + 8'h01;	    // X - T      => X +~T + 1
				5'b01100: rslt = X + (~T & 8'hFF);		    // X - T - 1  => X +~T
				5'b01101: rslt = X + (~T & 8'hFF) + (7'h00 + ~Cy);  // X - T - Cy => X +~T + ~Cy 
				5'b01110: rslt = X + 8'h01;			// inc X
				5'b01111: rslt = X + 8'hFF;		// dec X
				5'b10000: rslt = {1'b0, X & T};		// X and T
				5'b10001: rslt = {1'b0, X | T};		// X or T
				5'b10010: rslt = {1'b0, X ^ T};		// X xor T
				5'b10011: rslt = {1'b0, ~X};		// not X
				5'b10100: rslt = {1'b0, ~T};		// not T
				5'b11000: rslt = {Cy, 1'b0, X[7:1]};	// shift X right logical
				5'b11001: rslt = {Cy, Cy,   X[7:1]};	// shift X right with Cy
				5'b11011: rslt = {X, 1'b0};		// shift X left  logical
				5'b11010: rslt = {X, Cy};		// shift X left  with Cy
				default : rslt = 9'bX_XXXX_XXXX;
	    endcase

		  ALU = {rslt[7], (rslt[7:0]==0), rslt};

		end
	endfunction
	
endmodule

