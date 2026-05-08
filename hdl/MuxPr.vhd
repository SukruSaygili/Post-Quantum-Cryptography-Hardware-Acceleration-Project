--------------------------------------------------------------------------------
-- Module Name:     MuxPr - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Custom 2-to-1 Multiplexer
--
-- Revision     Date         Author     Comments
-- v0.2         10.10.2024   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity MuxPr is
    port (
        muxIn0      :in STD_LOGIC_VECTOR(31 downto 0);
        muxIn1      :in STD_LOGIC_VECTOR(31 downto 0);
        selector    :in STD_LOGIC_VECTOR(2 downto 0);
        muxOut      :out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity MuxPr;

architecture Behavioral of MuxPr is
    -- INTERNAL SIGNALS
    signal selected : STD_LOGIC_VECTOR(31 downto 0);
begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process( muxIn0, muxIn1, selector )
    begin
        case selector is
            when "110" => selected <= muxIn0;
            when "111" => selected <= muxIn1;
            when others => selected <= muxIn0;              
        end case;
    end process ;

    muxOut <= selected;
    
end architecture Behavioral;