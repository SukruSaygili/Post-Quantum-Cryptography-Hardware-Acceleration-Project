--------------------------------------------------------------------------------
-- Module Name:     uart_peripheral - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Wrapper module for the UART module obtained from, 
--                  “UART (VHDL) - Semiconductor / Logic Design - DigiKey TechForum 
--                  - An Electronic Component and Engineering Solution Forum”. 
--                  Accessed: 16 april 2026. [Online]. Available: 
--                  https://forum.digikey.com/t/uart-vhdl/12670,
--                  which provides a MMIO interface to the CPU.
--
-- Revision     Date         Author     Comments
-- v0.1         19.03.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    
entity uart_peripheral is
    port (clk     : in  STD_LOGIC;
            rst     : in  STD_LOGIC;
            addr    : in  STD_LOGIC_VECTOR(31 downto 0);
            wdata   : in  STD_LOGIC_VECTOR(31 downto 0);
            rdata   : out STD_LOGIC_VECTOR(31 downto 0);
            we      : in  STD_LOGIC;
            re      : in  STD_LOGIC;
            sel     : in  STD_LOGIC;
            busy    : out STD_LOGIC;
            uart_rx : in  STD_LOGIC;
            uart_tx : out STD_LOGIC
    );
end entity uart_peripheral;

architecture Behavioral of uart_peripheral is

    -- COMPONENT DECLARATIONS
    component uart IS
        generic(
            clk_freq  :  INTEGER    := 20_000_000;  --frequency of system clock in Hertz
            baud_rate :  INTEGER    := 115_200;     --data link baud rate in bits/second
            os_rate   :  INTEGER    := 16;          --oversampling rate to find center of receive bits (in samples per baud period)
            d_width   :  INTEGER    := 8;           --data bus width
            parity    :  INTEGER    := 1;           --0 for no parity, 1 for parity
            parity_eo :  STD_LOGIC  := '0');        --'0' for even, '1' for odd parity
        port(
            clk      :  in   STD_LOGIC;                             --system clock
            reset_n  :  in   STD_LOGIC;                             --ascynchronous reset
            tx_ena   :  in   STD_LOGIC;                             --initiate transmission 
            tx_data  :  in   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
            rx       :  in   STD_LOGIC;                             --receive pin
            rx_busy  :  OUT  STD_LOGIC;                             --data reception in progress
            rx_error :  OUT  STD_LOGIC;                             --start, parity, or stop bit error detected
            rx_data  :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data received
            tx_busy  :  OUT  STD_LOGIC;                             --transmission in progress
            tx       :  OUT  STD_LOGIC);                            --transmit pin
    end component uart;
    
    -- (DE-)LOCALISING IN/OUTPUTS
    -- UART signals
    signal tx_ena_i     : STD_LOGIC := '0';
    signal tx_data_i    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tx_busy_o    : STD_LOGIC;
    signal rx_busy_o    : STD_LOGIC;
    signal rx_error_o   : STD_LOGIC;
    signal rx_data_o    : STD_LOGIC_VECTOR(7 downto 0);

    -- RX latch
    signal rx_data_reg  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rx_valid_reg : STD_LOGIC := '0';
    signal rx_busy_prev : STD_LOGIC := '0';

    -- Write detect
    signal write_tx         : STD_LOGIC;

begin
    -------------------------------------------------------------------------------
    -- COMPONENTS MAPPING
    -------------------------------------------------------------------------------
    uart_inst : uart
        port map(
            clk      => clk,
            reset_n  => rst,
            tx_ena   => tx_ena_i,
            tx_data  => tx_data_i,
            rx       => uart_rx,
            rx_busy  => rx_busy_o,
            rx_error => rx_error_o,
            rx_data  => rx_data_o,
            tx_busy  => tx_busy_o,
            tx       => uart_tx
        );

    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    -- Write decode (TX register @ 0x00)
    write_tx <= '1' when (sel = '1' and we = '1' and addr(3 downto 2) = "00") else '0';

    tx_control: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                tx_ena_i  <= '0';
                tx_data_i <= (others => '0');
            else
                tx_ena_i <= '0';  -- default (pulse!)

                if write_tx = '1' and tx_busy_o = '0' then
                    tx_data_i <= wdata(7 downto 0);
                    tx_ena_i  <= '1';
                end if;
            end if;
        end if;
    end process;

    rx_latch: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                rx_data_reg  <= (others => '0');
                rx_valid_reg <= '0';
                rx_busy_prev <= '0';
            else
                -- Keep track of the previous state to detect edges
                rx_busy_prev <= rx_busy_o;

                -- latch only on the falling edge of rx_busy
                if rx_busy_prev = '1' and rx_busy_o = '0' then
                    rx_data_reg  <= rx_data_o;
                    rx_valid_reg <= '1';
                end if;

                -- clear when CPU reads RXDATA
                if sel = '1' and re = '1' and addr(3 downto 2) = "10" then
                    rx_valid_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    read_mux: process(sel, re, addr, rx_data_reg, tx_busy_o, rx_valid_reg, rx_error_o)
    begin
        rdata <= (others => '0');

        if sel = '1' and re = '1' then
            case addr(3 downto 2) is

                -- STATUS @ 0x04
                when "01" =>
                    rdata(0) <= tx_busy_o;
                    rdata(1) <= rx_busy_o;
                    rdata(2) <= rx_error_o;
                    rdata(3) <= rx_valid_reg;

                -- RXDATA @ 0x08
                when "10" =>
                    rdata(7 downto 0) <= rx_data_reg;

                when others =>
                    null;
            end case;
        end if;
    end process;

    -- Bus busy (no stalling for UART)
    busy <= '0';

end architecture Behavioral;