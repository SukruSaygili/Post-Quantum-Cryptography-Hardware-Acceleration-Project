--------------------------------------------------------------------------------
-- Module Name:     base_mul_peripheral - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Wrapper module for the base_mul-accelerator
--
-- Revision     Date         Author     Comments
-- v0.1         22.04.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;


entity base_mul_peripheral is
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
end entity base_mul_peripheral;

architecture Behavioral of base_mul_peripheral is

    -- COMPONENT DECLARATIONS
    component karatNbit is
        generic (
            N : integer := 64
        );
        port (
            multiplier : in UNSIGNED(N-1 downto 0);
            multiplicand : in UNSIGNED(N-1 downto 0);
            p : out UNSIGNED(2*N-1 downto 0)
        );
    end component; 

    -- INTERNAL SIGNALS
    signal a_reg        : UNSIGNED(63 downto 0);
    signal b_reg        : UNSIGNED(63 downto 0);
    signal res_reg      : UNSIGNED(127 downto 0);

begin
    -------------------------------------------------------------------------------
    -- COMPONENTS MAPPING
    -------------------------------------------------------------------------------
    karatsuba : karatNbit
        generic map(
            N => 64
        )
        port map(
            multiplier => a_reg,
            multiplicand => b_reg,
            p => res_reg
        );

    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    write_decoder: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                a_reg    <= (others => '0');
                b_reg    <= (others => '0');
            else
                if sel = '1' and we = '1' then
                    case addr(4 downto 2) is
                        when "000" => a_reg(31 downto 0)  <= UNSIGNED(wdata);
                        when "001" => a_reg(63 downto 32) <= UNSIGNED(wdata);
                        when "010" => b_reg(31 downto 0)  <= UNSIGNED(wdata);
                        when "011" => b_reg(63 downto 32) <= UNSIGNED(wdata);
                        when others => null;
                    end case;
                end if;
            end if;
        end if;
    end process;

    read_decoder: process(sel, re, addr, res_reg)
    begin
        rdata <= (others => '0');  -- default prevents latch
        
        if sel = '1' and re = '1' then
            case addr(4 downto 2) is
                when "100" => rdata <= STD_LOGIC_VECTOR(res_reg(31 downto 0));
                when "101" => rdata <= STD_LOGIC_VECTOR(res_reg(63 downto 32));
                when "110" => rdata <= STD_LOGIC_VECTOR(res_reg(95 downto 64));
                when "111" => rdata <= STD_LOGIC_VECTOR(res_reg(127 downto 96));
                when others => null;
            end case;
        end if;
    end process;

end architecture Behavioral;