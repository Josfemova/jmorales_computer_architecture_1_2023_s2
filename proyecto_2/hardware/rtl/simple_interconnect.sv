module simple_interconnect
#(
    parameter WIDTH=32, 
    REGIONS=5)
(
    input we_m, 
    input [WIDTH-1:0] addr_m, wd_m,
    input [(REGIONS * WIDTH)-1:0] rd_s,
    input [(REGIONS * WIDTH)-1:0] region_base, 
    input [(REGIONS * WIDTH)-1:0] region_end, 
    output logic [REGIONS-1:0] we_s,
    output logic [(REGIONS*WIDTH)-1:0] addr_s,
    output logic [(REGIONS*WIDTH)-1:0] wd_s,
    output logic [WIDTH-1:0] rd_m
);

genvar i;
generate
    for(i=0; i<REGIONS; i = i+1) begin: gen_region_check
        always_comb begin : blockName
            if (addr_m>= region_base[0] && addr_m < region_end[0]) begin 
                we_s[i] = we_m; 
                addr_s[WIDTH*i+:WIDTH] =  addr_m;
                wd_s[WIDTH*i+:WIDTH] = wd_m;
                rd_m = rd_s[WIDTH*i+:WIDTH];
            end else begin 
                we_s[i] = 0; 
                addr_s[WIDTH*i+:WIDTH] =  0;
                wd_s[WIDTH*i+:WIDTH] = 0;
                rd_m = 0;
            end
        end
    end
endgenerate

endmodule