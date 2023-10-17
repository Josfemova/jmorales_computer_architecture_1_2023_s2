module pio #(parameter WIDTH=32)
(
    input clk,
    input we,
    inout [WIDTH-1:0] port,
    input [(WIDTH-1):0] wd,
    output reg [(WIDTH-1):0] rd
);

  always @(posedge clk) begin
    rd <= port;
    if (we) port <= wd;
  end

endmodule