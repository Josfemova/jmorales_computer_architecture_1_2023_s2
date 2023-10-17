module top (
    input clk,
    input reset,
    output [5:0] instr
);

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
  
  logic rom0_we; // dummy
  logic [31:0] rom0_addr;
  logic [31:0] rom0_wd; // dummy
  logic [31:0] rom0_rd;
  
  logic ram0_we;
  logic [31:0] ram0_addr;
  logic [31:0] ram0_wd;
  logic [31:0] ram0_rd;

  rom_2port #(
      .INIT_FILE("../rtl/simple_test.txt")
  ) rom (
      .clk_a (clk),
      .clk_b (clk),
      .en_a  (instr_memory_enable),
      .en_b  (1'b1),
      .addr_a(instr_memory_addr),
      .addr_b(rom0_addr),
      .rd_a  (instr_memory_data),
      .rd_b  (rom0_rd)
  );

  ram_1port ram (
      .clk (clk),
      .we  (ram0_we),
      .addr(ram0_addr),
      .wd  (ram0_wd),
      .rd  (ram0_rd)
  );

  simple_interconnect #(
      .REGIONS(2)
  ) bus (
      .clk(clk),
      .we_m(data_memory_we),
      .addr_m(data_memory_addr),
      .wd_m(data_memory_wd),
      .rd_s({
        ram0_rd, 
        rom0_rd
    }),
      .region_base({
        32'h1000, 
        32'h0
    }),
      .region_end({
        32'h2000,
        32'h1000
    }),
      .we_s({
        ram0_we,
        rom0_we
    }),
      .addr_s({
        ram0_addr, 
        rom0_addr
    }),
      .wd_s({
        ram0_wd, 
        rom0_wd
    }),
      .rd_m(data_memory_data)
  );

endmodule
