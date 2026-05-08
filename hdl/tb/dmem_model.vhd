--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     dmem_model - Behavioural
-- Project Name:    HWSWCD
-- Description:     Memory model for DMEM
--
-- Revision     Date       Author     Comments
-- v0.1         20241202   VlJo       Initial version, modified (sukru)
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.STD_LOGIC_MISC.or_reduce;
    use ieee.std_logic_textio.all;
    use STD.textio.all;

entity dmem_model is
    generic (
        G_DATA_WIDTH : integer := 32;
        G_DEPTH_LOG2 : integer := 10;
        FNAME_INIT_FILE : string := "data.dat"
    );
    port (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        dataIn : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
        Address : IN STD_LOGIC_VECTOR(G_DEPTH_LOG2-1 downto 0);
        writeEn : IN STD_LOGIC;
        dataOut : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0)
    );
end entity dmem_model;

architecture Behavioural of dmem_model is

    -- localised inputs
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal di_i : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal ad_i : STD_LOGIC_VECTOR(G_DEPTH_LOG2-1 downto 0);
    signal we_i : STD_LOGIC;
    signal do_o : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);


    signal ad_int : natural;

    file ifh, ofh : text;

    -- The 'high of the addres is missing the "-1". This makes the memory 1 position larger, but this
    -- is required if an easy implementation for byte granularity is to be used. 
    type T_memory is array(0 to 2**(G_DEPTH_LOG2-2)) of STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal mem : T_memory;

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clk;
    reset_i <= rst;
    di_i <= dataIn;
    ad_i <= Address;
    we_i <= writeEn;
    dataOut <= do_o;


    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    ad_int <= to_integer(unsigned(ad_i(ad_i'high downto 2)));
    -- do_o <= mem(ad_int) when reset_i = '0' else (others => 'U');

    PMUX_BYTE_GRAN: process(reset_i, ad_i, ad_int, mem)
    begin
        if rst = '0' then 
            do_o <= (others => 'U');
        else
            case ad_i(1 downto 0) is
                when "01" => do_o <= mem(ad_int+1)(8-1 downto 0) & mem(ad_int)(G_DATA_WIDTH-1 downto 8);
                when "10" => do_o <= mem(ad_int+1)(16-1 downto 0) & mem(ad_int)(G_DATA_WIDTH-1 downto 16);
                when "11" => do_o <= mem(ad_int+1)(24-1 downto 0) & mem(ad_int)(G_DATA_WIDTH-1 downto 24);
                when others => do_o <= mem(ad_int);
            end case;
        end if;
    end process;

    -------------------------------------------------------------------------------
    -- MEMORY
    -------------------------------------------------------------------------------
    PMEM: process(reset_i, clock_i)
        variable v_line : line;
        variable v_temp : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
        variable v_pointer : integer;
    begin
        if reset_i = '0' then 
            mem <= (others => (others => '0'));

            v_pointer := 0;
            file_open(ifh, FNAME_INIT_FILE, read_mode);

            while not endfile(ifh) loop
                readline(ifh, v_line);
                hread(v_line, v_temp);
                mem(v_pointer) <= v_temp;
                v_pointer := v_pointer + 1;
            end loop;

            file_close(ifh);

        elsif rising_edge(clock_i) then 
            if(we_i = '1') then 
                mem(ad_int) <= di_i;
            end if;
        end if;
    end process;

end Behavioural;
