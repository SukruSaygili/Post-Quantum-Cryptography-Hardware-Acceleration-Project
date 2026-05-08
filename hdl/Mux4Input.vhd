--------------------------------------------------------------------------------
-- Module Name:     Mux4Input - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     4-to-1 Multiplexer
--
-- Revision     Date         Author     Comments
-- v0.2         10.10.2024   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity Mux4Input is
    port (
        muxIn0      :in STD_LOGIC_VECTOR(31 downto 0);
        muxIn1      :in STD_LOGIC_VECTOR(31 downto 0);
        muxIn2      :in STD_LOGIC_VECTOR(31 downto 0);
        muxIn3      :in STD_LOGIC_VECTOR(31 downto 0);
        selector    :in STD_LOGIC_VECTOR(1 downto 0);
        muxOut      :out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity Mux4Input;

architecture Behavioral of Mux4Input is
    -- INTERNAL SIGNALS
    signal selected : STD_LOGIC_VECTOR(31 downto 0);
begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process( muxIn0, muxIn1, muxIn2,muxIn3, selector )
    begin
        case selector is
            when "00" => selected <= muxIn0;
            when "01" => selected <= muxIn1;
            when "10" => selected <= muxIn2;
            when "11" => selected <= muxIn3;

            when others => selected <= muxIn0;              
        end case;
    end process ; 

    muxOut <= selected;
    
end architecture Behavioral;