module stage_execute (
    input clk,
    input mem_clear,
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
    //input [4:0] ex_rs1,
    //input [4:0] ex_rs2,

    // inputs de otras etapas
    //input [31:0] mem_alu_result, // se tiene a nivel interno
    input [31:0] wb_result,

    // inputs de hazard unit
    input [1:0] ex_op1_forward,
    input [1:0] ex_op2_forward,

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
    // output para la hazard unit
    output ex_pc_src,
    // posible pc target 
    output [31:0] ex_pc_target

);


  // señales internas del stage
  wire [31:0] op1;
  wire [31:0] write_data;
  wire [31:0] op2;
  wire [3:0] alu_flags;
  wire jump_cond_true;
  wire [31:0] alu_result;
  reg [31:0] mem_alu_result_proxy;



  always @(*) begin
    case (ex_op1_forward)
      2'b01:   op1 = wb_result;
      2'b10:   op1 = mem_alu_result_proxy;
      default: op1 = ex_rd1;
    endcase

    case (ex_op2_forward)
      2'b01:   write_data = wb_result;
      2'b10:   write_data = mem_alu_result_proxy;
      default: write_data = ex_rd2;
    endcase
  end


  jump_cond_ctrl cond_unit (
      .jump_cond(ex_jump_cond),
      .jump_cond_type(ex_jump_cond_type),
      .alu_flags(alu_flags),
      .jump_cond_true(jump_cond_true)
  );


  alu alu0 (
      .op1(op1),
      .op2(op2),
      .alu_control(ex_alu_control),
      .flags(alu_flags),
      .result(alu_result)
  );

  assign op2 = (ex_alu_src) ? ex_imm_ext : write_data;
  
  
  assign mem_alu_result  = mem_alu_result_proxy;
  assign ex_pc_target = ex_pc + ex_imm_ext;
  assign ex_pc_src = (ex_jump_cond & jump_cond_true) | (ex_jump);

  always @(posedge clk) begin
    if (mem_clear) begin
      // outputs de control unit
      mem_reg_write  <= 0;
      mem_mem_write  <= 0;
      mem_result_src <= 0;

      // outputs del data path
      mem_alu_result <= 0;
      mem_write_data <= 0;
      mem_pc_plus_4  <= 0;
      mem_imm_ext    <= 0;
      mem_rd         <= 0;
    end else begin
      // outputs de control unit
      mem_reg_write  <= ex_reg_write;
      mem_mem_write  <= ex_mem_write;
      mem_result_src <= ex_result_src;

      // outputs del data path
      mem_alu_result_proxy <= alu_result;
      mem_write_data <= write_data;
      mem_pc_plus_4  <= ex_pc_plus_4;
      mem_imm_ext    <= ex_imm_ext;
      mem_rd         <= ex_rd;
    end
  end

endmodule
