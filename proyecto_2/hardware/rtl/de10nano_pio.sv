module de10nano_pio #(
    parameter WIDTH = 32
) (
    output [ 7:0] LED,
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
  logic [ 7:0] LED_w;
  logic [31:0] GPIO0_w;  // no importa no usar todos
  logic [31:0] GPIO1_w;  // no importa no usar todos

  logic [31:0] GPIO0_r;  // no importa no usar todos
  logic [31:0] GPIO1_r;  // no importa no usar todos

  reg   [31:0] GPIO0_DIR;  // 1 es output
  reg   [31:0] GPIO1_DIR;  // 1 es output

  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin : gen_gpio_ctrl
      assign GPIO0[i]   = (GPIO0_DIR[i]) ? GPIO0_w : 1'bz;
      assign GPIO0_r[i] = (GPIO0_DIR[i]) ? GPIO0_w[i] : GPIO0[i];
      assign GPIO1[i]   = (GPIO1_DIR[i]) ? GPIO0_w : 1'bz;
      assign GPIO1_r[i] = (GPIO1_DIR[i]) ? GPIO1_w[i] : GPIO1[i];
    end
  endgenerate

  always @(*) begin
    LED = LED_w;
    case (addr[4:2])
      3'b001: begin
        port_r = {28'b0, SW};
      end
      3'b010: begin
        port_r = {30'b0, KEY};
      end
      3'b011: begin
        port_r = GPIO0_r;
      end
      3'b100: begin
        port_r = GPIO0_DIR;
      end
      3'b101: begin
        port_r = GPIO1_r;
      end
      3'b110: begin
        port_r = GPIO1_DIR;
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
        3'b000: LED_w <= wd[7:0];
        3'b011: GPIO0_w <= wd;
        3'b100: GPIO0_DIR <= wd;
        3'b101: GPIO1_w <= wd;
        3'b110: GPIO1_DIR <= wd;
      endcase
    end
  end


endmodule
