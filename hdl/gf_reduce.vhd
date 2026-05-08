--------------------------------------------------------------------------------
-- Module Name:     gf_reduce_core - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Core module for Galois field reduction, based on C-code from
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

entity gf_reduce_core is
    port (
        x      : in  UNSIGNED(63 downto 0);
        result : out UNSIGNED(15 downto 0)
    );
end entity gf_reduce_core;

architecture Behavioral of gf_reduce_core is

    function ctz(a : UNSIGNED(15 downto 0)) return INTEGER is
    begin
        for i in 0 to 15 loop
            if a(i) = '1' then
                return i;
            end if;
        end loop;
        return 16;
    end function;

    constant PARAM_M          : INTEGER               := 8;
    constant PARAM_GF_POLY_M2 : INTEGER               := 4;
    constant PARAM_GF_POLY    : UNSIGNED(15 downto 0) := to_unsigned(16#11D#, 16);
    constant PARAM_GF_POLY_WT : INTEGER               := 5;

begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process(x)
        variable vx : UNSIGNED(63 downto 0);
        variable deg_x : INTEGER;
        variable steps : INTEGER;
        variable modv : UNSIGNED(63 downto 0);
        variable z1, z2, dist : INTEGER;
        variable rmdr : UNSIGNED(15 downto 0);
    begin
        vx := x;
        -- compute deg_x
        deg_x := 0;
        for i in 63 downto 0 loop
            if vx(i) = '1' then
                deg_x := i;
                exit;
            end if;
        end loop;

        if deg_x < PARAM_M then
            result <= resize(vx, 16);
        else
            steps := ((deg_x - (PARAM_M - 1)) + (PARAM_GF_POLY_M2 - 1)) / PARAM_GF_POLY_M2;
            for i in 0 to 13 loop
                if i < steps then
                    modv := shift_right(vx, PARAM_M);
                    vx := vx and ((shift_left(to_unsigned(1, 64), PARAM_M)) - 1);
                    vx := vx xor modv;
                    z1 := 0;
                    rmdr := PARAM_GF_POLY xor to_unsigned(1, 16);
                    for j in (PARAM_GF_POLY_WT - 2) downto 1 loop
                        z2 := ctz(rmdr);
                        dist := z2 - z1;
                        modv := shift_left(modv, dist);
                        vx := vx xor modv;
                        rmdr := rmdr xor shift_left(to_unsigned(1, 16), z2);
                        z1 := z2;
                    end loop;
                end if;
            end loop;
            result <= resize(vx, 16);
        end if;
    end process;

end architecture Behavioral;