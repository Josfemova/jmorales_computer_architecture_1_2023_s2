module rom_1port #(
    INIT_FILE = "/home/common/Downloads/audio_Q114.txt"
) (
    // se agregan enables para el pipeline
    input clk,
    //input en,
    input [31:0] addr,
    output logic [15:0] rd
);

  //reg [15:0] rom[112000-1:0];  // 7seg
  //reg [15:0] rom[64000-1:0];  // 4seg
  reg [15:0] rom[32000-1:0];  // 2seg

  initial begin
    $readmemb(INIT_FILE, rom);
  end

  always @(posedge clk) begin
    //if (en) rd <= {rom[addr[31:2]]};
    rd <= rom[addr[31:2]];
  end

endmodule
