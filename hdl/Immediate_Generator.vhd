--------------------------------------------------------------------------------
-- Module Name:     Immediate_Generator - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Immediate_Generator for the RV32IM instruction set (modified)
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author               Comments
-- v0.2         30.03.2026   VlJo-MyKr-SaSu       Modified version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.all;
    use IEEE.NUMERIC_STD.all;
    use IEEE.STD_LOGIC_UNSIGNED.all;

entity Immediate_Generator is
    port (
        instruction     : in STD_LOGIC_VECTOR(31 downto 0);
        immediate       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity Immediate_Generator;

architecture Behavioral of Immediate_Generator is
    -- INTERNAL SIGNALS
    signal opcode : STD_LOGIC_VECTOR(6 downto 0);
    signal temporal: STD_LOGIC_VECTOR(31 downto 0);
    signal ItypeImmediate,StypeImmediate,SBtypeImmediate, UtypeImmediate
            ,UJtypeImmediate : STD_LOGIC_VECTOR(31 downto 0);
begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process( instruction, opcode, ItypeImmediate, StypeImmediate, SBtypeImmediate, UJtypeImmediate, UtypeImmediate )
    begin
        case opcode is
            when ("0010011") => temporal <= ItypeImmediate;                 -- loads and immediate arith
            when ("0000011") => temporal <= ItypeImmediate;
            when ("0100011") => temporal <= StypeImmediate;                 -- stores
            when ("1100011") => temporal <= SBtypeImmediate;                -- branches
            when ("1100111") => temporal <= ItypeImmediate;                 -- JALR
            when ("1101111") => temporal <= UJtypeImmediate;                -- JAL
            when ("0110111") => temporal <= UtypeImmediate;                 -- LUI
            when ("0010111") => temporal <= UtypeImmediate;                 -- AUIPC
            when others => temporal <= (others => '0');
        end case;       
    end process ; 
    
    ItypeImmediate <= X"00000" & instruction(31 downto 20) when instruction(31) = '0' else (X"FFFFF" & instruction(31 downto 20));
    StypeImmediate <= X"00000" & ( instruction(31 downto 25) & instruction(11 downto 7) ) when instruction(31) = '0' else
                      (X"FFFFF" & ( instruction(31 downto 25) & instruction(11 downto 7) ));
    SBtypeImmediate <= X"00000" & ( instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) ) 
                        when instruction(31) = '0' else
                        (X"FFFFF"  & (instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8)) );
    UtypeImmediate <= instruction(31 downto 12) & X"000";
    UJtypeImmediate <= X"000" & ( instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) ) when 
                        instruction(31) = '0' else
                        (X"FFF" & ( instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21)) );

    opcode <= instruction(6 downto 0);
    immediate <= temporal;

end architecture Behavioral;