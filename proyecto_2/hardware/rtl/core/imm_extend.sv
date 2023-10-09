module imm_extend
(
    input [25:0] imm_in,
    input [2:0] imm_src, //! selecciona src de imm
    output [31:0] imm_out
);

wire sign; //! signo, por defecto se extiende el signo (por eso el check a 0)
assign sign = (imm_src[0] == 1'b0) ? imm_in[25]: 1'b0;

wire imm_type_b, imm_type_c, imm_type_d, imm_type_e;
assign imm_type_b = imm_in[25-:16];
assign imm_type_c = {imm_in[25-:11], imm_in[10-:5]};
assign imm_type_d = imm_in[25-:21];
assign imm_type_e = {imm_type_c, 2'b00}; // alineado a 4
// upper solo se permite para inmediato de instr tipo c como Copy to Reg
always @(*)  begin 
    case (imm_src)
        3'b000, 3'b001: imm_out = {{16{sign}}, imm_type_b}; // op tipo b
        3'b010, 3'b011: imm_out = {{16{sign}}, imm_type_c}; // op tipo c
        3'b100, 3'b101: imm_out = {{14{sign}}, imm_type_e}; // op tipo e
        3'b110, 3'b111: imm_out = {{11{sign}}, imm_type_d}; // lower, op tipo d
        default: imm_out = {imm_type_c, {11{1'b0}}}; // upper, op tipo d
    endcase
end

endmodule