module imm_extend_tb;


logic [31:0] instr = 32'b0000_0000_0000_0000_0000_0010_0000_1000; // addi x1, x2, 
logic [3:0] imm_src;
logic [31:0] imm_out;

imm_extend extend(
    .imm_in(instr[31:6]),
    .imm_src(imm_src),
    .imm_out(imm_out)
);

initial begin
    #10 
    imm_src =  4'b0;
    #10 
    imm_src =  4'b1;
    #10 
    imm_src =  4'b10;
    #10 
    imm_src =  4'b11;
    #10 
    imm_src =  4'b100;
    #10 
    imm_src =  4'b101;
    #10 
    imm_src =  4'b110;
    #10 
    imm_src =  4'b111;
    #10 
    imm_src =  4'b1000;
    #10 
    imm_src =  4'b1001;


end 



endmodule