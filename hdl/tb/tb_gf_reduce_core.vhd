--------------------------------------------------------------------------------
-- Module Name:     tb_gf_reduce_core - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Testbench for the GF_Reduce_Core
--
-- Revision     Date         Author    Comments
-- v0.1         24.04.2026   SaSu      Initial version
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_gf_reduce_core is
end entity;

architecture sim of tb_gf_reduce_core is
    signal x_s      : unsigned(63 downto 0);
    signal result_s : unsigned(15 downto 0);

    -- Helper functie voor hex output in rapportage
    function to_hex_string(u : unsigned) return string is
        constant len : integer := (u'length + 3) / 4;
        variable result : string(1 to len);
        variable nibble : integer;
    begin
        for i in 0 to len-1 loop
            nibble := to_integer(u(u'length - 1 - i*4 downto u'length - 4 - i*4));
            case nibble is
                when 0 => result(i+1) := '0';
                when 1 => result(i+1) := '1';
                when 2 => result(i+1) := '2';
                when 3 => result(i+1) := '3';
                when 4 => result(i+1) := '4';
                when 5 => result(i+1) := '5';
                when 6 => result(i+1) := '6';
                when 7 => result(i+1) := '7';
                when 8 => result(i+1) := '8';
                when 9 => result(i+1) := '9';
                when 10 => result(i+1) := 'A';
                when 11 => result(i+1) := 'B';
                when 12 => result(i+1) := 'C';
                when 13 => result(i+1) := 'D';
                when 14 => result(i+1) := 'E';
                when 15 => result(i+1) := 'F';
                when others => result(i+1) := '?';
            end case;
        end loop;
        return result;
    end function;

begin 

    -- Device Under Test (DUT)
    dut: entity work.gf_reduce_core
        port map (
            x      => x_s,
            result => result_s
        );

    -- Stimulus process
    stim: process
    begin
        report "Starting GF Reduce Test...";
        
        -- Test Case 1: De waarde uit de opdracht
        x_s <= x"123456789ABCDEF0";
        wait for 10 ns;
        report "Input: 0x" & to_hex_string(x_s) & " | Result: 0x" & to_hex_string(result_s);
        
        -- Test Case 2: Kleine waarde (geen reductie nodig)
        x_s <= x"000000000000007F";
        wait for 10 ns;
        report "Input: 0x" & to_hex_string(x_s) & " | Result: 0x" & to_hex_string(result_s);
        
        -- Test Case 3: Randgeval graad 8
        x_s <= x"0000000000000100";
        wait for 10 ns;
        report "Input: 0x" & to_hex_string(x_s) & " | Result: 0x" & to_hex_string(result_s);
        
        -- Test Case 4: Allemaal enen
        x_s <= x"FFFFFFFFFFFFFFFF";
        wait for 10 ns;
        report "Input: 0x" & to_hex_string(x_s) & " | Result: 0x" & to_hex_string(result_s);

        report "Test finished. Check the output above.";
        wait;
    end process;

end architecture;
