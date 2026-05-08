--------------------------------------------------------------------------------
-- Module Name:     top_fpga - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Top-level FPGA design integrating the RISC-V processor, 
--                  peripherals, and memory components.
--
-- Revision     Date         Author     Comments
-- v0.1         05.03.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity top_fpga is
    Port ( 
        sys_clock : in STD_LOGIC;
        sys_reset : in STD_LOGIC;
        uart_rx   : in STD_LOGIC;
        uart_tx   : out STD_LOGIC;
        leds      : out STD_LOGIC_VECTOR (3 downto 0)
    );
end entity top_fpga;

architecture Behavioral of top_fpga is

    -- COMPONENT DECLARATIONS
    component DataPath is
        port (
            clk         : in std_logic;
            rst         : in std_logic; --reset is button, must be debounced

            -- dmem
            dmem_dataOut : in STD_LOGIC_VECTOR(31 downto 0);
            dmem_writeEn : out STD_LOGIC_VECTOR(3 downto 0);
            dmem_Address : out STD_LOGIC_VECTOR(31 downto 0);
            dmem_dataIn  : out STD_LOGIC_VECTOR(31 downto 0);

            -- imem
            imem_instruction : in STD_LOGIC_VECTOR(31 downto 0);
            imem_Address : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component DataPath;
    
    component clk_wiz_0 is
        port (
            clk_in1  : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            clk_out1 : out STD_LOGIC;
            locked   : out STD_LOGIC
        );
    end component;

    component blk_imem_gen_0
        port (
            clka  : in STD_LOGIC;
            addra : in STD_LOGIC_VECTOR(13 downto 0);
            douta : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component blk_mem_gen_0
        port (
            clka  : in STD_LOGIC;
            addra : in STD_LOGIC_VECTOR(15 downto 0);
            dina  : in STD_LOGIC_VECTOR(31 downto 0);
            douta : out STD_LOGIC_VECTOR(31 downto 0);
            wea   : in STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component uart_peripheral is
        port (
            clk     : in  STD_LOGIC;
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
    end component;

    component cycle_counter is
        port (
            clk     : in  STD_LOGIC;
            rst     : in  STD_LOGIC;

            sel     : in  STD_LOGIC;
            we      : in  STD_LOGIC;
            re      : in  STD_LOGIC;
            addr    : in  STD_LOGIC_VECTOR(3 downto 0);
            rdata   : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component base_mul_peripheral is
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
    end component;

    component gf_accel_peripheral is
        port (
            clk   : in STD_LOGIC;
            rst   : in STD_LOGIC;
            sel   : in STD_LOGIC;
            we    : in STD_LOGIC;
            re    : in STD_LOGIC;
            addr  : in STD_LOGIC_VECTOR(31 downto 0);
            wdata : in STD_LOGIC_VECTOR(31 downto 0);
            rdata : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component trng_peripheral is
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
    end component;
    
    -- (DE-)LOCALISING IN/OUTPUTS
    signal uart_rx_i, uart_tx_o                                         : STD_LOGIC;
    signal led_reg_o                                                    : STD_LOGIC_VECTOR(3 downto 0);

    -- INTERNAL SIGNALS
    signal clk_internal                                                 : STD_LOGIC;
    signal rst_internal                                                 : STD_LOGIC;
    constant RAM_BASE                                                   : UNSIGNED(31 downto 0) := x"00014000";

    signal dmem_writeEn_s, bram_sel_4bit                                : STD_LOGIC_VECTOR(3 downto 0);

    signal dmem_Address_s, dmem_dataIn_s, dmem_dataOut_s, 
        imem_instruction_s, imem_Address_s, bram_data_out               : STD_LOGIC_VECTOR(31 downto 0);
    
    signal dmem_bram_address                                            : STD_LOGIC_VECTOR(15 downto 0);

    signal uart_rdata_s, base_mul_rdata, gf_accel_rdata, trng_rdata, 
        cycle_rdata                                                     : STD_LOGIC_VECTOR(31 downto 0);
    
    signal peripheral_we, peripheral_re, uart_sel, bram_sel, led_sel, 
        cycle_sel, base_mul_sel, gf_accel_sel, trng_sel                 : STD_LOGIC;
    
    --signal signature_reg                                              : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin
    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    uart_rx_i <= uart_rx;
    uart_tx <= uart_tx_o;

    leds <= led_reg_o;

    -------------------------------------------------------------------------------
    -- COMPONENTS MAPPING
    -------------------------------------------------------------------------------
    datapath_inst00: component DataPath
        port map (
            clk              => clk_internal,
            rst              => rst_internal,
            dmem_dataOut     => dmem_dataOut_s,
            dmem_writeEn     => dmem_writeEn_s,
            dmem_Address     => dmem_Address_s,
            dmem_dataIn      => dmem_dataIn_s,
            imem_instruction => imem_instruction_s,
            imem_Address     => imem_Address_s
        );
 
    clk_wiz_0_inst: component clk_wiz_0
        port map (
            clk_in1  => sys_clock,
            reset    => sys_reset,
            clk_out1 => clk_internal,
            locked   => rst_internal
        );


    bram_sel_4bit <= dmem_writeEn_s when bram_sel = '1' else "0000";
    dmem_bram_address <= STD_LOGIC_VECTOR(UNSIGNED(dmem_Address_s(17 downto 2)) - UNSIGNED(RAM_BASE(17 downto 2)));

    dmem_inst: component blk_mem_gen_0
        port map (
            clka  => clk_internal,
            addra => dmem_bram_address,
            dina => dmem_dataIn_s,
            douta => bram_data_out,
            wea => bram_sel_4bit
        );

    imem_inst: component blk_imem_gen_0
        port map (
            clka  => clk_internal,
            addra => imem_Address_s(15 downto 2),
            douta => imem_instruction_s
        );

    cycle_counter_inst : component cycle_counter
        port map (
            clk   => clk_internal,
            rst   => rst_internal,
            sel   => cycle_sel,
            we    => peripheral_we,
            re    => peripheral_re,
            addr  => dmem_Address_s(3 downto 0),
            rdata => cycle_rdata
        );


    -- If ANY byte is written, trigger write.
    peripheral_we <= '1' when dmem_writeEn_s /= "0000" else '0';
    -- If NO bytes are written, it is a read operation.
    peripheral_re <= not peripheral_we;

    uart_peripheral_inst: component uart_peripheral
        port map (
            clk     => clk_internal,
            rst     => rst_internal,
            addr    => dmem_Address_s,
            wdata   => dmem_dataIn_s,
            rdata   => uart_rdata_s,
            we      => peripheral_we,
            re      => peripheral_re,
            sel     => uart_sel,
            busy    => open,
            uart_rx => uart_rx_i,
            uart_tx => uart_tx_o
        );

    base_mul_peripheral_inst: component base_mul_peripheral
        port map (
            clk => clk_internal,
            rst => rst_internal,
            sel => base_mul_sel,
            we => peripheral_we, 
            re => peripheral_re,
            addr => dmem_Address_s,
            wdata => dmem_dataIn_s,
            rdata => base_mul_rdata
        );

    gf_accel_peripheral_inst: component gf_accel_peripheral
        port map (
            clk => clk_internal,
            rst => rst_internal,
            sel => gf_accel_sel,
            we => peripheral_we,
            re => peripheral_re,
            addr => dmem_Address_s,
            wdata => dmem_dataIn_s,
            rdata => gf_accel_rdata
        );

    trng_peripheral_inst: component trng_peripheral
        port map (
            clk => clk_internal,
            rst => rst_internal,
            sel => trng_sel,
            we => peripheral_we,
            re => peripheral_re,
            addr => dmem_Address_s,
            wdata => dmem_dataIn_s,
            rdata => trng_rdata
        );

    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    address_decoder: process(dmem_Address_s, bram_data_out, uart_rdata_s, cycle_rdata, trng_rdata, base_mul_rdata, gf_accel_rdata)
    begin
        -- defaults
        uart_sel      <= '0';
        bram_sel        <= '0';
        led_sel         <= '0';
        dmem_dataOut_s  <= (others => '0');
        cycle_sel       <= '0';
        base_mul_sel  <= '0';
        gf_accel_sel  <= '0';
        trng_sel      <= '0';

        -- region decode
        if dmem_Address_s(31 downto 28) = "1000" then   -- peripheral space
            -- device decode
            case dmem_Address_s(15 downto 12) is
                when "0000" =>  -- UART
                    uart_sel <= '1';
                    dmem_dataOut_s <= uart_rdata_s;
                when "0001" =>  -- LED
                    led_sel <= '1';
                    dmem_dataOut_s <= bram_data_out;
                when "0010" =>  -- cycle counter
                    cycle_sel <= '1';
                    dmem_dataOut_s <= cycle_rdata;
                when "0011" =>  -- base multiplier peripheral
                    base_mul_sel <= '1';
                    dmem_dataOut_s <= base_mul_rdata;
                when "0100" =>  -- GF accelerator peripheral
                    gf_accel_sel <= '1';
                    dmem_dataOut_s <= gf_accel_rdata;
                when "0101" =>  -- TRNG peripheral
                    trng_sel <= '1';
                    dmem_dataOut_s <= trng_rdata;
                when others =>
                    dmem_dataOut_s <= bram_data_out;
            end case;
        else    -- dmem space
            bram_sel <= '1';
            dmem_dataOut_s <= bram_data_out;
        end if;
    end process;
    
    -------------------------------------------------------------------------------
    -- HELPERS/ADDITIONAL TESTS
    -------------------------------------------------------------------------------
    test_led: process(clk_internal)
    begin
        if rising_edge(clk_internal) then
            if rst_internal = '0' then
                led_reg_o <= (others => '1');
            else
                if dmem_writeEn_s /="0000" and led_sel = '1' then
                    led_reg_o <= dmem_dataIn_s(3 downto 0);
                end if;
            end if;
        end if;
    end process;

    --VERIFICATION OF TESTCODE WITH SIGNATURE--
    --signature: process(clk_internal)
    --begin
    --    if rising_edge(clk_internal) then
    --        if reset_sync = '0' then
    --            signature_reg <= (others => '0');
    --        else
    --            if dmem_writeEn_s = '1' and dmem_Address_s = x"82000000" then
    --                signature_reg <= dmem_dataIn_s;
    --            end if;
    --        end if;
    --    end if;
    --end process;
    -------------------------------------------

    --HARDWARE LED TEST COUNTER--
    --process(clk_internal)
    --begin
    --    if rising_edge(clk_internal) then
    --        if reset_sync = '0' then
    --            counter <= (others => '0');
    --        else
    --            counter <= counter + 1;
    --        end if;
    --    end if;
    --end process;
    --leds <= std_logic_vector(counter(26 downto 23));
    -------------------------
end architecture Behavioral;