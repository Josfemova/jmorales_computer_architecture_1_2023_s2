module hazard_unit (
    input de_rs1,
    input de_rs2,
    input ex_rs1,
    input ex_rs2,
    input ex_rd,
    input ex_pc_src,
    input ex_result_src0,
    input mem_rd,
    input mem_reg_write,
    input wb_rd,
    input wb_reg_write,

    output if_stall,
    output de_stall,
    output de_flush,
    output ex_flush,
    output [1:0] ex_op1_forward,
    output [1:0] ex_op2_forward
);

endmodule
