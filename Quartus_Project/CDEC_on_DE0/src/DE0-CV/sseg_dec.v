`default_nettype none

module sseg_dec(
	input wire				en,
	//input wire				dp,
	input wire [3:0]  data,
	output wire [7:0] led
	);

	//assign led = en ? ~{dp, dec(data)} : 7'b1111111;
	assign led = en ? ~dec(data) : 7'b1111111;

	function [6:0] dec;
		input [3:0] data_in;
		begin
			case(data_in)
				4'h0 : dec = 7'b0111111;
				4'h1 : dec = 7'b0000110;
				4'h2 : dec = 7'b1011011;
				4'h3 : dec = 7'b1001111;
				4'h4 : dec = 7'b1100110;
				4'h5 : dec = 7'b1101101;
				4'h6 : dec = 7'b1111101;
				4'h7 : dec = 7'b0100111;
				4'h8 : dec = 7'b1111111;
				4'h9 : dec = 7'b1101111;
				4'ha : dec = 7'b1110111;
				4'hb : dec = 7'b1111100;
				4'hc : dec = 7'b1011000;
				4'hd : dec = 7'b1011110;
				4'he : dec = 7'b1111001;
				4'hf : dec = 7'b1110001;
				default: dec = 7'b0000000;
			endcase
		end
	endfunction
endmodule