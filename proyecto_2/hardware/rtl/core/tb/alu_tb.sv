module alu_tb;

  parameter W = 32;

  reg [3:0] UC;
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
    A = 7;
    B = 1;
    UC = 3'b0;
    repeat (8) begin
      #10 UC += 1;
    end
    UC = 4'b1000;
    #10;
    UC = 4'b1001;
    #10;

    A  = 5;
    B  = 5;
    UC = 4'b0;
    repeat (8) begin
      #10 UC += 1;
    end
    UC = 4'b1000;
    #10;
    UC = 4'b1001;
    #10;

    A  = -3;
    B  = 7;
    UC = 4'b0;
    repeat (8) begin
      #10 UC += 1;
    end
    UC = 4'b1000;
    #10;
    UC = 4'b1001;
    #10;

    A  = 1;
    B  = -1;
    UC = 4'B0;
    repeat (8) begin
      #10 UC += 1;
    end
    UC = -8;
    #10;
    UC = -7;
    #10;

    A  = 3;
    B  = 1;
    UC = 4'B0;
    UC = 4'b1000;
    repeat (10) begin
      #10 B += 1;
    end

    A  = 32'h80000000;
    B  = 1;
    UC = 4'b0111;
    repeat (10) begin
      #10 B += 1;
    end

    A  = 32'h7000;
    B  = 32'hFFF;
    UC = 4'b1000;
    repeat (10) begin
      #10 A += 32'h100;
    end

    A  = 32'hF0F0F0F0;
    B  = -1;
    UC = 4'B100;
    repeat (10) begin
      #10 A += 32'hF;
    end
    $stop;
  end

endmodule
