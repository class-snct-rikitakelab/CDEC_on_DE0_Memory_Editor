/* CPU_shell.v  = = = = = = = = = = = = = = = = = = = = = = = = = = = = *****
 **    CDEC8 and test bench / FPGA interface module          ****
 ***       Ver. 1.0 2014.05.30                        ***
 ****                                      **
 ***** (C) 2014 kimsyn (ET & VLSI system design labo. GCT ICE)  = = = = = = */

module CPU_shell(
  input wire  [2:0] KEY,// push buttons: {clock, reset_N, p_clock}
  input wire  [9:0] SW,// slide switches: {mode, select_sw, io_in}
  output wire [9:0] LEDR,// LED RED: {clocklevel, endseq, io_out}
  //output wire [6:0] HEX0,// 7seg digit 0
  //output wire       HEX0_DP,// 7seg dp 0
  //output wire [6:0] HEX1,// 7seg digit 1
  //output wire       HEX1_DP,// 7seg dp 1
  //output wire [6:0] HEX2,// 7seg digit 2
  //output wire       HEX2_DP,// 7seg dp 2
  //output wire [6:0] HEX3,// 7seg digit 3
  //output wire       HEX3_DP// 7seg dp 3
  output wire [7:0] data,
  output wire [7:0] resdt,
  output wire [7:0]  pr_adrs,
  output wire [7:0]  pr_code
  );

  wire clock;   // clock
  wire reset_N; // reset (active low)
  wire prog_clock; // clock signal of memory programming


  wire clocklevel;        // clock level
  wire endseq;            // end seqence
  wire [7:0] io_out;      // OUTPUT PORT (8-bit LED)

  wire [7:0] ssled3;
  wire [7:0] ssled2;
  wire [7:0] ssled1;
  wire [7:0] ssled0;

  // program/run mode selector
  // mode == 1 => program mode
  // mode == 0 => run mode
  wire  mode;

  // sel
  // Given mode == 1
  //  sel == 1/0 : program write/read
  // Given mode == 0
  //  sel == 1/0 : debug resource I/PC
  wire sel;

  wire [7:0]  io_in;      // INPUT PORT (8-bit SW)

  /*
  wire HEX0_DP;
  wire HEX1_DP;
  wire HEX2_DP;
  wire HEX3_DP;
  */
  
  assign clock      = KEY[2];
  assign reset_N    = KEY[1];
  assign prog_clock = KEY[0];

  assign {mode, sel, io_in} = SW;

  assign LEDR = {clocklevel, endseq, io_out};

  /*
  assign {HEX0_DP, HEX0} = ssled0;
  assign {HEX1_DP, HEX1} = ssled1;
  assign {HEX2_DP, HEX2} = ssled2;
  assign {HEX3_DP, HEX3} = ssled3;
  */

  // memory_programmer -> memory
  //wire [7:0]  pr_adrs;
  //wire [7:0]  pr_code;
  wire        pr_clock;
  wire        pr_wr_en;
  // memory_programmer -> 7segs
  //wire [7:0]  data;

  // CDEC8 <-> memory
  wire [7:0]  data_in;
  wire [7:0]  data_out;
  wire [7:0]  adrs;
  wire        mm_wr_en;

  // debug
  wire        ressel;
  wire [7:0]  resad;
  //wire [7:0]  resdt;

  // 7seg
  /*
  wire [3:0]  sseg3_data;
  wire [3:0]  sseg2_data;
  wire [3:0]  sseg1_data;
  wire [3:0]  sseg0_data;

  assign sseg3_data = (mode == 0) ? 4'h0 : pr_adrs[7:4];
  assign sseg2_data = (mode == 0) ? 4'h0 : pr_adrs[3:0];
  assign sseg1_data = (mode == 0) ? resdt[7:4]    :
                      (sel  == 0) ? data[7:4]     :
                                    pr_code[7:4]  ;
  assign sseg0_data = (mode == 0) ? resdt[3:0]    :
                      (sel  == 0) ? data[3:0]     :
                                    pr_code[3:0]  ;

  sseg_dec  sseg3(.en(mode), .dp(1'b0)      , .data(sseg3_data), .led(ssled3));
  sseg_dec  sseg2(.en(mode), .dp(mode & sel), .data(sseg2_data), .led(ssled2));
  sseg_dec  sseg1(.en(1'b1), .dp(1'b0)      , .data(sseg1_data), .led(ssled1));
  sseg_dec  sseg0(.en(1'b1), .dp(mode & sel), .data(sseg0_data), .led(ssled0));
  */
  
  // memory programmer
  memory_programmer programmer(
    .reset_N(reset_N),
    .prog_clock(prog_clock),
    .prog_wr_en(sel),
    .prog_code(io_in),
    .data(data),

    .pr_clock(pr_clock),
    .pr_wr_en(pr_wr_en),
    .pr_adrs(pr_adrs),
    .pr_code(pr_code),
    .mm_data(data_in)
    );

  // -- debug monitor ---
  // clock level
  assign clocklevel = clock;

  // convert ressel to resad
  assign resad =  (sel == 1'b0) ? 8'h00 : // PC
										            	8'h01 ; // I

  //-- CPU core instantiation and bus connection

  CDEC8 CDEC8(
    .clock(clock),
    .reset_N(reset_N),
    .io_in(io_in),
    .io_out(io_out),
    .adrs(adrs),
    .data_in(data_in),
    .data_out(data_out),
    .mmwr_en(mm_wr_en),
    .endseq(endseq),
    .resad(resad),
    .resdt(resdt)
  );

  //-- memory/io signal connection
  memory ram(
    .adrs(mode ? pr_adrs : adrs),
    .data(mode ? pr_code : data_out),
    .q(data_in),
    .clock(mode ? pr_clock : clock),
    .wr_en(mode ? pr_wr_en : mm_wr_en));

endmodule
