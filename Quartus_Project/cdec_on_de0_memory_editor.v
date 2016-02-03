// ============================================================================
// Copyright (c) 2014 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Yue Yang          :| 08/25/2014:| Initial Revision
// ============================================================================


module CDEC_on_DE0_Memory_Editor(
      ///////// CLOCK2 /////////
      input              CLOCK2_50,

      ///////// CLOCK3 /////////
      input              CLOCK3_50,

      ///////// CLOCK4 /////////
      inout              CLOCK4_50,

      ///////// CLOCK /////////
      input              CLOCK_50,

      ///////// DRAM /////////
      output      [12:0] DRAM_ADDR,
      output      [1:0]  DRAM_BA,
      output             DRAM_CAS_N,
      output             DRAM_CKE,
      output             DRAM_CLK,
      output             DRAM_CS_N,
      inout       [15:0] DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_RAS_N,
      output             DRAM_UDQM,
      output             DRAM_WE_N,

      ///////// GPIO /////////
      inout       [35:0] GPIO_0,
      inout       [35:0] GPIO_1,

      ///////// HEX0 /////////
      output      [6:0]  HEX0,

      ///////// HEX1 /////////
      output      [6:0]  HEX1,

      ///////// HEX2 /////////
      output      [6:0]  HEX2,

      ///////// HEX3 /////////
      output      [6:0]  HEX3,

      ///////// HEX4 /////////
      output      [6:0]  HEX4,

      ///////// HEX5 /////////
      output      [6:0]  HEX5,

      ///////// KEY /////////
      input       [3:0]  KEY,

      ///////// LEDR /////////
      output      [9:0]  LEDR,

      ///////// PS2 /////////
      inout              PS2_CLK,
      inout              PS2_CLK2,
      inout              PS2_DAT,
      inout              PS2_DAT2,

      ///////// RESET /////////
      input              RESET_N,

      ///////// SD /////////
      output             SD_CLK,
      inout              SD_CMD,
      inout       [3:0]  SD_DATA,

      ///////// SW /////////
      input       [9:0]  SW,

      ///////// VGA /////////
      output      [3:0]  VGA_B,
      output      [3:0]  VGA_G,
      output             VGA_HS,
      output      [3:0]  VGA_R,
      output             VGA_VS
);

//=======================================================
//  REG/WIRE declarations
//=======================================================

	wire 	[2:0]	pio_mode_selout;
	wire 	[7:0] pio_datain;
	wire	[3:0] pio_keyout;
	wire	[8:0] pio_io_inout;
	wire 	[9:0]	virtual_SW;
	wire	[2:0] virtual_KEY;

	//制御されていない時は生の値を適用
	//mode
	assign 	virtual_SW[9] 		= (pio_mode_selout[2] == 0) ? SW[9] : pio_mode_selout[1];
	
	//sel
	assign 	virtual_SW[8] 		= (pio_mode_selout[2] == 0) ? SW[8] : pio_mode_selout[0];
	
	//io_in
	assign	virtual_SW[7:0]	= (pio_io_inout[8] == 0) ? SW[7:0] : pio_io_inout[7:0];
	
	//KEY
	assign	virtual_KEY[2:0]	= (pio_keyout[3] == 0) ? KEY[2:0] : pio_keyout[2:0];

	// memory_programmer -> memory
	wire [7:0]  pr_adrs;
   wire [7:0]  pr_code;
	
	//debug
	wire [7:0]	resdt;

	// 7seg
	wire [3:0]  sseg3_data;
	wire [3:0]  sseg2_data;
	wire [3:0]  sseg1_data;
	wire [3:0]  sseg0_data;

	assign sseg3_data = (virtual_SW[9] == 0) ? 4'h0 : pr_adrs[7:4];
	assign sseg2_data = (virtual_SW[9] == 0) ? 4'h0 : pr_adrs[3:0];
	assign sseg1_data = (virtual_SW[9] == 0) ? resdt[7:4]    	:
							  (virtual_SW[8] == 0) ? pio_datain[7:4]  :
															 pr_code[7:4]  ;
	assign sseg0_data = (virtual_SW[9] == 0) ? resdt[3:0]    	:
                       (virtual_SW[8] == 0) ? pio_datain[3:0]  :
															 pr_code[3:0]  ;

	sseg_dec  sseg3(.en(virtual_SW[9]), .data(sseg3_data), .led(HEX3));
	sseg_dec  sseg2(.en(virtual_SW[9]), .data(sseg2_data), .led(HEX2));
	sseg_dec  sseg1(.en(1'b1),          .data(sseg1_data), .led(HEX1));
	sseg_dec  sseg0(.en(1'b1),			   .data(sseg0_data), .led(HEX0));

DE0_CV_QSYS u0(
		.clk_clk(CLOCK_50),                        //                     clk.clk
		.reset_reset_n(1'b1),                  //                   reset.reset_n
		.key_external_connection_export(KEY), // key_external_connection.export
		//SDRAM
		.clk_sdram_clk(DRAM_CLK),                  //               clk_sdram.clk
	   .sdram_wire_addr(DRAM_ADDR),                //              sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                  //                        .ba
		.sdram_wire_cas_n(DRAM_CAS_N),               //                        .cas_n
		.sdram_wire_cke(DRAM_CKE),                 //                        .cke
		.sdram_wire_cs_n(DRAM_CS_N),                //                        .cs_n
		.sdram_wire_dq(DRAM_DQ),                  //                        .dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),                 //                        .dqm
		.sdram_wire_ras_n(DRAM_RAS_N),               //                        .ras_n
		.sdram_wire_we_n(DRAM_WE_N),                 //                        .we_n
		.pio_datain_export(pio_datain),  
		.pio_mode_selout_export(pio_mode_selout),  
		.pio_keyout_export(pio_keyout),
		.pio_io_inout_export(pio_io_inout),
		.uart_0_rxd(GPIO_1[31]),  //uart_0.rxd
		.uart_0_txd(GPIO_1[33])   // .txd
		);
		
CPU_shell CDEC_on_CV(
		.KEY(virtual_KEY),
		.SW(virtual_SW),
		.LEDR(LEDR),
		//.HEX0(HEX0),
		//.HEX1(HEX1),
		//.HEX2(HEX2),
		//.HEX3(HEX3),
		.pr_adrs(pr_adrs),
		.resdt(resdt),
		.data(pio_datain),
		.pr_code(pr_code)
	);

endmodule
