module pio_ro #(parameter WIDTH=32)
(
    input clk,
    input we,
    input [(WIDTH-1):0] wd,
    input [WIDTH-1:0] port,
    output reg [(WIDTH-1):0] rd
);

  always @(posedge clk) begin
    rd <= port;
  end

endmodule