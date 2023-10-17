module system_tb;

  logic clk;
  logic reset;

  logic [31:0] instr_memory_data;
  logic [31:0] data_memory_data;
  logic [31:0] instr_memory_addr;
  logic [31:0] data_memory_addr;
  logic [31:0] data_memory_wd;
  logic [31:0] dummy;
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

  rom_2port #(
      .INIT_FILE("../../../rtl/simple_test.txt")
  ) rom (
      .clk_a (clk),
      .clk_b (clk),
      .en_a  (instr_memory_enable),
      .en_b  (1'b0),
      .addr_a(instr_memory_addr),
      .addr_b(32'b0),
      .rd_a  (instr_memory_data),
      .rd_b  (dummy)
  );

  ram_1port ram (
      .clk (clk),
      .we  (data_memory_we),
      .addr(data_memory_addr),
      .wd  (data_memory_wd),
      .rd  (data_memory_data)
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
    if (data_memory_addr == 32'h290) begin
      #100;
      $display("Simulation ended");
      $stop;
    end

  end



endmodule
