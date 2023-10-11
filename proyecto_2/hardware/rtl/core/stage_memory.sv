module stage_memory (
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

endmodule
