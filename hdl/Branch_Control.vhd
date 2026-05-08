--------------------------------------------------------------------------------
-- Module Name:     Branch_Control - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Branch prediction logic for the EX-stage of the pipeline, 
--                  which determines whether a branch is taken
--
-- Revision     Date         Author           Comments
-- v0.3         05.12.2024   ToMe - SaSu      Modified version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_ARITH.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Branch_Control is
    port (
        branch              : in STD_LOGIC_VECTOR(3 downto 0);
        signo               : in STD_LOGIC;
        zero                : in STD_LOGIC;
        carry               : in STD_LOGIC;
        PCSrc               : out STD_LOGIC_VECTOR(1 downto 0);
        falsePredict_OUT    : out STD_LOGIC
    );
end entity Branch_Control;

architecture Behavioral of Branch_Control is
    -- INTERNAL SIGNALS
    signal BEQ, BNE, BLT, BGE, BGEU, BLTU, temp : STD_LOGIC;

begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process( branch, signo, zero, BEQ, BNE, BLT, BGE, BLTU, BGEU )
    begin
        case branch is
            when "0001" => temp <= BEQ;
            when "0010" => temp <= BNE;
            when "0011" => temp <= BLT;
            when "0100" => temp <= BGE;
            when "0111" => temp <= BLTU;
            when "1000" => temp <= BGEU;
            when "0101" => temp <= '1';  --JALR
            when "0110" => temp <= '1';  --JAL
            when others => temp <= '0';    
        end case;
    end process ;

    BEQ <= '1' when zero = '1' else '0';
    BNE <= '1' when zero = '0' else '0';
    BLT <= '1' when signo = '1' else '0';
    BGE <= '1' when signo = '0' else '0';
    BLTU <= '1' when carry = '1' else '0';
    BGEU <= '1' when carry = '0' else '0';

    process( branch, temp )
    begin
        if temp = '1' then
            if branch = "0101" then --JALR
                PCSrc <= "10";
            else                    --all other branches
                PCSrc <= "01";
            end if;
        else                        --no branch taken
            PCSrc <= "00";
        end if;
    end process ;

    falsePredict_OUT <= not temp;
    
end architecture Behavioral;