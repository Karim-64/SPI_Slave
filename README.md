# SPI Slave with Single-Port RAM

## Overview

This project implements a fully-functional SPI (Serial Peripheral Interface) **slave** peripheral connected to a single-port synchronous RAM. It has been designed and verified on a Basys3 FPGA board. Key features include:

- **SPI protocol handling** via a finite state machine (FSM) with configurable encoding (Gray, one-hot, binary).
- **10-bit command/data interface**: 2-bit command (read/write/address) + 8-bit payload.
- **Synchronous single-port RAM** for data storage and retrieval.
- **Top-level wrapper** integrating the SPI interface and RAM.
- **Testbench** (`testbench.v`) and QuestaSim script (`run.do`) for functional verification.
- **Vivado project** (`final_project/`) with constraints (`Constraints_basys3_SPI.xdc`) for Basys3 implementation.

## Repository Structure

```
Project_2/
│
├─ Constraints_basys3_SPI.xdc    # Pin assignments & clock definition for Basys3
├─ RAM.v                         # Synchronous single-port RAM module
├─ SPI_slave.v                   # SPI slave FSM & serial‑parallel converter
├─ Wrapper.v                     # Top-level module connecting SPI and RAM
├─ testbench.v                   # Verilog testbench for functional simulation
├─ run.do                        # QuestaSim simulation script
├─ final_project/                # Vivado project directory (bitstream & logs)
├─ Karim_Mohamed_Project2.pdf    # Detailed documentation (block diagrams & timing)
└─ … (log, lint, and intermediate build artifacts)
```

## Module Descriptions

### 1. `spi_slave_if` (SPI_slave.v)

Implements the SPI slave interface:

- **Ports**:
  - `MOSI`, `MISO`, `SS_n`, `clk`, `rst_n`
  - `rx_data[9:0]` (2-bit command + 8-bit data/address)
  - `rx_valid`, `tx_data[7:0]`, `tx_valid` handshake signals to RAM
- **FSM States**:
  - `IDLE`: Wait for chip‑select (`SS_n` low)
  - `CHK_CMD`: Sample the first bit of MOSI to decide read/write sequence
  - `WRITE`: Receive command+data to write or set address
  - `READ_ADD`: Receive address for read operation
  - `READ_DATA`: Transmit data from RAM back to master
- **Counter** for serial-to-parallel conversion (10 bits) and vice-versa.
- **`(* fsm_encoding = "gray" *)`** attribute configurable to other encodings.

### 2. `spi_sync_ram` (RAM.v)

A parameterized synchronous single-port RAM:

- **Parameters**:
  - `MEM_DEPTH` (default 256 words)
  - `ADDR_SIZE` (default 8 bits)
- **Ports**:
  - `din[9:0]`: Combined command & data/address bus from SPI
  - `rx_valid`: Load command/data on rising edge
  - `dout[7:0]`: Data output to SPI master
  - `tx_valid`: Indicates valid `dout` data
- **Operation** (`din[9:8]` command bits):
  - `2'b00`: Update read address (`addr <= din[7:0]`)
  - `2'b01`: Write data into memory (`mem[addr] <= din[7:0]`)
  - `2'b10`: (Alternate address update)
  - `2'b11`: Read memory at `addr` and assert `tx_valid` along with `dout`

### 3. Top-Level `SPI_slave_top_module` (Wrapper.v)

Instantiates and interconnects the SPI interface and RAM:

```verilog
spi_slave_if SPI_Slave(
  .MOSI(MOSI), .SS_n(SS_n), .clk(clk), .rst_n(rst_n),
  .tx_data(tx_data), .tx_valid(tx_valid), .MISO(MISO),
  .rx_data(rx_data), .rx_valid(rx_valid)
);
spi_sync_ram RAM(
  .din(rx_data), .clk(clk), .rst_n(rst_n), .rx_valid(rx_valid),
  .dout(tx_data), .tx_valid(tx_valid)
);
```

## Functional Verification

- **Testbench**: `testbench.v` exercises the SPI sequence:

  1. Reset and random toggles on `MOSI`/`SS_n` for robustness.
  2. Write high address (`0xFF`) to RAM.
  3. Write random data to address.
  4. Read back the written data and verify on `MISO`.

- **Simulation Script**: `run.do` for QuestaSim:

  ```tcl
  vlib work
  vlog SPI_slave.v RAM.v Wrapper.v testbench.v
  vsim -voptargs=+acc work.SPI_tb
  add wave -position insertpoint \
    sim:/SPI_tb/clk sim:/SPI_tb/rst_n ... sim:/SPI_tb/rx_valid
  run -all
  ```

## FPGA Implementation

1. **Open Vivado project**: `final_project/final_project.xpr`.
2. **Constraints**: `Constraints_basys3_SPI.xdc` maps ports to Basys3 pins:
   - `clk` → W5 (LVCMOS33, 100 MHz)
   - `rst_n` → V17
   - `SS_n` → V16
   - `MOSI` → W16
   - (Uncomment additional switch bindings as needed)
3. **Run**:
   - Synthesis
   - Implementation
   - Generate Bitstream (`.bit`) in `final_project/final_project.runs/impl_1/`
4. **Programming**: Download to Basys3 via USB-JTAG.

## Usage

- **Run Simulation**:
  ```bash
  vsim -do run.do
  ```
- **Program FPGA**:
  1. Open Vivado.
  2. Load bitstream (`.bit`).
  3. Use external SPI master (e.g., microcontroller) to drive `MOSI`, `SS_n`, `clk`.

## Further Reading

Detailed design notes, timing diagrams, and block-level architecture are documented in **Karim_Mohamed_Project2.pdf**.

---

*Authored by Karim Mohamed*

