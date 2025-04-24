# SPI Slave with Single-Port RAM

## Overview

This project implements a fully-functional SPI (Serial Peripheral Interface) **slave** peripheral connected to a single-port synchronous RAM. It has been designed, linted, simulated, and verified on a Basys3 FPGA board. Key deliverables and features include:

- **SPI slave peripheral** with FSM and configurable encoding (Gray, one-hot, binary).
- **10-bit serial protocol** with a 2-bit command and 8-bit data/address.
- **Single-port synchronous RAM** for storage.
- **Modular Verilog design** including `SPI_slave`, `RAM`, and a top-level `Wrapper`.
- **Testbench and QuestaSim simulation** with waveform generation.
- **Linting with Questa Lint** to ensure code quality and standard compliance.
- **Vivado implementation** with Basys3 constraints and bitstream generation.

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
├─ Karim_Mohamed_Project2.pdf    # Design documentation
└─ … (lint reports, logs, etc.)
```

## Module Descriptions

### 1. `spi_slave_if` (SPI_slave.v)

Implements the SPI slave interface and protocol parsing:

- **Ports**:
  - `MOSI`, `MISO`, `SS_n`, `clk`, `rst_n`
  - `rx_data[9:0]` (command + data)
  - `rx_valid`, `tx_data[7:0]`, `tx_valid`
- **FSM with Configurable Encoding**:
  - FSM is annotated with `(* fsm_encoding = "gray" *)` but can be toggled to binary or one-hot by modifying the encoding attribute.
- **States**:
  - `IDLE`, `CHK_CMD`, `WRITE`, `READ_ADD`, `READ_DATA`
- **Serial to Parallel Conversion**:
  - Internal counter collects 10 bits from MOSI.
  - MISO sends data bit-by-bit during read operations.

### 2. `spi_sync_ram` (RAM.v)

Simple synchronous single-port RAM:

- **Parameters**:
  - `MEM_DEPTH = 256`, `ADDR_SIZE = 8`
- **Command Decoding**:
  - `00`: Set read address
  - `01`: Write data to current address
  - `10`: (Not used)
  - `11`: Trigger read from RAM
- **Data Flow**:
  - `din[9:0]` carries address or data + command bits
  - `rx_valid` triggers RAM write/read actions
  - `dout` with `tx_valid` returns data to SPI

### 3. `SPI_slave_top_module` (Wrapper.v)

Top-level module instantiating the SPI interface and RAM:

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

### QuestaSim Simulation:

- **Testbench** `testbench.v` verifies:
  - Reset behavior and robustness
  - Writing to address `0xFF`
  - Random data write
  - Reading back from same address
- **Script** `run.do` automates compilation and simulation:

```tcl
vlib work
vlog SPI_slave.v RAM.v Wrapper.v testbench.v
vsim -voptargs=+acc work.SPI_tb
add wave -position insertpoint \
  sim:/SPI_tb/clk sim:/SPI_tb/rst_n sim:/SPI_tb/MOSI sim:/SPI_tb/MISO \
  sim:/SPI_tb/SS_n sim:/SPI_tb/rx_data sim:/SPI_tb/tx_data sim:/SPI_tb/rx_valid
run -all
```

### Linting:

- **Questa Lint** was used to:
  - Check for syntax/style issues
  - Validate FSM structure and encoding
  - Confirm design consistency and best practices

## FPGA Implementation

1. **Vivado Project**: Open `final_project/final_project.xpr`
2. **Constraints File**: `Constraints_basys3_SPI.xdc`:
   - Clock: W5 @ 100 MHz
   - Reset: V17
   - SPI: SS_n (V16), MOSI (W16)
3. **Bitstream Generation**:
   - Run synthesis → implementation → bitstream generation
   - Final `.bit` available in `final_project/final_project.runs/impl_1/`
4. **Programming**:
   - Use Vivado Hardware Manager to flash the Basys3

## Notes on Requirements Fulfillment

All requirements from the project specifications (as outlined in *Karim_Mohamed_Project2.pdf*) have been completed:

- [x] Top-level Wrapper
- [x] SPI Interface Module with FSM (Gray encoding used)
- [x] RAM Module
- [x] Configurable FSM Encoding
- [x] Simulation with Testbench
- [x] Questa Lint Check
- [x] Constraint File for Basys3
- [x] Bitstream Generation

## How to Use

- **Simulate**:
  ```bash
  vsim -do run.do
  ```
- **Flash FPGA**:
  1. Open Vivado
  2. Connect Basys3 via USB
  3. Program with generated bitstream
- **Verify Operation**:
  - Connect an SPI master (e.g., STM32 or Arduino)
  - Drive `MOSI`, `SS_n`, and `clk` lines according to SPI protocol

## Documentation

See `Karim_Mohamed_Project2.pdf` for design diagrams, timing charts, FSM state transitions, simulation snapshots, and project rationale.

---

*Authored by Karim Mohamed*

