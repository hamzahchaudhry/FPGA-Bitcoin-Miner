# FPGA Bitcoin Miner on DE1-SoC

This project is an **educational exploration** into Bitcoin mining on FPGA technology using the DE1-SoC board. It demonstrates how FPGA-based mining cores can be integrated with external data communication interfaces and evolving SoC designs.

## Overview

The primary goal of this project is to provide a hands-on educational platform for understanding the inner workings of Bitcoin mining on FPGAs. Key components include:

- **FPGA Mining Core:** An experimental mining core implemented on the DE1-SoC board.
- **UART Communication (WIP):** Designed to receive Bitcoin header data from a laptop. *Note: This interface is still under development and may change as the project evolves.*
- **SoC Option in Progress:** Efforts are underway to integrate a Linux-based system with Ethernet capabilities, aiming to create a fully independent Bitcoin mining solution.

## Educational Objectives

- **Understanding FPGA Implementation:** Learn how to design and implement parallel processing logic for Bitcoin mining.
- **Communication Interfaces:** Explore how UART can be used to interface with external devices (in this case, to receive Bitcoin header data).
- **SoC Integration:** Get introduced to building a self-contained SoC that leverages Linux and Ethernet for more autonomous operation.

## Features

- **FPGA-Accelerated Mining Core:** Implements the core Bitcoin mining algorithm.
- **UART for Data Ingestion:** Intended to receive Bitcoin header data from an external laptop, making the setup dynamic.
- **SoC-Based Independent Mining (Work in Progress):** A Linux/Ethernet-based option is being developed to enable the DE1-SoC to mine Bitcoin independently without external control.

## Requirements

- **Hardware:** DE1-SoC Development Board
- **Software:**
  - FPGA design tools (e.g., Quartus Prime)
  - HDL simulation tools (e.g., ModelSim or equivalent)
  - Linux environment for SoC development (for future implementation)
  - UART communication tools for debugging and testing

## Getting Started

### Hardware Setup

1. **Board Preparation:** Set up and power your DE1-SoC board.
2. **Connection:** Attach any required peripherals for programming, debugging, and UART communication.

### Software Setup

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/FPGA-Bitcoin-Miner.git
   cd FPGA-Bitcoin-Miner
   ```

2. **FPGA Compilation:**
   - Open the project in your FPGA design tool (e.g., Quartus Prime).
   - Follow the provided instructions to compile the design.
   - Program your DE1-SoC board with the generated bitstream.

3. **Simulation (Optional):**
   - Use an HDL simulator to run testbenches and verify the functionality of the mining core.

## Usage

After programming your DE1-SoC board:

- **Mining Core:** The mining logic will begin operating on the FPGA.
- **UART Communication:** Intended for receiving Bitcoin header data from your laptop. (Work in progress.)
- **SoC-Based Mining:** Future development will enable the DE1-SoC to run Linux with Ethernet support for fully independent mining.

## Current Status and Future Work

- **Educational FPGA Mining Core:** Fully implemented as an educational prototype.
- **UART Communication:** Currently under development to support dynamic Bitcoin header data input.
- **SoC Independent Mining:** Work is ongoing to integrate a Linux-based system with Ethernet for autonomous mining.
- **Further Documentation:** More detailed guides and performance metrics will be added as the project evolves.

## License

This project is for educational purposes and is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
