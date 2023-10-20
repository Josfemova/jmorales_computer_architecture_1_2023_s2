typedef enum bit [3:0] {
  ALU_OP_SUM = 4'b0000,  // suma
  ALU_OP_DIF = 4'b0001,  // resta
  ALU_OP_AND = 4'b0010,  // and
  ALU_OP_ORR = 4'b0011,  // or 
  ALU_OP_XOR = 4'b0100,  // xor 
  ALU_OP_SLL = 4'b0101,  // shift logical left
  ALU_OP_SLR = 4'b0110,  // shift logical right
  ALU_OP_SAR = 4'b0111,  // shift arithmethical right (no implementado para guardar espacio)
  ALU_OP_MUL = 4'b1000,  // multiplicacion
  // espacio reservado para otras mul
  ALU_OP_DIV = 4'b1100   // division
  // espacio reservado para otras relacionadas a div
} alu_op;


module alu #(
    parameter WIDTH = 32
) (
    input [WIDTH-1:0] op1,
    input [WIDTH-1:0] op2,
    input bit [3:0] alu_control,
    output logic [3:0] flags,
    output logic [WIDTH-1:0] result
);

  logic overflow, carry, negative, zero;

  wire carry_in;
  wire [WIDTH:0] sum_res;
  wire [WIDTH-1:0] sum_op2;
  assign carry_in = alu_control[0];
  assign sum_op2 = (alu_control[0] == 0) ? op2 : ~op2;
  assign sum_res = op1 + sum_op2 + carry_in;

  assign negative = (result[WIDTH-1] == 1);
  assign zero = (result == 0);

  always @(*) begin
    overflow = 0;
    carry = 0;
    case (alu_control)
      ALU_OP_SUM, ALU_OP_DIF: begin
        {carry, result} = sum_res;
        overflow = ~(alu_control[0]^op1[WIDTH-1]^op2[WIDTH-1]) & (op1[WIDTH-1]^result[WIDTH-1]);
      end
      ALU_OP_AND: result = op1 & op2;
      ALU_OP_ORR: result = op1 | op2;
      ALU_OP_XOR: result = op1 ^ op2;
      ALU_OP_SLL: result = op1 << op2;  // barrel shifter 
      ALU_OP_SLR: result = op1 >> op2;  // barrel shifter 
      ALU_OP_SAR: result = $signed(op1) >>> op2;
      ALU_OP_MUL: result = $signed(op1) * $signed(op2);
      default: result = 0;  // div no implementada aun 
    endcase
  end

  assign flags = {negative, zero, carry, overflow};

endmodule
