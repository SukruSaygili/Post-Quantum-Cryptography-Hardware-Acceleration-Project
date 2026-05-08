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
-- Module Name:     karatNbit - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Modified version of the karat64bit module that performs 
--                  multiplicationin GF(2) using bitwise XOR for addition and left 
--                  shifts for multiplication, suitable for polynomial multiplication 
--                  in the context of HQC-KEM.
--
-- Revision     Date         Author                     Comments
-- v0.1         22.04.2026   ParsaJahantab-SaSu         Modified version
--------------------------------------------------------------------------------

library IEEE ;
    use IEEE.STD_LOGIC_1164.all ;
    use IEEE.NUMERIC_STD.all ;

entity karatNbit is
    generic (
        N : INTEGER := 64
    );
    port (
        multiplier : in UNSIGNED(N-1 downto 0);
        multiplicand : in UNSIGNED(N-1 downto 0);
        p : out UNSIGNED(2*N-1 downto 0)
    );
end entity karatNbit; 

architecture Behavioral of karatNbit is
    -------------------------------------------------------------------------------
    -- COMPONENTS MAPPING
    -------------------------------------------------------------------------------
    component addshift is
        generic (
            N : INTEGER := 32
        );
        port (
            multiplier   : in  UNSIGNED(N-1 downto 0);
            multiplicand : in  UNSIGNED(N-1 downto 0);
            product      : out UNSIGNED(2*N-1 downto 0)
        );
    end component;

    -- INTERNAL SIGNALS
    signal first_half_multiplier, second_half_multiplier, 
        first_half_multiplicand, second_half_multiplicand, 
        multiplier_sum, multiplicand_sum                    : UNSIGNED((N/2)-1 downto 0);

    signal product1, product2, product3                     : UNSIGNED(N-1 downto 0);

begin
    -------------------------------------------------------------------------------
    -- COMPONENTS MAPPING
    -------------------------------------------------------------------------------
    k1 : addshift generic map(N => N/2) port map(multiplier => first_half_multiplier,   multiplicand => first_half_multiplicand,   product => product1);
    k2 : addshift generic map(N => N/2) port map(multiplier => second_half_multiplier,  multiplicand => second_half_multiplicand,  product => product2);
    k3 : addshift generic map(N => N/2) port map(multiplier => multiplier_sum,          multiplicand => multiplicand_sum,          product => product3);

    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    first_half_multiplier  <= multiplier(N-1 downto N/2);
    second_half_multiplier <= multiplier(N/2-1 downto 0);
    
    first_half_multiplicand  <= multiplicand(N-1 downto N/2);
    second_half_multiplicand <= multiplicand((N/2)-1 downto 0);

    multiplier_sum   <= first_half_multiplier xor second_half_multiplier;
    multiplicand_sum <= first_half_multiplicand xor second_half_multiplicand;

    p <=
        (product1 & (N - 1 downto 0 => '0')) xor
        ((2 * N - 1 downto N => '0') & product2) xor
        ((2 * N - 1 downto N + N / 2 => '0') &
        (product3 xor product2 xor product1) & (N / 2 - 1 downto 0 => '0'));

end architecture Behavioral;