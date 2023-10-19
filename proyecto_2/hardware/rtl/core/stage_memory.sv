module stage_memory (
    input clk,
    input wb_clear,

    // inputs de control unit
    input mem_reg_write,
    input mem_mem_write,
    input [1:0] mem_result_src,

    // inputs del data path
    input [31:0] mem_alu_result,
    input [31:0] mem_write_data,
    input [31:0] mem_pc_plus_4,
    input [31:0] mem_imm_ext,
    input [ 4:0] mem_rd,

    // input de la memoria de datos 
    input [31:0] mem_read_result,

    // outputs de control unit
    output reg wb_reg_write,
    output reg [1:0] wb_result_src,

    // outputs del data path
    output reg [31:0] wb_alu_result,
    output reg [31:0] wb_read_result,
    output reg [31:0] wb_pc_plus_4,
    output reg [31:0] wb_imm_ext,
    output reg [ 4:0] wb_rd
);
  // memoria sync
  assign wb_read_result = mem_read_result;
  always @(posedge clk) begin
    if (wb_clear) begin
      wb_reg_write <= 0;
      wb_result_src <= 0;
      wb_alu_result <= 0;
      wb_pc_plus_4 <= 0;
      wb_imm_ext <= 0;
      wb_rd <= 0;
    end else begin
      wb_reg_write <= mem_reg_write;
      wb_result_src <= mem_result_src;
      wb_alu_result <= mem_alu_result;
      wb_pc_plus_4 <= mem_pc_plus_4;
      wb_imm_ext <= mem_imm_ext;
      wb_rd <= mem_rd;
    end
  end



endmodule
