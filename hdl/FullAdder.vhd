--------------------------------------------------------------------------------
-- Module Name:     FullAdder - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Full adder, used in the ALU for addition and subtraction operations.
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author          Comments
-- v0.1         16.09.2024   VlJo-MyKr       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity FullAdder is
 Port ( 
    X : in STD_LOGIC;
    Y : in STD_LOGIC;
    Ci : in STD_LOGIC;
    Sum : out STD_LOGIC;
    Co : out STD_LOGIC
 );
end FullAdder;

architecture Behavioral of FullAdder is

begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    Sum <= X XOR Y XOR Ci ;
    Co <= (X AND Y) OR (Ci AND X) OR (Ci AND Y) ;

end architecture Behavioral;