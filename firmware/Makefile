# Makefile
# Default target
TARGET ?= embedded

RM = rm -rf
MKDIR = mkdir

INCLUDES = -I$(SOURCEDIR) \
           -I$(SOURCEDIR)/hqc_1_128 \
           -I$(SOURCEDIR)/hqc_3_192 \
           -I$(SOURCEDIR)/hqc_5_256 \
           -I$(SOURCEDIR)/common

BUILDDIR = build
SOURCEDIR = src
HEADERDIR = src
TOOLS = ../scripts/python
HDLDIR = ../hdl

SOURCES = $(wildcard $(SOURCEDIR)/*.c) \
          $(wildcard $(SOURCEDIR)/common/*.c) \
          $(wildcard $(SOURCEDIR)/hqc_1_128/*.c) \
          $(wildcard $(SOURCEDIR)/hqc_3_192/*.c) \
          $(wildcard $(SOURCEDIR)/hqc_5_256/*.c)

SOURCES_A = $(wildcard $(SOURCEDIR)/*.S)

ifeq ($(TARGET),pc)

    CC = gcc
	CFLAGS = -c -O2 -Wall -std=c99 -DPC_TEST $(INCLUDES)
    SFLAGS =
    LDFLAGS =
    LIBS =
    BINARY = firmware_pc

    # GEEN assembly files op PC
    OBJECTS = $(patsubst $(SOURCEDIR)/%.c, $(BUILDDIR)/pc_%.o, $(SOURCES))
    OBJECTS_A =

else
    TOOLCHAIN_PREFIX = /home/sukru/riscv32/bin/riscv32-unknown-elf-
    PYTHON = /usr/bin/python3

    ARCHITECTURE = rv32im
    ABI = ilp32
    IMEM_SIZE_32BIT_WORDS = 16384
    DMEM_SIZE_32BIT_WORDS = 65536

    CC = $(TOOLCHAIN_PREFIX)gcc
    CFLAGS = -c -Os -march=$(ARCHITECTURE) -mabi=$(ABI) -ffreestanding --std=c99 $(INCLUDES)
    SFLAGS = -c -Os -march=$(ARCHITECTURE) -mabi=$(ABI) -ffreestanding --std=c99 $(INCLUDES)
    LDFLAGS = -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -march=$(ARCHITECTURE) -mabi=$(ABI) -nostartfiles
    LIBS =
    BINARY = firmware.elf

    OBJECTS = $(patsubst $(SOURCEDIR)/%.c, $(BUILDDIR)/%.o, $(SOURCES))
    OBJECTS_A = $(patsubst $(SOURCEDIR)/%.S, $(BUILDDIR)/%.o, $(SOURCES_A))

endif

.PHONY: all clean sizes

################################################################################

ifeq ($(TARGET),pc)

all: $(BINARY)

else

all: firmware.objdump firmware_imem.coe firmware_dmem.coe firmware_imem.hex firmware_dmem.hex

endif

################################################################################
%.objdump: %.elf
	$(TOOLCHAIN_PREFIX)objdump -D -M no-aliases $< > $@

# Make binary
# %.bin: %.elf
#	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

# Make hex
firmware_imem.hex: firmware_imem.bin
	$(PYTHON) $(TOOLS)/makehex.py $< $@ $(IMEM_SIZE_32BIT_WORDS)

firmware_dmem.hex: firmware_dmem.bin
	$(PYTHON) $(TOOLS)/makehex.py $< $@ $(DMEM_SIZE_32BIT_WORDS)

# Extract .text en .init sections out of ELF for IMEM
firmware_imem.bin: $(BINARY)
	$(TOOLCHAIN_PREFIX)objcopy -j .init -j .text -O binary $< $@

# Extract e .data en .rodata sections out of ELF for DMEM
firmware_dmem.bin: $(BINARY)
	$(TOOLCHAIN_PREFIX)objcopy -j .data -j .rodata -O binary $< $@

# Generate coe-files for Vivado
firmware_imem.coe: firmware_imem.bin
	$(PYTHON) $(TOOLS)/makecoe.py $< $@ $(IMEM_SIZE_32BIT_WORDS)

firmware_dmem.coe: firmware_dmem.bin
	$(PYTHON) $(TOOLS)/makecoe.py $< $@ $(DMEM_SIZE_32BIT_WORDS)

# LINKING ######################################################################
$(BINARY): $(OBJECTS) $(OBJECTS_A)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

# COMPILING ####################################################################
$(BUILDDIR)/pc_%.o: $(SOURCEDIR)/%.c
	@$(MKDIR) -p $(dir $@)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c
	@$(MKDIR) -p $(dir $@)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.S
	@$(MKDIR) -p $(dir $@)
	$(CC) $(SFLAGS) -o $@ $<

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c
	@$(MKDIR) -p $(dir $@)
	$(CC) $(CFLAGS) -o $@ $<

################################################################################

sizes: firmware.elf
	$(TOOLCHAIN_PREFIX)size $^

clean:
	$(RM) firmware*.elf firmware*.bin firmware*.hex firmware*.map firmware*.objdump 
	$(RM) firmware_imem*.coe firmware_dmem*.coe firmware_pc
	$(RM) -f simulation_output.txt
	$(RM) $(BUILDDIR)
	$(RM) $(BINARY)