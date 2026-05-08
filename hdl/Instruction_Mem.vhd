--------------------------------------------------------------------------------
-- Module Name:     Data_Mem - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Instruction memory for the RISC-V processor
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author          Comments
-- v0.1         16.09.2024   VlJo-MyKr       Initial version
--------------------------------------------------------------------------------
-- if you like to program your own code, just use following website to translate the instruction
-- https://luplab.gitlab.io/rvcodecjs/ 	 	  
-- this site DOES not work for branching!!	
--	https://venus.cs61c.org/ does work!

---- In this file the instruction are hardcoded
---- During the course it showed that this should be saved into SRAM, but to make it easier we hardcode it here

library ieee;
use ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use ieee.STD_LOGIC_unsigned.all;

entity Instruction_Mem is
    port (
        Address     :in STD_LOGIC_VECTOR(15 downto 0);
        instruction :out STD_LOGIC_VECTOR(31 downto 0) 
    );
end entity Instruction_Mem;

architecture Behavioral of Instruction_Mem is
    
    type ROM_ARRAY is array (0 to 65535) of STD_LOGIC_VECTOR(7 downto 0);      --declaring size of memory. 128 elements of 32 bits
    constant ROM : ROM_ARRAY := (  
        X"00",X"00",X"00",X"93",  --addi x1, x0, 0 #i = 0                                PC 0 
        X"01",X"40",X"02",X"13",  --addi x4, x0, 20 #matrix 1 ==> 20 elements            PC 4 
        X"00",X"F0",X"02",X"93",  --addi x5, x0, 15 #matrix 2 ==> 15 elements            PC 8 
        X"00",X"20",X"0F",X"93",  --addi x31, x0, 2 #shift for word address              PC 12 

        ------ loopm1
        X"01",X"F0",X"91",X"33",  --sll x2, x1, x31 #i --> word address  (no SSLI)       PC 16
        X"00",X"10",X"80",X"93",  --addi x1,x1,1 #i+1                                    PC 20
        X"00",X"11",X"20",X"23",  --sw x1, 0(x2)                                         PC 24
        X"FE",X"12",X"1A",X"E3",  --bne x4, x1, loop_m1                                  PC 28
        X"00",X"00",X"03",X"93",  --addi x7, x0, 0 #j                                    PC 32
        ------ loop m2
        X"01",X"F0",X"91",X"33",  --sll x2, x1, x31 #i --> word address  (no SSLI)       PC 36
        X"40",X"72",X"84",X"33",  --sub x8, x5, x7                                       PC 40      these two lines swapped places because 
        X"00",X"10",X"80",X"93",  --addi x1, x1, 1  #i = i+1                             PC 44      our hardware did not support it (sub ... sw)
        X"00",X"13",X"83",X"93",  --addi x7, x7, 1  #j=j+1                               PC 48
        X"00",X"81",X"20",X"23",  --sw x8, 0(x2)                                         PC 52
        X"FE",X"72",X"96",X"E3",  --bne x5, x7, loop_m2                                  PC 56

        X"00",X"04",X"84",X"93",  --addi x9, x9, 0                                       PC 60
        X"00",X"15",X"05",X"13",  --addi x10, x10, 1                                     PC 64
        X"00",X"00",X"0A",X"13",  --addi x20, x0, 0 #I input address starting point      PC 68
        X"05",X"00",X"0A",X"93",  --addi x21, x0, 80 #W input address starting point     PC 72
        X"08",X"C0",X"0B",X"13",  --addi x22, x0, 0 #O output address starting point     PC 76
        X"00",X"50",X"02",X"13",  --addi x4, x0, 5 C loop size                           PC 80
        X"00",X"30",X"02",X"93",  --addi x5, x0, 3 K loop size                           PC 84
        X"00",X"40",X"05",X"93",  --addi x11, x0, 4 B loop size                          PC 88
        X"00",X"00",X"0B",X"93",  --addi x23, x0, 0 C loop index starts with 0           PC 92
        X"00",X"00",X"0C",X"13",  --addi x24, x0, 0  K loop index starts with 0          PC 96
        X"00",X"00",X"0C",X"93",  --addi x25, x0, 0  B loop index starts with 0          PC 100
        X"00",X"00",X"05",X"13",  --addi x10, x0, 0  #acc result                         PC 104
        X"00",X"10",X"0D",X"93",  --addi x27, x0, 1  ##program start                     PC 108

        ----- START COUNTING CYCLES FROM HERE -----------
        --- INSERT YOUR CODE HERE

        X"FE",X"CA",X"0E",X"13",    --addi x28, x20, -20                                 PC 112
        X"01",X"60",X"0E",X"B3",    --add x29, x0, x22                                   PC 116
        X"01",X"50",X"01",X"33",    --add x2, x0, x21                                    PC 120
        X"01",X"4E",X"0E",X"13",    --addi x28, x28, 20                                  PC 124
        X"00",X"0E",X"23",X"03",    --lw x6, 0(x28)                                      PC 128
        X"00",X"01",X"23",X"83",    --lw x7, 0(x2)                                       PC 132
        X"00",X"4E",X"2F",X"03",    --lw x30, 4(x28)                                     PC 136
        X"02",X"73",X"04",X"33",    --mul x8, x6, x7                                     PC 140
        X"00",X"41",X"2F",X"83",    --lw x31, 4(x2)                                      PC 144
        X"00",X"8E",X"23",X"03",    --lw x6, 8(x28)                                      PC 148
        X"03",X"FF",X"04",X"B3",    --mul x9, x30, x31                                   PC 152
        X"00",X"94",X"05",X"33",    --add x10, x8, x9                                    PC 156
        X"00",X"81",X"23",X"83",    --lw x7, 8(x2)                                       PC 160
        X"00",X"CE",X"2F",X"03",    --lw x30, 12(x28)                                    PC 164
        X"02",X"73",X"04",X"33",    --mul x8, x6, x7                                     PC 168
        X"00",X"85",X"05",X"33",    --add x10, x10, x8                                   PC 172
        X"00",X"C1",X"2F",X"83",    --lw x31, 12(x2)                                     PC 176
        X"01",X"0E",X"23",X"03",    --lw x6, 16(x28)                                     PC 180
        X"03",X"FF",X"04",X"33",    --mul x8, x30, x31                                   PC 184
        X"00",X"85",X"05",X"33",    --add x10, x10, x8                                   PC 188
        X"01",X"01",X"23",X"83",    --lw x7, 16(x2)                                      PC 192
        X"01",X"41",X"01",X"13",    --addi x2, x2, 20                                    PC 196
        X"02",X"73",X"04",X"33",    --mul x8, x6, x7                                     PC 200
        X"00",X"85",X"05",X"33",    --add x10, x10, x8                                   PC 204
        X"00",X"AE",X"A0",X"23",    --sw x10, 0(x29)                                     PC 208
        X"00",X"4E",X"8E",X"93",    --addi x29, x29, 4                                   PC 212
        X"FB",X"61",X"44",X"E3",    --blt x2, x22, loop_inner                            PC 216
        X"00",X"1C",X"8C",X"93",    --addi x25, x25, 1                                   PC 220
        X"F8",X"BC",X"CC",X"E3",    --blt x25, x11, loop_outer                           PC 224

        ----- STOP COUNTING CYCLES -----------
        X"00",X"00",X"0D",X"93",   --addi x27, x0, 0  #indication of program end!        PC 228
		others => X"00"	
    );
begin
    instruction <= ROM(conv_integer(Address)) & ROM(conv_integer(Address + 1)) &
                   ROM(conv_integer(Address + 2)) & ROM(conv_integer(Address + 3)); 
    --instruction <= ROM(conv_integer(Address + 3)) & ROM(conv_integer(Address + 2))
      --           & ROM(conv_integer(Address + 1)) & ROM(conv_integer(Address));
 

end architecture Behavioral;	 