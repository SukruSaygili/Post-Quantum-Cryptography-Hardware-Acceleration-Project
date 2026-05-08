# Hardware-software co-design of HQC-KEM for all security levels using an application-specific RISC-V processor

Implementation of the HQC post-quantum cryptographic scheme for a custom RISC-V platform with optional hardware acceleration for finite field and polynomial multiplication operations.

This repository contains:

* C implementation of HQC parameter sets
* Hardware acceleration hooks for custom instructions/peripherals
* VHDL hardware modules
* Build system for both embedded RISC-V targets and PC-based testing
* Memory image generation for FPGA/SoC integration

---

# Features

* Supports multiple HQC security levels:

  * HQC-128
  * HQC-192
  * HQC-256
* Optional hardware acceleration:

  * Base multiplication accelerator
  * Galois Field accelerator
* Embedded RISC-V firmware generation
* PC test mode for debugging and validation
* Stack usage measurement utilities
* Deterministic or random seed initialization
* Automatic generation of:

  * `.hex`
  * `.coe`
  * `.objdump`
  * `.bin`
  * `.elf`

---

# Repository Structure

```text
├── doc/
│   └── README.md
│
├── firmware/
│   ├── src/
│   │   ├── common/
│   │   ├── hqc_1_128/
│   │   ├── hqc_3_192/
│   │   ├── hqc_5_256/
│   │   ├── *.h
│   │   ├── *.c
│   │   └── *.S
│   │
│   ├── build/
│   │   └── Generated object files when make is executed
│   │
│   ├── firmware.lds
│   │
│   └── Makefile
│   
├── hdl/
│   ├── constrs/
│   ├── ip/
│   ├── tb/
│   └── *.vhd
│
├── scripts/
│   └── python/
│       ├── makehex.py
│       └── makecoe.py
│
└── LICENSE
```

---

# Requirements

## Embedded Build

Required tools:

* RISC-V GCC toolchain
* Python 3
* GNU Make

Example tested toolchain:

```bash
riscv32-unknown-elf-gcc
```

## PC Test Build

Required tools:

* GCC
* GNU Make

---

# Configuration

The main configuration file is:

```text
config_helpers.h
```

Users can enable or disable features depending on their setup.

---

## Hardware Accelerators

Enable hardware acceleration:

```c
#define USE_BASE_MUL_ACCEL
#define USE_GF_ACCEL
```

These macros replace selected PQClean software routines with hardware-accelerated versions.

Disable them if:

* the hardware blocks are not present
* running purely in software
* debugging the reference implementation

---

## Deterministic Testing

Enable deterministic seed generation:

```c
#define DETERMINISTIC
```

Useful for:

* reproducible benchmarks
* debugging
* verification against known-answer tests

Disable for random seed initialization.

---

## PC Test Mode

`PC_TEST` is automatically defined by the Makefile when building for PC:

```bash
make TARGET=pc
```

This mode:

* disables hardware accelerators
* replaces linker symbols with fake stack regions
* enables desktop debugging utilities

Do **not** manually define `PC_TEST` inside the header file.

---

# Build Instructions

## Embedded RISC-V Build

Default build:

```bash
make
```

Generated files:

| File                | Description                |
| ------------------- | -------------------------- |
| `firmware.elf`      | ELF executable             |
| `firmware.objdump`  | Full disassembly           |
| `firmware_imem.hex` | Instruction memory image   |
| `firmware_dmem.hex` | Data memory image          |
| `firmware_imem.bin` | Instruction memory binary  |
| `firmware_dmem.bin` | Data memory binary         |
| `firmware_imem.coe` | Vivado IMEM initialization |
| `firmware_dmem.coe` | Vivado DMEM initialization |

---

## PC Test Build

Build desktop test executable:

```bash
make TARGET=pc
```

Generated executable:

```text
firmware_pc
```

Run:

```bash
./firmware_pc
```

---

# Important Makefile Settings

The following paths may need to be adapted for your system.

## RISC-V Toolchain

```makefile
TOOLCHAIN_PREFIX = /home/sukru/riscv32/bin/riscv32-unknown-elf-
```

Change this to your local installation path.

Example:

```makefile
TOOLCHAIN_PREFIX = /opt/riscv/bin/riscv32-unknown-elf-
```

---

## Python Interpreter

```makefile
PYTHON = /usr/bin/python3
```

Adjust if Python is installed elsewhere.

---

## HDL Directory

```makefile
HDLDIR = ../hdl
```

Modify if the VHDL folder is located somewhere else.

---

## Python Tool Scripts

```makefile
TOOLS = ../scripts/python
```

Contains:

* `makehex.py`
* `makecoe.py`

Used for memory initialization file generation.

---

# Memory Configuration

Instruction and data memory sizes are configurable in the Makefile:

```makefile
IMEM_SIZE_32BIT_WORDS = 16384
DMEM_SIZE_32BIT_WORDS = 65536
```

Adapt these values to your FPGA or SoC memory configuration.

---

# Stack Usage Measurement

The project includes utilities for stack profiling:

```c
void stack_paint(void);
size_t get_stack_usage_bytes(void);
```

These functions can be used to:

* estimate runtime stack consumption
* optimize embedded memory usage
* validate linker memory layouts

---

# Cleaning Build Files

Remove generated files:

```bash
make clean
```

---

# Vivado / FPGA Integration

The generated `.coe` files can directly initialize Block RAMs inside Vivado.

Typical flow:

1. Build firmware
2. Generate `.coe`
3. Attach `.coe` to Block Memory Generator IP
4. Synthesize FPGA design
5. Run simulation or deploy to hardware

---

# Notes

* Assembly files (`*.S`) are only compiled for embedded targets.
* PC builds intentionally exclude hardware-specific assembly.
* Hardware accelerators must match the software interface expected by the firmware.
* Linker symbols:

  * `__bss_end`
  * `__stack_top`

  must exist in the linker script for embedded builds.

---

# Example Commands

```bash
# Embedded build
make

# PC test build
make TARGET=pc

# Clean project
make clean

# Show firmware size
make sizes
```

---

# License

Add your preferred license here.

Example:

```text
MIT License
```

or

```text

Apache 2.0
```

---

# Authors
SaSu
Electronics and ICT Engineering Technology
Master's thesis — UHasselt/KU Leuven