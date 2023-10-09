typedef enum bit[2:0] {
    OP_A  = 3'b000, //! rd rs1 rs2, func3 y func11. ALU con regs si func11 = 0
    OP_B  = 3'b001, //! rd rs1 imm, func3, ALU con inmediatos 
    OP_C  = 3'b010, //! rd, imm, func3. 
    OP_D  = 3'b011, //! 
    OP_E  = 3'b100, //! 
    OP_F  = 3'b101, //! 
    OP_G  = 3'b110, //! 
    OP_G  = 3'b111  //!
}op_type;

module control_unit
(
    input [2:0] op_t,
    input [2:0] func3,
    input [10:0] func11,

    output reg_write, //! enable de write a regsitro
    output mem_write, //! enable de write a memoria 
    output jump, //! indica que se tiene una instr de salto 
    output jump_cond, //! indica que se tiene una instr de salto condicionado

    output [2:0] alu_control, //! selecciona operacion de alu
    output alu_src, //! selecciona si op2 es rs2

    output imm_sign_extend, //! indica si se debe extender signo de imm
    output imm_is_upper, //! indica si el imm se carga a los bits superiores
    output imm_sel_21, //! indica si el imm se considera de 21 bits

    output [1:0] result_src //! selector de resultado final
);

always @(*) begin
    case (op_t)
        OP_A: begin 
            
        end 
        default: 
    endcase
end


endmodule 