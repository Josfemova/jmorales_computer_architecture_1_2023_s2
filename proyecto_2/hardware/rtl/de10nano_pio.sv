module de10nano_pio #(
    parameter WIDTH = 32
) (
    output [ 5:0] LED,
    input  [ 3:0] SW,
    input  [ 1:0] KEY,
    inout  [31:0] GPIO0,  // no importa no usar todos
    inout  [31:0] GPIO1,  // no importa no usar todos

    input clk,
    input we,
    input [(WIDTH-1):0] wd,
    input [(WIDTH-1):0] addr,
    output reg [(WIDTH-1):0] rd
);

  logic [31:0] port_r;
  logic [ 5:0] LED_w;
  logic [31:0] GPIO0_w;  // no importa no usar todos
  logic [31:0] GPIO1_w;  // no importa no usar todos
  assign LED   = LED_w;
  assign GPIO0 = GPIO0_w;
  assign GPIO1 = GPIO1_w;
  always @(*) begin
    case (addr[4:2])
      3'b001: begin
        port_r = {28'b0,SW};
      end
      3'b010: begin
        port_r = {30'b0,KEY};
      end
      3'b011: begin
        port_r = GPIO0;
      end
      3'b100: begin
        port_r = GPIO1;
      end
      default: begin
        port_r = 32'b0;
      end
    endcase
  end

  always @(posedge clk) begin
    rd <= port_r;
    if (we) begin
      case (addr[4:2])
        3'b000: LED_w <= wd[5:0];
        3'b011: GPIO0_w <= wd;
        3'b100: GPIO1_w <= wd;
      endcase
    end
  end


endmodule
