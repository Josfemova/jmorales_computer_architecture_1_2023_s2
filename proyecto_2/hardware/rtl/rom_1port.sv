module rom_1port #(
    parameter WIDTH = 32,
    LENGTH = 256,
    INIT_FILE = "../rtl/simple_test.txt"
) (
    // se agregan enables para el pipeline
    input clk,
    input en,
    input [(WIDTH-1):0] addr,
    output logic [(WIDTH-1):0] rd
);
  reg [(WIDTH-1):0] rom[(LENGTH-1):0];

  initial begin
    $readmemb(INIT_FILE, rom);
    rd = 0;
  end

  always @(posedge clk) begin
    if (en) rd <= rom[addr[WIDTH-1:2]];
  end

endmodule
