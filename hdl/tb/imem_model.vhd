--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     imem_model - Behavioural
-- Project Name:    HWSWCD
-- Description:     Memory model for IMEM. 
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

entity imem_model is
    generic (
        G_DATA_WIDTH : integer := 32;
        G_DEPTH_LOG2 : integer := 10; 
        FNAME_INIT_FILE : string := "data.dat"
    );
    port (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;

        Address : IN STD_LOGIC_VECTOR(G_DEPTH_LOG2-1 downto 0);
        instruction : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0)
    );
end entity imem_model;

architecture Behavioural of imem_model is

    -- localised inputs
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal ad_i : STD_LOGIC_VECTOR(G_DEPTH_LOG2-1 downto 0);
    signal do_o : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);


    signal ad_int : natural;

    file fh : text;

    type T_memory is array(0 to 2**G_DEPTH_LOG2-1) of STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal mem : T_memory;


    constant C_MAX_ADDRESS : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0) := (others => '1');

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clk;
    reset_i <= rst;
    ad_i <= Address;
    instruction <= do_o;


    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    ad_int <= to_integer(unsigned(ad_i));
    do_o <= mem(ad_int) when reset_i = '1' else (others => 'U');


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
            file_open(fh, FNAME_INIT_FILE, read_mode);

            while not endfile(fh) loop
                readline(fh, v_line);
                hread(v_line, v_temp);
                mem(v_pointer) <= v_temp;
                v_pointer := v_pointer + 1;
            end loop;

            file_close(fh);
        elsif rising_edge(clock_i) then 

        end if;
    end process;

end Behavioural;
