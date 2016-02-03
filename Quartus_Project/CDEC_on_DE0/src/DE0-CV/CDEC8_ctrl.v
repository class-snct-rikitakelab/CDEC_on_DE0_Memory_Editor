// CDEC8_PLA .v(2014-10-30)
/* CDEC8_PLA.v  = = = = = = = = = = = = = = = = = = = = = = = = = = = = *****
 **    CDEC8 PLA control part module					 ****
 ***       Ver. 1.0  2014.05.30						  ***
 ****									   **
 ***** (C) 2014 kimsyn (ET & VLSI system design labo. GCT ICE)  = = = = = = */

`default_nettype none

module CDEC8_ctrl(
  input  wire	       clock,
  input  wire	       reset_N,
  input  wire [ 7:0] I,
  input  wire [ 2:0] SZCy,

  output wire [16:0] ctrl,
  output wire endseq,

  input  wire [ 7:0] resad,
  output wire [ 7:0] resdt
  );

  //wire 	  endseq;
  reg	   [ 3:0] state;

  //-- PLA
  // assign {endseq, ctrl} = PLA(state, I, SZCy);
  ctrl_pla ctrl_pla(
    .state(state), .instruction(I), .flag(SZCy),
    .pla({endseq, ctrl}));

  //-- state counter
  always @(posedge clock or negedge reset_N) begin
    if(~reset_N) begin
      state <= 4'b0000;
    end else begin
      state <= (endseq) ? 4'b0000 : state + 1'b1;
    end
  end


  //-- internal hardware resource singnal observation bus for debug monitor
  assign resdt = (resad == 8'h0B) ? {endseq, 3'b000, state} : 8'hZZ;


endmodule

