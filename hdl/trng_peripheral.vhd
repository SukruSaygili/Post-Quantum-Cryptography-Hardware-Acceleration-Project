--------------------------------------------------------------------------------
-- Module Name:     trng_peripheral - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Wrapper module for the neoTRNG true random number generator, 
--                  which provides a MMIO interface for the RISC-V processor to 
--                  control and read random data from the TRNG
--
-- Revision     Date         Author     Comments
-- v0.1         27.04.2026  SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity trng_peripheral is
    port (
        clk   : in  STD_LOGIC;
        rst   : in  STD_LOGIC;
        sel   : in  STD_LOGIC;
        we    : in  STD_LOGIC;
        re    : in  STD_LOGIC;
        addr  : in  STD_LOGIC_VECTOR(31 downto 0);
        wdata : in  STD_LOGIC_VECTOR(31 downto 0);
        rdata : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity trng_peripheral;

architecture Behavioral of trng_peripheral is

    -- COMPONENT DECLARATIONS
    component neoTRNG is
        generic (
            NUM_CELLS     : NATURAL range 1 to 255;
            NUM_INV_START : NATURAL range 3 to 4095;
            NUM_RAW_BITS  : NATURAL range 8 to 4096;
            SIM_MODE      : BOOLEAN
        );
        port (
            clk_i    : in  STD_ULOGIC;
            rstn_i   : in  STD_ULOGIC;
            enable_i : in  STD_ULOGIC;
            valid_o  : out STD_ULOGIC;
            data_o   : out STD_ULOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- INTERNAL SIGNALS
    signal trng_enable_reg : STD_LOGIC := '0';
    signal trng_valid_flag : STD_LOGIC := '0';
    signal trng_data_reg   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- SIGNALS FROM neoTRNG
    signal neo_valid : STD_ULOGIC;
    signal neo_data  : STD_ULOGIC_VECTOR(7 downto 0);

begin
    -------------------------------------------------------------------------------
    -- COMPONENTS MAPPING
    -------------------------------------------------------------------------------
    neoTRNG_inst: neoTRNG
        generic map (
            NUM_CELLS     => 3,    -- 3 entropy cells / ring-oscillators in total
            NUM_INV_START => 5,    -- 5 inverters in first ring-oscillator
            NUM_RAW_BITS  => 64,   -- consume 64 raw random bits per output byte
            SIM_MODE      => false -- disable simulation-mode for physical implementation
        )
        port map (
            clk_i    => STD_ULOGIC(clk),
            rstn_i   => STD_ULOGIC(rst),
            enable_i => STD_ULOGIC(trng_enable_reg),
            valid_o  => neo_valid,
            data_o   => neo_data
        );

    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    write_and_capture_process: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                trng_enable_reg <= '0';
                trng_valid_flag <= '0';
                trng_data_reg   <= (others => '0');
            else
                --Handle CPU Writes (Control Register)
                if sel = '1' and we = '1' then
                    if addr(4 downto 2) = "000" then
                        trng_enable_reg <= wdata(0);
                    end if;
                end if;

                -- Capture TRNG Data when valid
                -- If neoTRNG asserts valid, capture data and set flag
                if neo_valid = '1' and trng_valid_flag = '0' then
                    trng_data_reg   <= STD_LOGIC_VECTOR(neo_data);
                    trng_valid_flag <= '1';
                end if;

                -- Clear Valid Flag on CPU Read of the Data Register
                if sel = '1' and re = '1' then
                    if addr(4 downto 2) = "001" then
                        trng_valid_flag <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    read_decoder: process(sel, re, addr, trng_enable_reg, trng_valid_flag, trng_data_reg)
    begin
        rdata <= (others => '0');  -- default prevents latch
        
        if sel = '1' and re = '1' then
            case addr(4 downto 2) is
                when "000" => 
                    -- Status/Control Register
                    rdata(0) <= trng_enable_reg;
                    rdata(1) <= trng_valid_flag;
                when "001" => 
                    -- Data Register (bits 7:0 contain the byte)
                    rdata(7 downto 0) <= trng_data_reg;
                when others => null;
            end case;
        end if;
    end process;

end architecture Behavioral;