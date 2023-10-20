//`define ENABLE_HPS

module top (

    ///////// ADC /////////
    output ADC_CONVST,
    output ADC_SCK,
    output ADC_SDI,
    input  ADC_SDO,

    ///////// ARDUINO /////////
    inout [15:0] ARDUINO_IO,
    inout        ARDUINO_RESET_N,

    ///////// FPGA /////////
    input FPGA_CLK1_50,
    input FPGA_CLK2_50,
    input FPGA_CLK3_50,

    ///////// GPIO /////////
    inout [35:0] GPIO_0,
    inout [35:0] GPIO_1,

    ///////// HDMI /////////
    inout         HDMI_I2C_SCL,
    inout         HDMI_I2C_SDA,
    inout         HDMI_I2S,
    inout         HDMI_LRCLK,
    inout         HDMI_MCLK,
    inout         HDMI_SCLK,
    output        HDMI_TX_CLK,
    output [23:0] HDMI_TX_D,
    output        HDMI_TX_DE,
    output        HDMI_TX_HS,
    input         HDMI_TX_INT,
    output        HDMI_TX_VS,

`ifdef ENABLE_HPS
    ///////// HPS /////////
    inout         HPS_CONV_USB_N,
    output [14:0] HPS_DDR3_ADDR,
    output [ 2:0] HPS_DDR3_BA,
    output        HPS_DDR3_CAS_N,
    output        HPS_DDR3_CKE,
    output        HPS_DDR3_CK_N,
    output        HPS_DDR3_CK_P,
    output        HPS_DDR3_CS_N,
    output [ 3:0] HPS_DDR3_DM,
    inout  [31:0] HPS_DDR3_DQ,
    inout  [ 3:0] HPS_DDR3_DQS_N,
    inout  [ 3:0] HPS_DDR3_DQS_P,
    output        HPS_DDR3_ODT,
    output        HPS_DDR3_RAS_N,
    output        HPS_DDR3_RESET_N,
    input         HPS_DDR3_RZQ,
    output        HPS_DDR3_WE_N,
    output        HPS_ENET_GTX_CLK,
    inout         HPS_ENET_INT_N,
    output        HPS_ENET_MDC,
    inout         HPS_ENET_MDIO,
    input         HPS_ENET_RX_CLK,
    input  [ 3:0] HPS_ENET_RX_DATA,
    input         HPS_ENET_RX_DV,
    output [ 3:0] HPS_ENET_TX_DATA,
    output        HPS_ENET_TX_EN,
    inout         HPS_GSENSOR_INT,
    inout         HPS_I2C0_SCLK,
    inout         HPS_I2C0_SDAT,
    inout         HPS_I2C1_SCLK,
    inout         HPS_I2C1_SDAT,
    inout         HPS_KEY,
    inout         HPS_LED,
    inout         HPS_LTC_GPIO,
    output        HPS_SD_CLK,
    inout         HPS_SD_CMD,
    inout  [ 3:0] HPS_SD_DATA,
    output        HPS_SPIM_CLK,
    input         HPS_SPIM_MISO,
    output        HPS_SPIM_MOSI,
    inout         HPS_SPIM_SS,
    input         HPS_UART_RX,
    output        HPS_UART_TX,
    input         HPS_USB_CLKOUT,
    inout  [ 7:0] HPS_USB_DATA,
    input         HPS_USB_DIR,
    input         HPS_USB_NXT,
    output        HPS_USB_STP,
`endif  /*ENABLE_HPS*/

    ///////// KEY /////////
    input [1:0] KEY,

    ///////// LED /////////
    output [7:0] LED,

    ///////// SW /////////
    input [3:0] SW
);

  wire clk;
  assign clk = FPGA_CLK1_50;
  wire reset;
  assign reset = SW[0];
  logic [31:0] instr_memory_data;
  logic [31:0] data_memory_data;
  logic [31:0] instr_memory_addr;
  logic [31:0] data_memory_addr;
  logic [31:0] data_memory_wd;
  logic instr_memory_enable;
  logic data_memory_we;

  core_top dut (
      .clk(clk),
      .reset(reset),
      .instr_memory_data(instr_memory_data),
      .data_memory_data(data_memory_data),
      .instr_memory_addr(instr_memory_addr),
      .data_memory_addr(data_memory_addr),
      .data_memory_wd(data_memory_wd),
      .data_memory_we(data_memory_we),
      .instr_memory_enable(instr_memory_enable)
  );

  logic rom0_we;  // dummy
  logic [31:0] rom0_addr;
  logic [31:0] rom0_wd;  // dummy
  logic [31:0] rom0_rd;

  logic rom1_we;  // dummy
  logic [31:0] rom1_addr;
  logic [31:0] rom1_wd;  // dummy
  logic [31:0] rom1_rd;
  assign rom1_rd[31:16] = 16'b0;

  logic rom2_we;  // dummy
  logic [31:0] rom2_addr;
  logic [31:0] rom2_wd;  // dummy
  logic [31:0] rom2_rd;
  assign rom2_rd[31:16] = 16'b0;

  logic ram0_we;
  logic [31:0] ram0_addr;
  logic [31:0] ram0_wd;
  logic [31:0] ram0_rd;

  logic pio0_we;
  logic [31:0] pio0_addr;
  logic [31:0] pio0_wd;
  logic [31:0] pio0_rd;

  rom_2port #(
      .INIT_FILE("../../software/program/output_files/reverb.txt")
  ) rom0 (
      .clk_a (clk),
      .clk_b (clk),
      .en_a  (instr_memory_enable),
      .en_b  (1'b1),
      .addr_a(instr_memory_addr),
      .addr_b(rom0_addr),
      .rd_a  (instr_memory_data),
      .rd_b  (rom0_rd)
  );

  // para audio sin reverb
  rom_1port #(
      .INIT_FILE("/tmp/vitas.txt")
  ) rom1 (
      .clk (clk),
      //.en  (1'b1),
      .addr(rom1_addr),
      .rd  (rom1_rd[15:0])
  );

  // para audio con reverb
  rom_1port #(
      .INIT_FILE("/tmp/vitas_reverbed.txt")
  ) rom2 (
      .clk (clk),
      //.en  (1'b1),
      .addr(rom2_addr),
      .rd  (rom2_rd[15:0])
  );

  // para buffer circular
  ram_1port ram (
      .clk (clk),
      .we  (ram0_we),
      .addr(ram0_addr),
      .wd  (ram0_wd),
      .rd  (ram0_rd)
  );

  de10nano_pio pio (
      .LED(LED),
      .SW(SW),
      .KEY(KEY),
      .GPIO0(GPIO_0[31:0]),
      .GPIO1(GPIO_1[31:0]),
      .clk(clk),
      .we(pio0_we),
      .wd(pio0_wd),
      .addr(pio0_addr),
      .rd(pio0_rd)
  );

  simple_interconnect #(
      .REGIONS(5)
  ) bus (
      .clk(clk),
      .we_m(data_memory_we),
      .addr_m(data_memory_addr),
      .wd_m(data_memory_wd),
      .rd_s({rom2_rd, rom1_rd, pio0_rd, ram0_rd, rom0_rd}),
      .region_base({32'h0005_0000, 32'h0001_0000, 32'h0000_2000, 32'h0000_1000, 32'h0000_0000}),
      .region_end({32'h0009_0000, 32'h0005_0000, 32'h0000_3000, 32'h0000_2000, 32'h0000_1000}),
      .we_s({rom2_we, rom1_we, pio0_we, ram0_we, rom0_we}),
      .addr_s({rom2_addr, rom1_addr, pio0_addr, ram0_addr, rom0_addr}),
      .wd_s({rom2_wd, rom1_wd, pio0_wd, ram0_wd, rom0_wd}),
      .rd_m(data_memory_data)
  );

endmodule
