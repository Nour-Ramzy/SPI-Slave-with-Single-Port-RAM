module SPI_wrapper (MOSI,MISO,SS_n,SCK,rst_n);
input SCK,MOSI,SS_n,rst_n;
output MISO;
//
wire [9:0] rx_data;
wire [7:0] tx_data;
wire rx_valid,tx_valid;
//
spi_slave dut1(
    .clk(SCK),
    .rst_n(rst_n),
    .MOSI(MOSI),
    .SS_n(SS_n),
    .tx_data(tx_data),
    .tx_valid(tx_valid),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .MISO(MISO)
);

spi_sram dut2(
    .clk(SCK),
    .rst_n(rst_n),
    .din(rx_data),
    .rx_valid(rx_valid),
    .dout(tx_data),
    .tx_valid(tx_valid)
);

endmodule //SPI_wrapper