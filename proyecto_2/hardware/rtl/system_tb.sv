module system_tb;

  logic clk;
  logic reset;

  logic [5:0] LED;
  logic [3:0] SW;
  logic [1:0] KEY;
  logic [31:0] GPIO0_drv;
  logic [31:0] GPIO1_drv;
  wire [31:0] GPIO0;
  wire [31:0] GPIO1;


  initial begin
    LED = 0;
    SW = 4'b0110;
    KEY = 0;
    GPIO0_drv = 1;
    GPIO1_drv = 1;
  end

  logic request;
  assign GPIO0[17] = request;

  //assign GPIO0 = 1'bz;
  //assign GPIO1 = 1'bz;
  always begin
    request = 1;
    #50;
    request = 0;
    #50;
  end

  always begin
    KEY <= 2'b11;
    #50;
    KEY <= 2'b00;
    #50;
  end

  logic [31:0] instr_memory_data;
  logic [31:0] data_memory_data;
  logic [31:0] instr_memory_addr;
  logic [31:0] data_memory_addr;
  logic [31:0] data_memory_wd;
  logic instr_memory_enable;
  logic data_memory_we;

  core_top dut (
      .clk(clk),
      .reset(reset),
      .instr_memory_data(instr_memory_data),
      .data_memory_data(data_memory_data),
      .instr_memory_addr(instr_memory_addr),
      .data_memory_addr(data_memory_addr),
      .data_memory_wd(data_memory_wd),
      .data_memory_we(data_memory_we),
      .instr_memory_enable(instr_memory_enable)
  );

  logic rom0_we;  // dummy
  logic [31:0] rom0_addr;
  logic [31:0] rom0_wd;  // dummy
  logic [31:0] rom0_rd;

  logic rom1_we;  // dummy
  logic [31:0] rom1_addr;
  logic [31:0] rom1_wd;  // dummy
  logic [31:0] rom1_rd;
  assign rom1_rd[31:16] = 16'b0;

  logic rom2_we;  // dummy
  logic [31:0] rom2_addr;
  logic [31:0] rom2_wd;  // dummy
  logic [31:0] rom2_rd;
  assign rom2_rd[31:16] = 16'b0;

  logic ram0_we;
  logic [31:0] ram0_addr;
  logic [31:0] ram0_wd;
  logic [31:0] ram0_rd;

  logic pio0_we;
  logic [31:0] pio0_addr;
  logic [31:0] pio0_wd;
  logic [31:0] pio0_rd;

  rom_2port #(
      .INIT_FILE("../../../rtl/simple_test.txt")
  ) rom0 (
      .clk_a (clk),
      .clk_b (clk),
      .en_a  (instr_memory_enable),
      .en_b  (1'b1),
      .addr_a(instr_memory_addr),
      .addr_b(rom0_addr),
      .rd_a  (instr_memory_data),
      .rd_b  (rom0_rd)
  );

  // para audio sin reverb
  rom_1port #(
      .INIT_FILE("/tmp/vitas.txt")
  ) rom1 (
      .clk (clk),
      //.en  (1'b1),
      .addr(rom1_addr),
      .rd  (rom1_rd[15:0])
  );

  // para audio con reverb
  rom_1port #(
      .INIT_FILE("/tmp/vitas_reverbed.txt")
  ) rom2 (
      .clk (clk),
      //.en  (1'b1),
      .addr(rom2_addr),
      .rd  (rom2_rd[15:0])
  );

  // para buffer circular
  ram_1port ram (
      .clk (clk),
      .we  (ram0_we),
      .addr(ram0_addr),
      .wd  (ram0_wd),
      .rd  (ram0_rd)
  );

  de10nano_pio pio (
      .LED(LED),
      .SW(SW),
      .KEY(KEY),
      .GPIO0(GPIO0),
      .GPIO1(GPIO1),
      .clk(clk),
      .we(pio0_we),
      .wd(pio0_wd),
      .addr(pio0_addr),
      .rd(pio0_rd)
  );

  simple_interconnect #(
      .REGIONS(5)
  ) bus (
      .clk(clk),
      .we_m(data_memory_we),
      .addr_m(data_memory_addr),
      .wd_m(data_memory_wd),
      .rd_s({rom2_rd, rom1_rd, pio0_rd, ram0_rd, rom0_rd}),
      .region_base({32'h2000_0000, 32'h1000_0000, 32'h0000_2000, 32'h0000_1000, 32'h0000_0000}),
      .region_end({32'h3000_0000, 32'h2000_0000, 32'h0000_3000, 32'h0000_2000, 32'h0000_1000}),
      .we_s({rom2_we, rom1_we, pio0_we, ram0_we, rom0_we}),
      .addr_s({rom2_addr, rom1_addr, pio0_addr, ram0_addr, rom0_addr}),
      .wd_s({rom2_wd, rom1_wd, pio0_wd, ram0_wd, rom0_wd}),
      .rd_m(data_memory_data)
  );

  initial begin
    reset <= 1;
    #20;
    reset <= 0;
  end

  always begin
    clk <= 0;
    #5;
    clk <= 1;
    #5;
  end


  always @(posedge clk) begin
    if (rom1_addr == 32'hc4f3c4) begin
      #100;
      $display("Simulation ended");
      $stop;
    end

  end



endmodule
