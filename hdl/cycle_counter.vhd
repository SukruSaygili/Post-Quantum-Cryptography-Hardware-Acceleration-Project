--------------------------------------------------------------------------------
-- Module Name:     cycle_counter - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Cycle counter peripheral that increments on every clock cycle 
--                  and can be read/written via MMIO.
--
-- Revision     Date         Author     Comments
-- v0.1         20.04.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity cycle_counter is
    port (
        clk     : in  STD_LOGIC;
        rst     : in  STD_LOGIC;

        sel     : in  STD_LOGIC;
        we      : in  STD_LOGIC;
        re      : in  STD_LOGIC;
        addr    : in  STD_LOGIC_VECTOR(3 downto 0);

        rdata   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity cycle_counter;

architecture Behavioral of cycle_counter is

    -- INTERNAL SIGNALS
    signal counter : UNSIGNED(63 downto 0);

begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    running_counter: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                counter <= (others => '0');
    
            elsif sel = '1' and we = '1' and addr = "0000" then
                counter <= (others => '0');
    
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    read_mux: process(counter, addr, sel, re)
    begin
        if sel = '1' and re = '1' then
            case addr is
                when "0000" => rdata <= STD_LOGIC_VECTOR(counter(31 downto 0));
                when "0100" => rdata <= STD_LOGIC_VECTOR(counter(63 downto 32));
                when others => rdata <= (others => '0');
            end case;
        else
            rdata <= (others => '0');
        end if;
    end process;

end architecture Behavioral;