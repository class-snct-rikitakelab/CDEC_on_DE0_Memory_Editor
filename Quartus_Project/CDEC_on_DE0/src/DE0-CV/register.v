/* register.v  = = = = = = = = = = = = = = = = = = = = = = = = = = = = =*****
 **    various registers						 ****
 ***       Ver. 1.0  2014.05.09						  ***
 ****									   **
 ***** (C) 2014 kimsyn (ET & VLSI system design labo. GCT ICE)  = = = = = = */

`default_nettype none

//--------------------------------------------------------------------
// 8-bit positive edge trigger type

module reg8_pe(
    input wire           clock,
    input wire           wr_en,
    input wire     [7:0] in,
    output reg [7:0] out);

    always @(posedge clock) begin
	if(wr_en) begin
	    out <= in;
	end
    end
endmodule

//--------------------------------------------------------------------
// 8-bit negative edge trigger type

module reg8_ne(
    input wire           clock,
    input wire           wr_en,
    input wire     [7:0] in,
    output reg [7:0] out);

    always @(negedge clock) begin
    if(wr_en) begin
        out <= in;
    end
    end
endmodule

//--------------------------------------------------------------------
// 8-bit positive edge trigger type with async. reset

module reg8_per(
    input wire           clock,
    input wire           wr_en,
    input wire     [7:0] in,
    output reg [7:0] out,
    input wire           reset_N);

    always @(posedge clock or negedge reset_N) begin
	if(~reset_N) begin
	    out <= 8'h00;
	end else begin
	    if(wr_en) begin
		out <= in;
	    end
	end
    end
endmodule


//--------------------------------------------------------------------
// 8-bit negative edge trigger type with async. reset

module reg8_ner(
    input wire           clock,
    input wire           wr_en,
    input wire     [7:0] in,
    output reg [7:0] out,
    input wire           reset_N
);

    always @(negedge clock or negedge reset_N) begin
	if(~reset_N) begin
	    out <= 8'h00;
	end else begin
	    if(wr_en) begin
		out <= in;
	    end
	end
    end
endmodule


//--------------------------------------------------------------------
// 8-bit low level trigger type

module reg8_ll(
    input wire           clock,
    input wire           wr_en,
    input wire     [7:0] in,
    output reg [7:0] out);

   always @(clock, wr_en, in) begin
	if(~clock) begin
	    if(wr_en) begin
		out <= in;
	    end
	end
    end
endmodule


//--------------------------------------------------------------------
// 8-bit high level trigger type

module reg8_hl(
    input wire           clock,
    input wire           wr_en,
    input wire     [7:0] in,
    output reg [7:0] out);

    always @(clock, wr_en, in) begin
	if(clock) begin
	    if(wr_en) begin
		out <= in;
	    end
	end
    end
endmodule

