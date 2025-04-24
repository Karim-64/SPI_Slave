vlib work 

vlog SPI_slave.v RAM.v Wrapper.v testbench.v

vsim -voptargs=+acc work.SPI_tb

add wave -position insertpoint  \
sim:/SPI_tb/clk \
sim:/SPI_tb/rst_n \
sim:/SPI_tb/MOSI \
sim:/SPI_tb/SS_n \
sim:/SPI_tb/MISO_dut \
sim:/SPI_tb/dut/tx_data \
sim:/SPI_tb/dut/tx_valid \
sim:/SPI_tb/dut/rx_data \
sim:/SPI_tb/dut/rx_valid 

run -all