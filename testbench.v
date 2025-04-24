module SPI_tb();
    reg  MOSI;
    reg  SS_n;
    reg  clk;
    reg  rst_n;
    wire MISO_dut;
    reg  [7:0] temp_word;
    integer i;
    // dut instantiation 
    SPI_slave_top_module dut (
        .MOSI(MOSI),
        .SS_n(SS_n),
        .clk(clk),
        .rst_n(rst_n),
        .MISO(MISO_dut)
    );

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end
    // test generator
    initial begin
        rst_n = 0;
        @(negedge clk);
        repeat(10)begin
            MOSI = $random;
            SS_n = $random;
            @(negedge clk);
        end
        rst_n = 1;
        SS_n  = 0;        
        @(negedge clk); // to enter chk_cmd state
        MOSI = 0;       
        @(negedge clk); // to enter write state
        repeat(2) @(negedge clk); // din[9:8] are 2'b00 to tell the RAM the address
        repeat(8) begin // the address is the the highest address to be easy to see
            MOSI = 1;
            @(negedge clk);
        end
        @(negedge clk); // till the data is transfered to the rx_data
        SS_n = 1;
        @(negedge clk); // return to the idle state
        SS_n = 0;
        @(negedge clk); // chk_cmd state
        MOSI = 0;
        @(negedge clk); // write state 
        MOSI = 0;
        @(negedge clk);
        MOSI = 1;
        @(negedge clk); // to tell the RAM the mode (write data)
        repeat(8) begin
            MOSI = $random;
            @(negedge clk);
        end
        @(negedge clk);
        SS_n = 1;
        @(negedge clk); // return to IDLE mode
        SS_n = 0;
        @(negedge clk); // enter chk_cmd
        MOSI = 1;
        @(negedge clk); // enter read_add
        MOSI = 1;
        @(negedge clk);
        MOSI = 0;
        @(negedge clk); // send to the RAM to store the address
        repeat(8) begin
            MOSI = 1;
            @(negedge clk);
        end
        @(negedge clk);
        SS_n = 1;
        @(negedge clk); // return to the IDLE state
        SS_n = 0;
        @(negedge clk); // enter chk_cmd
        MOSI = 1;
        @(negedge clk); // enter read_data 
        repeat(2) @(negedge clk); // to tell the ram to write the data to the previous address
        @(negedge clk); // the data is on tx_data
        @(negedge clk); // the data converted to data_in
        @(negedge clk); // MISO will take the values at the next rising edge
        repeat(8) @(negedge clk); 
        SS_n = 1; //
        @(negedge clk); // return to the IDLE
        $stop;
    end
endmodule