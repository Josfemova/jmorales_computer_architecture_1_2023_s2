typedef enum bit [2:0] {
  ALU_OP_SUM = 3'b000,  // suma
  ALU_OP_DIF = 3'b001,  // resta
  ALU_OP_AND = 3'b010,  // and
  ALU_OP_ORR = 3'b011,  // or 
  ALU_OP_XOR = 3'b100,  // xor 
  ALU_OP_SLL = 3'b101,  // shift logical left
  ALU_OP_SLR = 3'b110,  // shift logical right
  ALU_OP_SAR = 3'b111   // shift arithmethical right (no implementado para guardar espacio)
} alu_op;


module alu #(
    parameter WIDTH = 32
) (
    input [WIDTH-1:0] op1,
    input [WIDTH-1:0] op2,
    input bit [2:0] alu_control,
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

  assign negative = (result[31] == 1);
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
      default: result = 0;
    endcase
  end

  assign flags = {negative, zero, carry, overflow};

endmodule
