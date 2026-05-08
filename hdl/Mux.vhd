--------------------------------------------------------------------------------
-- Module Name:     Mux - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Multiplexer
--
-- Revision     Date         Author     Comments
-- v0.2         10.10.2024   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity Mux is
    port (
        muxIn0      :in STD_LOGIC_VECTOR(31 downto 0);
        muxIn1      :in STD_LOGIC_VECTOR(31 downto 0);
        selector    :in STD_LOGIC;
        muxOut      :out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity Mux;

architecture Behavioral of Mux is
    -- INTERNALS SIGNALS
    signal selected : STD_LOGIC_VECTOR(31 downto 0);
begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process( muxIn0, muxIn1, selector )
    begin
        case selector is
            when '0' => selected <= muxIn0;
            when '1' => selected <= muxIn1;
            when others => selected <= muxIn0;              
        end case;
    end process ; -- 

    muxOut <= selected;
    
end architecture Behavioral;