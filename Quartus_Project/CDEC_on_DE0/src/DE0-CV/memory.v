`default_nettype none

module memory(
  input	wire [7:0] adrs,
  input	wire [7:0] data,
  output reg [7:0] q,

  input wire clock,
  input wire wr_en
  );

  reg [7:0] ram[255:0];


  always @(posedge clock) begin
    if (wr_en) begin
      ram[adrs] <= data;
    end
    q <= ram[adrs];
  end
endmodule