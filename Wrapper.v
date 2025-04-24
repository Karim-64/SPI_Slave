module SPI_slave_top_module(
    input  MOSI,
    input  SS_n,
    input  clk,
    input  rst_n,
    output MISO
);
    wire [9:0] rx_data;
    wire [7:0] tx_data;
    wire rx_valid, tx_valid;
    // SPI_slave module
    spi_slave_if SPI_Slave(
        .MOSI(MOSI),
        .SS_n(SS_n),    
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),      
        .tx_valid(tx_valid),    
        .MISO(MISO),
        .rx_data(rx_data),      
        .rx_valid(rx_valid)     
    );
    // MEMORY module 
    spi_sync_ram RAM(
        .din(rx_data),
        .clk(clk),
        .rst_n(rst_n), 
        .rx_valid(rx_valid),
        .dout(tx_data),
        .tx_valid(tx_valid)
    );
endmodule