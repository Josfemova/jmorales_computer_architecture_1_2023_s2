module register_file #(
    parameter REGISTERS = 32,
    WIDTH = 32
) (
    input clk,
    we3,
    input [($clog2(REGISTERS))-1:0] a1,
    input [($clog2(REGISTERS))-1:0] a2,
    input [($clog2(REGISTERS))-1:0] a3,
    input [WIDTH-1:0] wd3,
    output [WIDTH-1:0] rd1,
    output [WIDTH-1:0] rd2
);

  reg [WIDTH-1:0] registers[REGISTERS-1:0];

  // asegurar que x0 siempre sea 0
  assign rd1 = (a1 == 0) ? 0 : registers[a1];
  assign rd2 = (a2 == 0) ? 0 : registers[a2];

  always @(posedge clk) begin
    if (we3) registers[a3] <= wd3;
  end

endmodule
