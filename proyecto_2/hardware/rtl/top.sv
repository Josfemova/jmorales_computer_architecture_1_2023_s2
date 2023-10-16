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

  assign instr = data_memory_wd[5:0];

  logic data_memory_we;
  logic instr_memory_flush;
  logic instr_memory_enable;
  logic instr_memory_we;

  core_top dut (
      .clk(clk),
      .reset(reset),
      .instr_memory_data(instr_memory_data),
      .data_memory_data(data_memory_data),
      .instr_memory_addr(instr_memory_addr),
      .data_memory_addr(data_memory_addr),
      .data_memory_wd(data_memory_wd),
      .data_memory_we(data_memory_we),
      .instr_memory_flush(instr_memory_flush),
      .instr_memory_enable(instr_memory_enable)
  );

  rom_2port rom (
      .clk_a(clk),
      .clk_b(clk),
      .en_a(instr_memory_enable),
      .en_b(0),
      .flush_a(instr_memory_flush),
      .flush_b(0),
      .addr_a(instr_memory_addr),
      .addr_b(0),
      .rd_a(instr_memory_data),
      .rd_b(0)
  );

  ram_1port ram (
      .clk (clk),
      .we  (data_memory_we),
      .addr(data_memory_addr),
      .wd  (data_memory_wd),
      .rd  (data_memory_data)
  );

endmodule
