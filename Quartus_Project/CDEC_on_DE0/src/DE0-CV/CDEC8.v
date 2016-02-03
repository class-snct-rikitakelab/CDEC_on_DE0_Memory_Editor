/* CDEC8.v  = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = *****
 **    CDEC8 cpu core module						 ****
 ***       Ver. 1.0  2014.09.01						  ***
 ****									   **
 ***** (C) 2014 kimsyn (ET & VLSI system design labo. GCT ICE)  = = = = = = */

`default_nettype none
`include "./my_const.vh"

module CDEC8(
    input wire        clock,
    input wire        reset_N,

    input wire  [7:0] io_in,
    output wire [7:0] io_out,

    output wire [7:0] adrs,
    input  wire [7:0] data_in,
    output wire [7:0] data_out,
    output wire       mmwr_en,

    output wire endseq,
    input  wire [7:0] resad,
    output wire [7:0] resdt);

    wire [ 2:0] SZCy;
    wire [ 7:0] I;
    wire [16:0] ctrl;

    wire   [ 1:0] mmrw;


    CDEC8_DP CDEC8_DP (
        clock, reset_N,
        io_in, io_out,
        adrs, data_in, data_out,
        I, SZCy, ctrl,
        resad, resdt);

    CDEC8_ctrl CDEC8_ctrl (
        clock, reset_N,
        I, SZCy, ctrl,
        endseq,
        resad, resdt);

  //-- memory access control signals
    assign mmrw     = ctrl[16:15];
    assign mmwr_en  = (mmrw == 2'b01);

endmodule
