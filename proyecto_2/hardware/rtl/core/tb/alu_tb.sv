module alu_tb;

  parameter W = 4;

  reg [2:0] UC;
  reg [3:0] Flags;

  logic clk = 0;
  logic reset;

  reg [W-1:0] A, B, Q;

  alu #(
      .WIDTH(W)
  ) DUT (
      .op1(A),
      .op2(B),
      .alu_control(UC),
      .flags(Flags),
      .result(Q)
  );

  always #2 clk = ~clk;

  initial begin
    reset = 0;
    A = 4'b0111;
    B = 4'b0001;
    UC = 3'b0;
    repeat (8) begin
      #10 UC += 1;
    end

    A  = 4'b0101;
    B  = 4'b0101;
    UC = 3'b0;
    repeat (8) begin
      #10 UC += 1;
    end

    A  = 4'b1101;
    B  = 4'b0111;
    UC = 3'b0;
    repeat (8) begin
      #10 UC += 1;
    end

    A  = 4'B0001;
    B  = 4'B1111;
    UC = 3'B0;
    repeat (8) begin
      #10 UC += 1;
    end


    A  = 4'B1111;
    B  = 4'B0001;
    UC = 3'B0;
    repeat (8) begin
      #10 UC += 1;
    end


    $stop;
  end

endmodule
