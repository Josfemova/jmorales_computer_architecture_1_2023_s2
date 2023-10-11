module stage_instruction_fetch(
    input clk, 
    input if_stall, de_stall, de_flush
    input ex_pc_src // selecciona pc source 
    input [31:0] ex_pc_target,
    input [31:0] if_instr_rd, // de la memoria rom 
    output reg [31:0] de_instr, // a la memoria rom y a reg de decode
    output reg [31:0] de_pc, de_pc_plus4
    
);

wire [31:0] if_pc_plus4;
wire [31:0] if_pc_next;
wire [31:0] if_pc;

assign if_pc_plus4 = pc + 4;
assign if_pc_next = (ex_pc_src == 0) ? if_pc_plus4 : ex_pc_target;

always @(posedge clk) begin
    if (~if_stall) if_pc <= if_pc_next;
end

// señales de siguiente etapa
// solo rutear la info que viene de la rom, la rom recibe de_stall y de_flush
assign de_instr = if_instr_rd; 
always @(posedge clk) begin
    if(de_flush) begin 
        de_pc <= 0;
        de_pc_plus4 <= 0;
    end 
    else if (~de_stall) begin 
        de_pc <= if_pc;
        de_pc_plus4 <= if_pc_plus4;
    end 
end


endmodule