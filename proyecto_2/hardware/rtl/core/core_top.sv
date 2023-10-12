module core_top (
    input clk,
    input reset,
    input [31:0] instr_memory_data,
    input [31:0] data_memory_data,
    output [31:0] instr_memory_addr,
    output [31:0] data_memory_addr,
    output [31:0] data_memory_wd,
    output data_memory_we,
    output instr_memory_flush,
    output instr_memory_enable
);

  // ======== IF ============ /
  wire if_stall;
  wire [31:0] if_instr_rd;  // de la memoria rom 

  wire [31:0] if_pc_next_instr_mem;  // a addr de rom
  wire [31:0] de_pc;
  wire [31:0] de_pc_plus4;

  // ======== DE ============ /
  wire de_clear;
  wire de_stall;
  wire [31:0] de_instr;  // a la memoria rom y a reg de decode
  wire [31:0] de_pc;
  wire [31:0] de_pc_plus4;
  wire [4:0] de_rs1;
  wire [4:0] de_rs2;

  // ======== EX ============ /
  wire ex_clear;
  wire ex_reg_write;
  wire ex_mem_write;
  wire ex_jump;
  wire ex_jump_cond;
  wire [2:0] ex_jump_cond_type;
  wire [2:0] ex_alu_control;
  wire ex_alu_src;
  wire [1:0] ex_result_src;
  wire [31:0] ex_pc;
  wire [31:0] ex_pc_plus_4;
  wire [31:0] ex_imm_ext;
  wire [31:0] ex_rd1;
  wire [31:0] ex_rd2;
  wire [4:0] ex_rs1;
  wire [4:0] ex_rs2;
  wire [4:0] ex_rd;
  wire ex_pc_src;
  wire [31:0] ex_pc_target;

  // ======== MEM =========== /
  wire mem_clear;
  wire mem_reg_write;
  wire mem_mem_write;
  wire [1:0] mem_result_src;
  wire [31:0] mem_alu_result;
  wire [31:0] mem_write_data;
  wire [31:0] mem_pc_plus_4;
  wire [31:0] mem_imm_ext;
  wire [4:0] mem_rd;

  // wire de la memoria de datos 
  wire [31:0] mem_read_result;

  // ======== WB ============ /
  wire wb_clear;
  wire wb_reg_write;
  wire [1:0] wb_result_src;
  wire [31:0] wb_alu_result;
  wire [31:0] wb_read_result;
  wire [31:0] wb_pc_plus_4;
  wire [31:0] wb_imm_ext;
  wire [4:0] wb_rd;
  wire [31:0] wb_result;


  // ========= Hazard unit ========/ 
  // salidas hazard unit
  wire if_stall;
  wire de_stall;
  wire de_flush;
  wire ex_flush;
  wire [1:0] ex_op1_forward;
  wire [1:0] ex_op2_forward;

  assign instr_memory_addr = if_pc_next_instr_mem;
  assign if_instr_rd = instr_memory_data;
  assign instr_memory_enable = ~if_stall;
  assign instr_memory_flush = de_flush;

  stage_instruction_fetch instf (
      .clk(clk),
      .de_clear(de_clear),
      .if_stall(if_stall),
      .de_stall(de_stall),
      .ex_pc_src(ex_pc_src),
      .ex_pc_target(ex_pc_target),
      .if_instr_rd(if_instr_rd),
      .if_pc_next_instr_mem(if_pc_next_instr_mem),  // a addr de rom
      .de_instr(de_instr),
      .de_pc(de_pc),
      .de_pc_plus4(de_pc_plus4)
  );

  stage_decode de (
      .clk(clk),
      .ex_clear(ex_clear),
      .de_instr(de_instr),
      .de_pc(de_pc),
      .de_pc_plus4(de_pc_plus4),
      .wb_result(wb_result),
      .wb_reg_write(wb_reg_write),
      .wb_rd(wb_rd),
      .ex_reg_write(ex_reg_write),
      .ex_mem_write(ex_mem_write),
      .ex_jump(ex_jump),
      .ex_jump_cond(ex_jump_cond),
      .ex_jump_cond_type(ex_jump_cond_type),
      .ex_alu_control(ex_alu_control),
      .ex_alu_src(ex_alu_src),
      .ex_result_src(ex_result_src),
      .ex_pc(ex_pc),
      .ex_pc_plus_4(ex_pc_plus_4),
      .ex_imm_ext(ex_imm_ext),
      .ex_rd1(ex_rd1),
      .ex_rd2(ex_rd2),
      .ex_rd(ex_rd),
      .ex_rs1(ex_rs1),
      .ex_rs2(ex_rs2),
      .de_rs1(de_rs1),
      .de_rs2(de_rs2)
  );

  stage_execute ex (
      .clk(clk),
      .mem_clear(mem_clear),
      .ex_reg_write(ex_reg_write),
      .ex_mem_write(ex_mem_write),
      .ex_jump(ex_jump),
      .ex_jump_cond(ex_jump_cond),
      .ex_jump_cond_type(ex_jump_cond_type),
      .ex_alu_control(ex_alu_control),
      .ex_alu_src(ex_alu_src),
      .ex_result_src(ex_result_src),
      .ex_pc(ex_pc),
      .ex_pc_plus_4(ex_pc_plus_4),
      .ex_imm_ext(ex_imm_ext),
      .ex_rd1(ex_rd1),
      .ex_rd2(ex_rd2),
      .ex_rd(ex_rd),
      .wb_result(wb_result),
      .ex_op1_forward(ex_op1_forward),
      .ex_op2_forward(ex_op2_forward),
      .mem_reg_write(mem_reg_write),
      .mem_mem_write(mem_mem_write),
      .mem_result_src(mem_result_src),
      .mem_alu_result(mem_alu_result),
      .mem_write_data(mem_write_data),
      .mem_pc_plus_4(mem_pc_plus_4),
      .mem_imm_ext(mem_imm_ext),
      .mem_rd(mem_rd),
      .ex_pc_src(ex_pc_src),
      .ex_pc_target(ex_pc_target)
  );

  assign data_memory_addr = mem_alu_result;
  assign data_memory_wd   = mem_write_data;
  assign data_memory_we   = mem_mem_write;

  assign mem_read_result  = data_memory_data;

  stage_memory mem (

      .clk(clk),
      .wb_clear(wb_clear),
      .mem_reg_write(mem_reg_write),
      .mem_mem_write(mem_mem_write),
      .mem_result_src(mem_result_src),
      .mem_alu_result(mem_alu_result),
      .mem_write_data(mem_write_data),
      .mem_pc_plus_4(mem_pc_plus_4),
      .mem_imm_ext(mem_imm_ext),
      .mem_rd(mem_rd),
      .mem_read_result(mem_read_result),
      .wb_reg_write(wb_reg_write),
      .wb_result_src(wb_result_src),
      .wb_alu_result(wb_alu_result),
      .wb_read_result(wb_read_result),
      .wb_pc_plus_4(wb_pc_plus_4),
      .wb_imm_ext(wb_imm_ext),
      .wb_rd(wb_rd)
  );
  stage_writeback wb (
      .wb_result_src(wb_result_src),
      .wb_alu_result(wb_alu_result),
      .wb_read_result(wb_read_result),
      .wb_pc_plus_4(wb_pc_plus_4),
      .wb_imm_ext(wb_imm_ext),
      .wb_result(wb_result)
  );

  hazard_unit hazard_u (
      .de_rs1(de_rs1),
      .de_rs2(de_rs2),
      .ex_rs1(ex_rs1),
      .ex_rs2(ex_rs2),
      .ex_rd(ex_rd),
      .ex_pc_src(ex_pc_src),
      .ex_result_src(ex_result_src),
      .mem_rd(mem_rd),
      .mem_reg_write(mem_reg_write),
      .wb_rd(wb_rd),
      .wb_reg_write(wb_reg_write),
      .if_stall(if_stall),
      .de_stall(de_stall),
      .de_flush(de_flush),
      .ex_flush(ex_flush),
      .ex_op1_forward(ex_op1_forward),
      .ex_op2_forward(ex_op2_forward)
  );




endmodule
