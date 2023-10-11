module control_unit
(
    input [2:0] op, //! tipo de op
    input [2:0] func3, //! subtipo de op
    input [10:0] func11, //! prefijo de tipo de op (reservado, sin usar por ahora)

    output reg_write, //! enable de write a regsitro
    output mem_write, //! enable de write a memoria 
    output jump, //! indica que se tiene una instr de salto 
    output jump_cond, //! indica que se tiene una instr de salto condicionado
    output [2:0] jump_cond_type //! especifica tipo de salto condicional

    output [2:0] alu_control, //! selecciona operacion de alu
    output alu_src, //! selecciona si op2 es rs2

    //! [0] indica si es sin signo
    //! [1] indica si es upper 
    //! [2:3] indican el tipo de operación (entre las que usan inmediato)
    output [3:0] imm_src, 
    output [1:0] result_src //! selector de resultado final
);

typedef enum bit[2:0] {
    OP_A  = 3'b000, // rd rs1 rs2, func3 y func11. ALU con regs si func11 = 0
    OP_B  = 3'b001, // rd rs1 imm_16 func3, ALU con inmediatos 
    OP_C  = 3'b010, // rs1, rs2 , imm_16, func3.  Solo STM (escribe memoria)
    OP_D  = 3'b011, // rd, imm_21 clir, cuir y jll
    OP_E  = 3'b100, // reservado
    OP_F  = 3'b101, // rd, rs1, imm_16. ldm y jlrl
    OP_G  = 3'b110, // rs1, rs2, imm_18:2. Jumps condicionales
    OP_H  = 3'b111  // reservado
}op_type;

typedef enum bit[2:0] {
    CLIR = 3'b000, 
    CUIR  = 3'b001, 
    JLL  = 3'b010
}func3_d;

typedef enum bit[2:0] {
    LDM = 3'b000, 
    JLRL  = 3'b010
}func3_f;

typedef enum bit [1:0]{
    RESULT_SRC_DEFAULT = 2'b00,
    RESULT_SRC_ALURES = 2'b00,
    RESULT_SRC_MEMRD = 2'b01,
    RESULT_SRC_PCPLUS4 = 2'b10,
    RESULT_SRC_IMM = 2'b11 // CLIR y CUIR
}result_src_t;

assign reg_write = ~(op[1:0] == 2'b10); // aplica para todos excepto tipo c y tipo g
assign mem_write = (op == OP_C); 
assign jump = ((op==OP_D) || (op==op_F));
assign jump_cond = (op == OP_G);
assign jump_cond_type = func3; // solo importa para tipo g
assign alu_src = (op[1:0] == 2'b01); // aplica para tipo b o f

always @(*) begin
    case (op_t)
        OP_A: begin
            alu_control = func3; 
            imm_src = 4'b0; // no importa
            result_src = RESULT_SRC_ALURES;
        end 
        OP_B: begin 
            alu_control = func3;
            imm_src = (func3[2] == 1'b1) 4'b0010 : 4'b0000; // se extiende en 0 para shifts
            result_src = RESULT_SRC_ALURES;
        end 
        OP_C: begin // solo STM
            alu_control = 3'b0; // suma dir a escribir 
            imm_src = 4'b100; // usa inmediato con signo extendido
            result_src = RESULT_SRC_DEFAULT; // no necesita result
        end 
        OP_D: begin  // CLIR, CUIR y JLL
            alu_control = 3'b0; // suma 
            case (func3)
                CLIR: begin 
                    imm_src = 4'b1100;
                    result_src = RESULT_SRC_IMM; 
                end
                CUIR: begin  
                    imm_src = 4'b1110;
                    result_src = RESULT_SRC_IMM; 
                end
                default: begin  
                    imm_src = 4'b1100;
                    result_src = RESULT_SRC_PCPLUS4; 
                end
            endcase
        end 
        /*OP_E: begin 
            
        end*/ 
        OP_F: begin 
            alu_control = 3'b0; // suma dir de ldm o registro de jump + label
            imm_src = 4'b0000; // inmediato con extensión de signo
            result_src = (func3 == LDM) ? RESULT_SRC_MEMRD : RESULT_SRC_PCPLUS4;
        end 
        OP_G: begin 
            alu_control = 3'b1; // resta para hacer comp
            imm_src = 4'b1100; // inmediato con extensión de signo, [18:2] 
            result_src = RESULT_SRC_DEFAULT; // no necesita result
        end 
        /*OP_H: begin 
            
        end */
        default: begin
            alu_control = 3'b00;  
            imm_src = 4'b000;
            result_src = 2'b00;
        end 
    endcase
end


endmodule 