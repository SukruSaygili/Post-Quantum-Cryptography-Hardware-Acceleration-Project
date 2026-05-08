################################################################################
# Module Name:     portMaping.xdc
# Project Name:    Hardware-software co-design of HQC-KEM for all security 
#                  levels using an application-specific RISC-V processor 
#                  (Master's thesis)
# Description:     Constraint file for PYNQ-Z2 FPGA board
#
# Revision     Date         Author     Comments
# v0.1         05.03.2026   SaSu       Initial version
################################################################################

# Clock signal 125 MHz
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports sys_clock]
#create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sys_clock }];

# LEDs
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {leds[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {leds[1]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {leds[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {leds[3]}]

# Buttons
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports sys_reset]

set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports uart_tx]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports uart_rx]

# Allow combinatorial loops inside the neoTRNG instance
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *neoTRNG_inst*/*}]