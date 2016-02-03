`default_nettype none

module memory_programmer(
  input wire        reset_N,
  input wire        prog_clock,
  input wire        prog_wr_en,
  input wire  [7:0] prog_code,
  output wire [7:0] data,

  output wire       pr_clock,
  output wire       pr_wr_en,
  output wire [7:0] pr_adrs,
  output wire [7:0] pr_code,
  input wire  [7:0] mm_data
  );

  reg [7:0] address_counter;

  assign pr_clock = ~prog_clock;
  assign pr_wr_en = prog_wr_en;
  assign pr_adrs  = address_counter;
  assign pr_code  = prog_code;
  assign data     = mm_data;

  always @(posedge prog_clock or negedge reset_N) begin
    if (reset_N == 0) begin
      address_counter <= 8'h00;      
    end
    else begin
      address_counter <= address_counter + 1'b1;
    end
  end

endmodule
