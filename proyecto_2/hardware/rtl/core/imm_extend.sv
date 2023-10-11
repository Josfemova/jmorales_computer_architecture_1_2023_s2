module imm_extend
(
    input [25:0] imm_in, //! datos en seco provenientes de instrucción
    input [3:0] imm_src, //! selecciona src de imm, 0 si es reg, 1 si es imm
    output [31:0] imm_out //! inmediato de salida
);

wire sign; //! signo, por defecto se extiende el signo (por eso el check a 0)
assign sign = (imm_src[0] == 1'b0) ? imm_in[25]: 1'b0;

wire [15:0] imm_type_bf;
wire [15:0] imm_type_c;
wire [20:0] imm_type_d;
wire [17:0] imm_type_g;

assign imm_type_bf = imm_in[25-:16];
assign imm_type_c = {imm_in[25-:11], imm_in[10-:5]};
assign imm_type_d = imm_in[25-:21];
assign imm_type_g = {imm_type_c, 2'b00}; // alineado a 4

// upper solo se permite para inmediato de instr tipo c como Copy to Reg
always @(*)  begin 
    case (imm_src)
        3'b0000, 3'b0001: imm_out = {{16{sign}}, imm_type_bf}; // op tipo b y f
        3'b0100, 3'b0101: imm_out = {{16{sign}}, imm_type_c}; // op tipo c
        3'b1000, 3'b1001: imm_out = {{14{sign}}, imm_type_g}; // op tipo g
        3'b1100, 3'b1101: imm_out = {{11{sign}}, imm_type_d}; // lower, op tipo d. Zero extended no se usa
        default: imm_out = {imm_type_c, {11{1'b0}}}; // upper, op tipo d
    endcase
end

endmodule