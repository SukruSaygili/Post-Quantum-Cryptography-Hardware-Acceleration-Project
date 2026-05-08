--------------------------------------------------------------------------------
-- Module Name:     gf_square - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Core module for Galois field squaring, based on C-code from
--                  the implementation of HQC-KEM by PQClean.
--                  @inproceedings{SSR:KSSW22,
--                    author    = {Matthias J. Kannwischer and
--                                 Peter Schwabe and
--                                 Douglas Stebila and
--                                 Thom Wiggers},
--                    title     = {Improving Software Quality in Cryptography Standardization Projects},
--                    booktitle = {{IEEE} European Symposium on Security and Privacy, EuroS{\&}P 2022 - Workshops, Genoa, Italy, June 6-10, 2022},
--                    pages     = {19--30},
--                    publisher = {IEEE Computer Society},
--                    address   = {Los Alamitos, CA, USA},
--                    year      = {2022},
--                    url       = {https://eprint.iacr.org/2022/337},
--                    doi       = {10.1109/EuroSPW55150.2022.00010},
--                  }
--
-- Revision     Date         Author     Comments
-- v0.1         24.04.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity gf_square is
    port (
        a  : in  UNSIGNED(7 downto 0);
        s  : out UNSIGNED(15 downto 0)
    );
end entity gf_square;

architecture Behavioral of gf_square is

begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    s <= (15 => '0', 14 => a(7), 13 => '0', 12 => a(6), 11 => '0', 
            10 => a(5), 9  => '0', 8  => a(4), 7  => '0', 6  => a(3),
            5  => '0', 4  => a(2), 3  => '0', 2  => a(1), 1  => '0',
            0  => a(0));
          
end architecture Behavioral;
