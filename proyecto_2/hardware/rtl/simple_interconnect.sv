//! Modulo lazy para interconexion de componentes
//! Asume que toda lectura es sincrónica a clk
module simple_interconnect #(
    parameter WIDTH = 32,
    REGIONS = 5
) (
    input clk,
    input we_m,
    input [WIDTH-1:0] addr_m,
    input [WIDTH-1:0] wd_m,
    input [(REGIONS * WIDTH)-1:0] rd_s,
    input [(REGIONS * WIDTH)-1:0] region_base,
    input [(REGIONS * WIDTH)-1:0] region_end,
    output logic [REGIONS-1:0] we_s,
    output logic [(REGIONS*WIDTH)-1:0] addr_s,
    output logic [(REGIONS*WIDTH)-1:0] wd_s,
    output logic [WIDTH-1:0] rd_m
);
  logic [WIDTH-1:0] read_addr;
  always @(posedge clk) begin
    read_addr <= addr_m;
  end

  always @(*) begin
    rd_m = 0;
    for (int i = 0; i < REGIONS; i = i + 1) begin
      addr_s[WIDTH*i+:WIDTH] = (addr_m) - region_base[WIDTH*i+:WIDTH];
      if ((addr_m >= region_base[WIDTH*i+:WIDTH]) && (addr_m < region_end[WIDTH*i+:WIDTH])) begin
        we_s[i] = we_m;
        wd_s[WIDTH*i+:WIDTH] = wd_m;
      end else begin
        we_s[i] = 1'b0;
        wd_s[WIDTH*i+:WIDTH] = 32'b0;
      end

      if ((read_addr >= region_base[WIDTH*i+:WIDTH]) && (read_addr < region_end[WIDTH*i+:WIDTH])) begin
        rd_m = rd_s[WIDTH*i+:WIDTH];
      end
    end
  end

endmodule
