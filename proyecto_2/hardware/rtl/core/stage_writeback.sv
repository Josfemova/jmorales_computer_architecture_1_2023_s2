module stage_writeback(

    input [1:0] wb_result_src,
    // inputs del data path
    input [31:0] wb_alu_result,
    input [31:0] wb_read_result,
    input [31:0] wb_pc_plus_4,
    input [31:0] wb_imm_ext,
    // única salida
    output reg [31:0] wb_result
);

always @(*) begin
    case (wb_result_src)
        2'b01: wb_result =  wb_read_result;
        2'b10: wb_result =  wb_pc_plus_4;
        2'b11: wb_result = wb_imm_ext;
        default: wb_result = wb_alu_result;
    endcase
end


endmodule