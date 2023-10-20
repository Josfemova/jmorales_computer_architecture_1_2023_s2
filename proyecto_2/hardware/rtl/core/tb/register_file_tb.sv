module register_file_tb;
  reg clk;
  reg we3;
  reg [4:0] a1;
  reg [4:0] a2;
  reg [4:0] a3;
  reg [31:0] wd3;
  wire [31:0] rd1;
  wire [31:0] rd2;

  register_file #(
    .REGISTERS(32),
    .WIDTH(32)
  ) dut (
    .clk(clk),
    .we3(we3),
    .a1(a1),
    .a2(a2),
    .a3(a3),
    .wd3(wd3),
    .rd1(rd1),
    .rd2(rd2)
  );

  // clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // escribir a registro 5 y leer de 10 y 15
  
  initial begin
    we3 = 1;
    a1 = 10;
    a2 = 15;
    a3 = 5;
    wd3 = 32'hABCDE123; 
    #10; 
    we3 = 0; 
    #10;


  // Leer de registro 0 y 31
    we3 = 0; // deshabilita write
    a1 = 0;
    a2 = 31;
    a3 = 0; 
    wd3 = 32'h0; 
    #10; 

	// escribir a registro 7 y leer del 14 y 21
	
	  we3 = 1;
	  a1 = 14;
	  a2 = 21;
	  a3 = 7;
	  wd3 = 32'h12345678; 
	  #10; 
	  we3 = 0; 
	  #10;
	

	// escribir al registro 1 y leer del 2 y 3
	  we3 = 1;
	  a1 = 2;
	  a2 = 3;
	  a3 = 1;
	  wd3 = 32'hABCDEFFF;
	  #10; 
	  we3 = 0; 
	  #10;
	  
	end

endmodule
