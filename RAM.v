module spi_sync_ram #(
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8
)(
    input  [9:0] din,
    input  clk,
    input  rst_n, // synchronus active low
    input  rx_valid,
    output reg [7:0] dout,
    output reg tx_valid
);
    reg [7:0] mem [MEM_DEPTH-1:0];
    reg [7:0] addr;
    always @(posedge clk) begin
        if(~rst_n) begin
            dout     <= 0;
            tx_valid <= 0;
        end
        else if(rx_valid) begin
            case (din[9:8])
                2'b00 : addr      <= din[7:0];
                2'b01 : mem[addr] <= din[7:0];
                2'b10 : addr      <= din[7:0];
                2'b11 : begin
                    tx_valid  <= 1;
                    dout      <= mem[addr];
                end
            endcase
        end
        else 
            tx_valid <= 0;
    end
endmodule