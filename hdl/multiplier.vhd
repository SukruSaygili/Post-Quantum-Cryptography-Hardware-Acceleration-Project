--------------------------------------------------------------------------------
-- Module Name:     multiplier - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Combinational tree multiplier for the RV32IM instruction set
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author               Comments
-- v0.1         16.09.2024   VlJo-MyKr-SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use ieee.STD_LOGIC_UNSIGNED.ALL;  

--Not currently used for any instructions. Multiplication takes place inside the ALU.

entity multiplier is
    generic(size: INTEGER := 32);
    port (
        operator1   : in STD_LOGIC_VECTOR(size-1 downto 0);
        operator2   : in STD_LOGIC_VECTOR(size-1 downto 0);
        product     : out STD_LOGIC_VECTOR(2*size-1 downto 0)
    );
end entity multiplier;	 

architecture Behavioral of multiplier is

    -- INTERNALS SIGNALS
    type Tr is array (size-1 downto 0) of STD_LOGIC_VECTOR(size downto 0);
    signal PProduct, S, C : Tr;
    
    -------------------------------------------------------------------------------
    -- COMPONENTS MAPPING
    -------------------------------------------------------------------------------
    component FullAdder
        Port ( 
            X : in STD_LOGIC;
            Y : in STD_LOGIC;
            Ci : in STD_LOGIC;
            Sum : out STD_LOGIC;
            Co : out STD_LOGIC
        );
    end component;

begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    S(0)(size) <= '0';
    row_0: for i in size-1 downto 0 generate
        S(0)(i) <= operator1(i) and operator2(0);
    end generate row_0;

    row_j : for j in 1 to size-1 generate
        S(j)(size) <= C(j)(size);
        col_i : for i in size-1 downto 0 generate
            PProduct(j)(i) <= operator1(i) and operator2(j);
            FullAdd: FullAdder port map (X => S(j-1)(i+1), Y => PProduct(j)(i), Ci => C(j)(i), Sum => S(j)(i), Co => C(j)(i+1));
        end generate ; -- col_i
        C(j)(0) <= '0';
        product(j) <= S(j)(0);
    end generate ; -- row_j

    product(2*size-1 downto size) <= S(size -1)(size downto 1);
    product(0) <= S(0)(0);
    
end architecture Behavioral;