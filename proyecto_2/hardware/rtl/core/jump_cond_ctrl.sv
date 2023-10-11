module jump_cond_ctrl (
    input jump_cond,
    input [2:0] jump_cond_type,
    input [3:0] alu_flags,
    output jump_cond_true
);

  typedef enum bit [2:0] {
    COND_EQ = 3'b000,  // ==
    COND_NE = 3'b001,  // =/=
    COND_GT = 3'b010,  // >
    COND_LT = 3'b011,  // < 
    COND_GE = 3'b100,  // >=
    COND_LE = 3'b101   // <=
  } jump_cond_t;

  wire negative, zero, carry, overflow, ge, gt;
  assign {negative, zero, carry, overflow} = alu_flags;
  assign ge = (negative == overflow);
  assign gt = (~zero & ge);

  always @(*) begin
    if (jump_cond) begin
      case (jump_cond_type)
        COND_EQ: jump_cond_true = zero;
        COND_NE: jump_cond_true = ~zero;
        COND_GT: jump_cond_true = gt;
        COND_LT: jump_cond_true = ~ge;
        COND_GE: jump_cond_true = ge;
        COND_LE: jump_cond_true = ~gt;
        default: jump_cond_true = 1'b0;
      endcase
    end else begin
      jump_cond_true = 1'b0;
    end
  end

endmodule
