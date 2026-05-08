--------------------------------------------------------------------------------
-- Module Name:     BR - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Delay register for the IF-stage of the pipeline, which holds 
--                  the PC and PC+4 values for the next stage (ID).
--
-- Revision     Date         Author     Comments
-- v0.1         09.03.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity BRD is
    Port ( 
        clk             : in STD_LOGIC;
        rst             : in STD_LOGIC;
        enable          : in STD_LOGIC;        
        flush           : in STD_LOGIC;        
        PC_BRD_IN       : in STD_LOGIC_VECTOR(31 downto 0);
        PC4_BRD_IN      : in STD_LOGIC_VECTOR(31 downto 0);
        PC_BRD_OUT      : out STD_LOGIC_VECTOR(31 downto 0);
        PC4_BRD_OUT     : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity BRD;

architecture Behavioral of BRD is

    -- (DE-)LOCALISING IN/OUTPUTS
    signal PC_BRD_REG_o        : STD_LOGIC_VECTOR (31 downto 0);
    signal PC4_BRD_REG_o       : STD_LOGIC_VECTOR (31 downto 0);

begin
    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    PC_BRD_OUT  <= PC_BRD_REG_o;
    PC4_BRD_OUT <= PC4_BRD_REG_o;

    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                -- Reset the registers
                PC_BRD_REG_o        <= (others => '0');
                PC4_BRD_REG_o       <= (others => '0');

            elsif enable = '1' then
                if flush = '0' then
                    PC_BRD_REG_o  <= (others => '0');
                    PC4_BRD_REG_o <= (others => '0');
                else
                    PC_BRD_REG_o  <= PC_BRD_IN; 
                    PC4_BRD_REG_o <= PC4_BRD_IN; 
                end if;
            end if;
        end if;    
    end process;
    
end architecture Behavioral;