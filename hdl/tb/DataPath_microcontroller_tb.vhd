--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     riscv_microcontroller_tb - Behavioural
-- Project Name:    Testbench for RISC-V microcontroller
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20241128   VlJo       Initial version, modified (sukru)
--
--------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

library work;
    --use work.PKG_hwswcd.ALL;

entity DataPath_microcontroller_tb is
    generic (
        G_DATA_WIDTH : integer := 32;
        G_DEPTH_LOG2 : integer := 11;

        FNAME_IMEM_INIT_FILE : string := "..\firmware_imem.hex";
        FNAME_DMEM_INIT_FILE : string := "..\firmware_dmem.hex";
        FNAME_OUT_FILE :       string := "..\simulation_output.txt"
    );
end entity DataPath_microcontroller_tb;

architecture Behavioural of DataPath_microcontroller_tb is

    -- COMPONENT DECLARATIONS
    component DataPath_microcontroller is
        port(
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            ALU_result  : out std_logic_vector(31 downto 0);        

            -- dmem
            dmem_dataOut : in STD_LOGIC_VECTOR(31 downto 0);
            dmem_writeEn : out STD_LOGIC;
            dmem_Address : out STD_LOGIC_VECTOR(31 downto 0);
            dmem_dataIn : out STD_LOGIC_VECTOR(31 downto 0);

            -- imem
            imem_instruction : in STD_LOGIC_VECTOR(31 downto 0);
            imem_Address : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component DataPath_microcontroller;

    -- clock and reset
    signal clk_i : STD_LOGIC := '0';
    signal rst_i : STD_LOGIC := '0';

    constant clk_period : time := 100 ns;

    --imem
    signal imem_Address : STD_LOGIC_VECTOR(G_DEPTH_LOG2-1 downto 0);
    signal imem_instruction : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);

    --dmem
    signal dmem_dataIn : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal dmem_Address : STD_LOGIC_VECTOR(G_DEPTH_LOG2-1 downto 0);
    signal dmem_writeEn : STD_LOGIC;
    signal dmem_dataOut : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    
    --other
    signal dmem_Address_o : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal imem_Address_o : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);

    -- constants
    constant C_ZEROES: STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0) := (others => '0');

begin

    -------------------------------------------------------------------------------
    -- STIMULI
    -------------------------------------------------------------------------------
    --PREG_LEDS: process(clk_i)
    --begin
    --    if rising_edge(clk_i) then 
    --        if rst_i = '1' then 
    --            leds <= "0000";
    --        else
    --            if dmem_writeEn = '1' and dmem_Address = x"80000000" then 
    --                leds <= dmem_dataIn(3 downto 0);
    --            end if;
    --        end if;
    --    end if;
    --end process;


    -------------------------------------------------------------------------------
    -- DUT
    -------------------------------------------------------------------------------
    DUT: component DataPath_microcontroller port map(
        clk => clk_i,
        rst => rst_i,
        ALU_result => open,
        dmem_dataOut => dmem_dataOut,
        dmem_writeEn => dmem_writeEn,
        dmem_Address => dmem_Address_o, -- dmem_Address => dmem_Address_o, indien slicing hier gebeurt
        dmem_dataIn => dmem_dataIn,
        imem_instruction => imem_instruction,
        imem_Address => imem_Address_o -- imem_Address => imem_Address_o, indien slicing hier gebeurt
    );

    --voorlopig gebeurt slicing nog in DataPath.vhd
    --indien slicing hier gebeurt, gewoon onderstaande uncommenten
    --dmem_Address <= dmem_Address_o(G_DEPTH_LOG2-2+1 downto 2);
    dmem_Address <= dmem_Address_o(G_DEPTH_LOG2-1 downto 0);
    imem_Address <= imem_Address_o(G_DEPTH_LOG2-1+2 downto 0+2);

    -------------------------------------------------------------------------------
    -- IMEM
    -------------------------------------------------------------------------------



    -------------------------------------------------------------------------------
    -- DMEM
    -------------------------------------------------------------------------------


    -------------------------------------------------------------------------------
    -- CLOCK
    -------------------------------------------------------------------------------
    PCLK: process
    begin
        clk_i <= '1';
        wait for clk_period/2;
        clk_i <= '0';
        wait for clk_period/2;
    end process PCLK;


    -------------------------------------------------------------------------------
    -- RESET
    -------------------------------------------------------------------------------
    PRST: process
    begin
        rst_i <= '0';
        wait for clk_period*9;
        wait for clk_period/2;
        rst_i <= '1';
        wait;
    end process PRST;

end Behavioural;