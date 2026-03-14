# PicoRV32 SoC for Sipeed Tang FPGAs

This project implements a RISC-V SoC based on the **PicoRV32** CPU, specifically optimized for the **Sipeed Tang Nano** and **Tang Primer** series. It features a configurable memory architecture and an integrated HDMI text output.

## 🚀 Key Features

* **Processor:** PicoRV32 RISC-V CPU.
* **Boot Memory:** 8KB BSRAM.
* **Memory Expansion:** Up to 64KB BSRAM (configurable in 8KB steps).
* **Clock Management:** 
    * Automatic selection of clock settings and video parameters based on the target hardware.
    * Selectable CPU frequency: **12, 48, or 60 MHz** (depending on hardware capabilities).
* **Video Output:** HDMI Text Mode with 16 colors.
* **Peripherals:**
    * Simple 8-bit GPIO port.
    * Integrated UART (Serial console).
    * Standard Timer.

## 📋 Supported Boards & Resolutions

| Board | CPU Freq (MHz) | 1360x768 @ 50Hz (80x32 char) | 1366x768 @ 60Hz (80x32 char) | 1680x1050 @ 60Hz (96x42 char) |
| :--- | :---: | :---: | :---: | :---: |
| **Tang Nano 9K** | 12, 48 | ✅ | - | - |
| **Tang Nano 20K** | 12, 48 | - | ✅ | - |
| **Tang Primer 20K** | 12, 48, 60 | - | ✅ | ✅ |
| **Tang Primer 25K** | 12, 48, 60 | - | ✅ | ✅ |

## 🎨 HDMI Text Mode Colors

| Index | Color | Index | Color |
| :--- | :--- | :--- | :--- |
| 0 | Black | 8 | Dark Gray |
| 1 | Blue | 9 | Light Blue |
| 2 | Green | 10 | Light Green |
| 3 | Cyan | 11 | Light Cyan |
| 4 | Red | 12 | Light Red |
| 5 | Magenta | 13 | Light Magenta |
| 6 | Brown/Yellow | 14 | Yellow |
| 7 | Light Gray | 15 | White |

---

## 🛠️ How to Build

### Prerequisites
* **Gowin EDA:** For hardware synthesis and place-and-route.
* **RISC-V Toolchain:** To compile C/ASM code (e.g., `riscv64-unknown-elf-gcc`).

### Hardware Synthesis
1. Open the `.gprj` file in **Gowin EDA**.
2. Select your device in `Project -> Configuration`.
3. Check the `.cst` (Constraints) file to ensure it matches your board's pinout.
4. Run the synthesis and place-and-route to generate the bitstream.

### Software Compilation
1. Navigate to the `c_code/` directory.
2. Run the Makefile:
   ```bash
   make clean
   make all
