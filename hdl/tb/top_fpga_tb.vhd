--------------------------------------------------------------------------------
-- Module Name:     top_fpga_tb - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Testbench for the top_fpga
--
-- Revision     Date         Author    Comments
-- v0.1         06.03.2026   SaSu      Initial version
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_fpga_tb is
end;

architecture sim of top_fpga_tb is
    component top_fpga is
        Port ( 
            sys_clock : in STD_LOGIC;
            sys_reset : in STD_LOGIC;
            uart_rx   : in STD_LOGIC;
            uart_tx   : out STD_LOGIC;
            leds      : out STD_LOGIC_VECTOR (3 downto 0)
            --cycle_count : out STD_LOGIC_VECTOR(31 downto 0)
            );
    end component top_fpga;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal leds : std_logic_vector(3 downto 0);
    signal cycle_count : std_logic_vector(31 downto 0);

    signal uart_tx_o, uart_rx_i : STD_LOGIC := '0';

    constant clk_period : time := 8 ns;

begin
    --uart_tx_o <= '1';
    dut : component top_fpga
        port map(
            sys_clock => clk,
            sys_reset => rst,
            uart_rx => uart_tx_o,
            uart_tx => uart_rx_i,
            leds => leds
            --cycle_count => cycle_count
        );

    -- clock
    process
    begin
        clk <= not clk;
        wait for clk_period/2;
    end process;

    -- reset
    process
    begin
        rst <= '1';
        wait for clk_period * 10;
        rst <= '0';
        wait;
    end process;

end architecture;