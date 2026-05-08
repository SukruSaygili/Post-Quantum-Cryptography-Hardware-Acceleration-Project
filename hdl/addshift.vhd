--MIT License
--
--Copyright (c) 2024 ParsaJahantab
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.
--------------------------------------------------------------------------------
-- Module Name:     addshift - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Modified version of the addshift module that performs 
--                  multiplicationin GF(2) using bitwise XOR for addition and left 
--                  shifts for multiplication, suitable for polynomial multiplication 
--                  in the context of HQC-KEM.
--
-- Revision     Date         Author                     Comments
-- v0.1         22.04.2026   ParsaJahantab-SaSu         Modified version
--------------------------------------------------------------------------------

library IEEE ;
    use IEEE.STD_LOGIC_1164.ALL ;
    use IEEE.NUMERIC_STD.ALL ;

entity addshift is
    generic (
        N : INTEGER := 32
    );
    port (
        multiplier   : in  UNSIGNED(N-1 downto 0);
        multiplicand : in  UNSIGNED(N-1 downto 0);
        product            : out UNSIGNED(2*N-1 downto 0)
    );
end entity addshift;

architecture Behavioral of addshift is
begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    comb: process (multiplier, multiplicand)
        variable temp_p : UNSIGNED(2*N-1 downto 0);
        variable temp_m : UNSIGNED(2*N-1 downto 0);
    begin
        temp_p := (others => '0');
        temp_m := (2*N-1 downto N => '0') & multiplicand;

        for i in 0 to N-1 loop
            if multiplier(i) = '1' then
                temp_p := temp_p xor temp_m;
            end if;
            temp_m := shift_left(temp_m, 1);
        end loop;

        product <= temp_p;
    end process;
end architecture Behavioral;
