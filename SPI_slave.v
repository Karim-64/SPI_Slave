module spi_slave_if #(
    parameter IDLE      = 3'b000,
    parameter CHK_CMD   = 3'b001,
    parameter WRITE     = 3'b010,
    parameter READ_ADD  = 3'b011,
    parameter READ_DATA = 3'b100
) (
    input            MOSI,      // data sent from the master to the slave
    input            SS_n,      // signal by the master to enable the slave
    input            clk,
    input            rst_n,
    input      [7:0] tx_data,   // for data coming from the RAM
    input            tx_valid,  // enable to store the data coming from the RAM
    output reg       MISO,      // data sent from the slave to the master
    output reg [9:0] rx_data,   // for data to be sent to the RAM
    output reg       rx_valid   // enable for the RAM to store the data on rx_data
);
    (* fsm_encoding = "gray" *)
    reg [2:0] cs, ns;   // current state and next state
    reg [3:0] counter;  // counter for serial to parallel data conversion
    reg       rd_addr;  // a signal to know if the address is received or not
    reg [9:0] data_in;  // to store the data coming from RAM

    // next state logic
    always @(*) begin
        case (cs)
            IDLE:    ns = (SS_n) ? IDLE : CHK_CMD;
            CHK_CMD: begin
                if (~SS_n)
                  if (MOSI) ns = (rd_addr) ? READ_DATA : READ_ADD;
                  else ns = WRITE;
                else ns = IDLE;
            end
            WRITE:   ns = (counter == 10 && SS_n == 1) ? IDLE : WRITE;
            READ_ADD: begin
                if (counter == 10 && SS_n == 1) ns = IDLE;
                else ns = READ_ADD;
            end
            READ_DATA: begin
                if (counter == 11 && SS_n == 1) ns = IDLE;
                else ns = READ_DATA;
            end
            default: ns = IDLE;
        endcase
    end

    // current state memory and slave data handling
    always @(posedge clk) begin
        if (~rst_n) begin
            cs      <= IDLE;
            counter <= 3'b0;
            MISO    <= 0;
            rx_data <= 10'b0;
            rd_addr <= 0;
        end 
        else begin
            cs <= ns;
            if (cs == IDLE) counter <= 0;
            // reciving data from the master 
            if (cs == WRITE || cs == READ_ADD) begin
                if (counter != 10) begin
                    data_in[9-counter] <= MOSI;  //converting serial data input
                    counter <= counter + 1;
                end 
                else  // the data is ready to be transfered
                    rx_data <= data_in;
                if (cs == READ_ADD)
                    rd_addr <= 1;  // pull up rd_addr to notify the spi that the address is transfered
            end 
            else if (cs == READ_DATA) begin
                // storing data came from the master
                if (counter < 2) begin  // here we need the first two bits only and the others are dummy
                    data_in[9-counter] <= MOSI;  //serial data input
                    counter <= counter + 1;
                end  
                // saving the data came from the RAM
                else if (tx_valid) begin
                    data_in[7:0] <= tx_data;
                    rd_addr <= 0;
                    counter <= counter + 1;
                end else if (counter == 2)  // transfering the data recieved to rx_data
                    rx_data <= data_in;     // from here tx_valid will be risen to high
                // recieving data from the RAM and sending it to the master
                else if (counter > 2 && counter < 11) begin
                    MISO    <= data_in[10-counter]; // the first value of the counter is 3
                    counter <= counter + 1;
                end
            end
        end
    end

    // output logic
    always @(*) begin
        // the cases when rx_valid is high
        if (((cs == WRITE || cs == READ_ADD) && counter == 10) || (cs == READ_DATA && counter == 2))
            rx_valid = 1;
        else rx_valid = 0;
    end
endmodule
