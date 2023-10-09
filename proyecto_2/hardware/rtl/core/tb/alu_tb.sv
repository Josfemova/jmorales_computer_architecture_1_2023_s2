module alu_tb;

parameter W=4;

reg [2:0] UC;
reg [3:0] Flags;

logic clk=0;
logic reset;

reg [W-1:0] A,B,Q;

alu #(.WIDTH(W)) DUT(
	.op1(A),
	.op2(B),
	.alu_control(UC),
	.flags(Flags),
	.result(Q)
);

always #2 clk =~clk;

initial begin
	reset = 0;
	A = 4'b1111;
	B = 4'b0001;
	UC = 3'b101;
	#5;
	B = 4'b0010;
	#5;
	B = 4'b0011;
	#5;
	B = 4'b0100;
	#5;
	B = 4'b0101;
	#5;

end

endmodule