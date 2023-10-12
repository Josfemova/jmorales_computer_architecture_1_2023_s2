module stage_writeback(

    input reg [1:0] wb_result_src,
    
    // inputs del data path
    input reg [31:0] wb_alu_result,
    input reg [31:0] wb_read_result,
    input reg [31:0] wb_pc_plus_4,
    input reg [31:0] wb_imm_ext,
    
    // única salida
    output reg [31:0] wb_result
);

always @(*) begin
    case (wb_result_src)
        2'b01: wb_read_result;
        2'b10: wb_pc_plus_4;
        2'b11: wb_imm_extñ 
        default: wb_alu_result;
    endcase
end


endmodule