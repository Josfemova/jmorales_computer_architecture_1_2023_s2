module hazard_unit(
    input id_rs1, id_rs2, 
    input ex_rs1, ex_rs2, ex_rd, ex_pc_src, ex_result_src0,
    input mem_rd, mem_reg_write,
    input wb_rd, wb_reg_write
    output if_stall, id_stall,
    output id_flush, ex_flush, 
    output[1:0] ex_op1_forward, ex_op2_forward,  
);

endmodule