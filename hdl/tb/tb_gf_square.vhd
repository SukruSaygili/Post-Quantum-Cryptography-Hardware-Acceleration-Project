--------------------------------------------------------------------------------
-- Module Name:     tb_gf_square - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Testbench for the GF_Square
--
-- Revision     Date         Author    Comments
-- v0.1         24.04.2026   SaSu      Initial version
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_gf_square is
end entity;

architecture sim of tb_gf_square is
    signal a_s : unsigned(7 downto 0) := (others => '0');
    signal s_s : unsigned(15 downto 0);

    -- Helper functie voor hex output
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

    -- DUT is combinatorisch
    dut: entity work.gf_square
        port map (
            a => a_s,
            s => s_s
        );

    stim: process
    begin
        report "Starting GF Square Test...";

        -- Test Case 1: All zeros
        a_s <= x"00";
        wait for 10 ns;
        report "Input: 0x" & to_hex_string(a_s) & " | Result: 0x" & to_hex_string(s_s);

        -- Test Case 2: All ones
        a_s <= x"FF";
        wait for 10 ns;
        report "Input: 0x" & to_hex_string(a_s) & " | Result: 0x" & to_hex_string(s_s);

        -- Test Case 3: Alternating bits
        a_s <= x"AA";
        wait for 10 ns;
        report "Input: 0x" & to_hex_string(a_s) & " | Result: 0x" & to_hex_string(s_s);

        -- Test Case 4: Random logic value
        a_s <= x"12";
        wait for 10 ns;
        report "Input: 0x" & to_hex_string(a_s) & " | Result: 0x" & to_hex_string(s_s);

        report "Test finished.";
        wait;
    end process;

end architecture;
