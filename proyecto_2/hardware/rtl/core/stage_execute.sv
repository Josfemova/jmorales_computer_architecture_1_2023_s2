module stage_execute (

    // inputs de control unit
    input ex_reg_write,
    input ex_mem_write,
    input ex_jump,
    input ex_jump_cond,
    input [2:0] ex_jump_cond_type,
    input [2:0] ex_alu_control,
    input ex_alu_src,
    input [1:0] ex_result_src,

    // inputs del data path
    input [31:0] ex_pc,
    input [31:0] ex_pc_plus_4,
    input [31:0] ex_imm_ext,
    input [31:0] ex_rd1,
    input [31:0] ex_rd2,

    input [4:0] ex_rd,
    input [4:0] ex_rs1,
    input [4:0] ex_rs2,

    // inputs de otras etapas
    //input [31:0] mem_alu_result, // se tiene a nivel interno
    input [31:0] wb_result,

    // inputs de hazard unit
    input forward_op1,
    input forward_op2,

    // outputs de control unit
    output reg mem_reg_write,
    output reg mem_mem_write,
    output reg [1:0] mem_result_src,

    // outputs del data path
    output reg [31:0] mem_alu_result,
    output reg [31:0] mem_write_data,
    output reg [31:0] mem_pc_plus_4,
    output reg [31:0] mem_imm_ext,
    output reg [ 4:0] mem_rd,

    // output a otras etapas que no son la inmediatamente siguiente
    // y dependen de lógica combinacional
    output ex_jump_cond_true,
    // output para la hazard unit
    output ex_pc_src

);


endmodule
