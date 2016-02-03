/* CDEC_DP.v  = = = = = = = = = = = = = = = = = = = = = = = = = = = = = *****
 **    CDEC data path part FPGA version          ****
 ***       Ver. 1.0  2014.05.29             ***
 ****                    **
 ***** (C) 2014 kimsyn (ET & VLSI system design labo. GCT ICE)  = = = = = = */

`default_nettype none
`include "./my_const.vh"

module CDEC8_DP (
  input  wire        clock,
  input  wire        reset_N,

  // io port
  input  wire [7:0] io_in,  // input port
  output wire [7:0] io_out, // output port

  // memory
  output wire [7:0] adrs,
  input  wire [7:0] data_in,
  output wire [7:0] data_out,

  // to control unit
  output wire [7:0] I,
  output wire [2:0] SZCy,

  // from control unit
  input  wire [16:0] ctrl,

  // debug monitor
  input  wire [7:0] resad, // resource address for PC debug monitor
  output wire [7:0] resdt//, // resource data    for PC debug monitor
  );


  //-- internal signals
  wire       rwr, fwr;
  wire [1:0] mmrw;
  wire [3:0] xdst, xsrc;
  wire [4:0] aluop;

  wire [7:0] XBUS;
  wire [7:0] PC, A, B, C, T, R, MAR, RDR, WDR, FLG;
  wire [7:0] IPORT;
  wire [7:0] alu_out;
  wire [2:0] alu_szcy;

  //-- control signal re-assign
  assign {mmrw, fwr, rwr, xdst, aluop, xsrc} = ctrl; // CTRL

  //-- ALU/FLAG connection
  alu alu(.x(XBUS), .y(T), .cy(FLG[1]), .op(aluop), .flag(alu_szcy), .result(alu_out));
  assign SZCy = FLG[3:1];

  //-- memory bus
  assign adrs     = MAR;
  assign data_out = WDR;

  //-- XBUS connection: Reg -> XBUS
  assign XBUS = (xsrc == 4'b0000) ? PC    :
                (xsrc == 4'b0001) ? A     :
                (xsrc == 4'b0010) ? B     :
                (xsrc == 4'b0011) ? C     :
                (xsrc == 4'b0100) ? R     :
                (xsrc == 4'b0101) ? RDR   :
                (xsrc == 4'b0110) ? FLG   :
                (xsrc == 4'b0111) ? 8'hff :
                (xsrc == 4'b1000) ? IPORT :
                                    8'hff ; //pullup

  //-- register instantiation
  reg8_ner PC_reg (.clock(clock),
    .wr_en(xdst == 4'b0000), .in(XBUS), .out(PC),
    .reset_N(reset_N)); // PC
  reg8_ne  A_reg  (.clock(clock),
    .wr_en(xdst == 4'b0001), .in(XBUS), .out(A)); // A
  reg8_ne  B_reg  (.clock(clock),
    .wr_en(xdst == 4'b0010), .in(XBUS), .out(B)); // B
  reg8_ne  C_reg  (.clock(clock),
    .wr_en(xdst == 4'b0011), .in(XBUS), .out(C)); // C
  reg8_ne  I_reg  (.clock(clock),
    .wr_en(xdst == 4'b0111), .in(XBUS), .out(I)); // I
  reg8_ne  T_reg  (.clock(clock),
    .wr_en(xdst == 4'b0110), .in(XBUS), .out(T)); // T
  reg8_ne  MAR_reg (.clock(clock),
    .wr_en(xdst == 4'b0100), .in(XBUS), .out(MAR)); // MAR
  reg8_ne  WDR_reg (.clock(clock),
    .wr_en(xdst == 4'b0101), .in(XBUS), .out(WDR)); // WDR
  reg8_ne  RDR_reg (.clock(clock),
    .wr_en(mmrw == 2'b10),   .in(data_in), .out(RDR)); // RDR
  reg8_ne  R_reg   (.clock(clock),
    .wr_en(rwr),  .in(alu_out), .out(R)); // R
  reg8_ne  FLG_reg (.clock(clock),
    .wr_en(fwr),  .in({4'h0, alu_szcy, 1'b0}), .out(FLG)); // FLG
  reg8_pe  IPORT_reg(.clock(clock),
    .wr_en(1'b1), .in(io_in), .out(IPORT)); // IPORT
  reg8_ne  OPORT_reg(.clock(clock),
    .wr_en(xdst == 4'b1000), .in(XBUS), .out(io_out)); // OPORT

  //-- internal hardware resource singnal observation bus for debug monitor
  assign resdt = (resad == 8'h00) ? PC      : 8'hZZ;
  assign resdt = (resad == 8'h01) ? I       : 8'hZZ;
  assign resdt = (resad == 8'h02) ? T       : 8'hZZ;
  assign resdt = (resad == 8'h03) ? R       : 8'hZZ;
  assign resdt = (resad == 8'h04) ? MAR     : 8'hZZ;
  assign resdt = (resad == 8'h05) ? data_in : 8'hZZ;
  assign resdt = (resad == 8'h06) ? RDR     : 8'hZZ;
  assign resdt = (resad == 8'h07) ? WDR     : 8'hZZ;
  assign resdt = (resad == 8'h08) ? A       : 8'hZZ;
  assign resdt = (resad == 8'h09) ? B       : 8'hZZ;
  assign resdt = (resad == 8'h0A) ? C       : 8'hZZ;
  // assign resdt = (resad == 8'h0B) ? state   : 8'hZZ;  // external
  // assign resdt = (resad == 8'h0C) ? signal  : 8'hZZ;  // external
  assign resdt = (resad == 8'h0D) ? FLG     : 8'hZZ;
  assign resdt = (resad == 8'h0E) ? XBUS    : 8'hzz;
  assign resdt = (resad == 8'h0F) ? IPORT   : 8'hzz;

endmodule
