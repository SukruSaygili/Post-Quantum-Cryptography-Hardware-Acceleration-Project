--------------------------------------------------------------------------------
-- Module Name:     PC - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Program counter for the RV32IM instruction set
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author          Comments
-- v0.1         16.09.2024   VlJo-MyKr       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PC is
    port (
        PCIn        : in STD_LOGIC_VECTOR(31 downto 0);
        clk         : in STD_LOGIC;
        rst         : in STD_LOGIC;
        PCEnable    : in STD_LOGIC;     -- PCEnable signal to include a hazard detection unit, which can stall the pipeline
        PCOut       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity PC;

architecture Behavioral of PC is

begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process( clk, rst)
    begin
        if rst = '0' then
            PCOut <= (others => '0');
        else
            if rising_edge(clk) then
                if PCEnable = '1' then   
                        PCOut <= PCIn;
                end if;
            end if;
        end if;
    end process;

end architecture Behavioral;