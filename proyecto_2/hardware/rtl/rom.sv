module rom_2port
#(
	parameter 
	WIDTH = 32, 
	LENGTH = 256
	//INIT_FILE = "program.txt"
)
(
	// se agregan enables para el pipeline
	input clk_a, clk_b, en_a, en_b
	input [(WIDTH-1):0] addr_a, addr_b,
	output logic [(WIDTH-1):0] rd_a, rd_b
);
	reg [(WIDTH-1):0] rom[(LENGTH-1):0];

	initial begin
		//$readmemh(INIT_FILE,rom);
	end

	always @(posedge clk_a)
	begin
		if (en_a) rd_a <= rom[addr_a[WIDTH-1:2]];
	end

	always @(posedge clk_b)
	begin
		if (en_b) rd_b <= rom[addr_b[WIDTH-1:2]];
	end
endmodule