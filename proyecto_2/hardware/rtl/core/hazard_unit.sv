module hazard_unit (
    input de_rs1,
    input de_rs2,
    input ex_rs1,
    input ex_rs2,
    input ex_rd,
    input ex_pc_src,
    input [1:0] ex_result_src,
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

// a diferencia del RV del libro, 2b11 corresponde al valor del imm, entonces si se chequea 
// igualdad a 2'b01 que selecciona la salida del dato leído de memoria. 
wire ldm_hazard_stall = (ex_result_src == 2'b01) & ((de_rs1 == ex_rs1) | (de_rs2 == ex_rs2));
assign if_stall = ldm_hazard_stall;
assign de_stall = ldm_hazard_stall;
assign de_flush = ex_pc_src;
ex_flush = ldm_hazard_stall | ex_pc_src;

always @(*) begin
    // adelantamiento de rs1
    if (((ex_rs1 = mem_rd) & mem_reg_write) & (ex_rs1 !=0 )) begin
        ex_op1_forward = 2'b10; 
    end else if (((ex_rs1 == wb_rd) & wb_rd) & (ex_rs1 !=0)) begin 
        ex_op1_forward = 2'b01;
    end else begin 
        ex_op1_forward = 2'00
    end 
    // adelantamiento de rs2
    if (((ex_rs2 = mem_rd) & mem_reg_write) & (ex_rs2 !=0 )) begin
        ex_op2_forward = 2'b10; 
    end else if (((ex_rs2 == wb_rd) & wb_rd) & (ex_rs2 !=0)) begin 
        ex_op2_forward = 2'b01;
    end else begin 
        ex_op2_forward = 2'00
    end 
end

endmodule
