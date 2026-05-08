--------------------------------------------------------------------------------
-- Module Name:     Control - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Control logic for the RISC-V processor (modified)
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author               Comments
-- v0.2         16.09.2024   VlJo-MyKr-SaSu       Modified version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
    port (
        opcode      : in STD_LOGIC_VECTOR(6 downto 0);
        funct3      : in STD_LOGIC_VECTOR(2 downto 0);
        funct7      : in STD_LOGIC_VECTOR(6 downto 0);
        jump        : out STD_LOGIC;
        ToRegister  : out STD_LOGIC_VECTOR(2 downto 0);
        MemWrite    : out STD_LOGIC;
        MemRead     : out STD_LOGIC;
        Branch      : out STD_LOGIC_VECTOR(3 downto 0);
        ALUOp       : out STD_LOGIC_VECTOR(4 downto 0);
        StoreSel    : out STD_LOGIC_VECTOR (1 downto 0);
        ALUSrc1     : out STD_LOGIC;
        ALUSrc2     : out STD_LOGIC;
        WriteReg    : out STD_LOGIC;
        LoadSel     : out STD_LOGIC_VECTOR(1 downto 0)
    );
end entity Control;

architecture Behavioral of Control is

begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process( opcode, funct7, funct3 )
    begin
        case opcode is
            when "0110011" =>                           --R-type
                MemRead     <= '0';         -- veranderd subLab3
                LoadSel     <= "00";        
                case funct3 is
                    when "000" =>
                        case funct7 is
                            when "0000000" =>               --ADD
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';                                
                                ALUOp       <= "00100";
                                WriteReg    <= '1';
                            when "0100000" =>               --SUB
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00101";
                                WriteReg    <= '1';  
                            when "0000001" =>               --MUL
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "01100";
                                WriteReg    <= '1';     
                            when others =>                  --not included instructions
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00000";
                                WriteReg    <= '0'; 
                        end case;
                    when "001" =>                           
                        case funct7 is
                            when "0000000" =>           --SLL
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00110";
                                WriteReg    <= '1';
                            when "0000001" =>           --MULH
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "01101";
                                WriteReg    <= '1';
                            when others =>
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00000";
                                WriteReg    <= '0'; 
                        end case;
                    when "010" =>                           
                        case funct7 is
                            when "0000000" =>               --SLT
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00011";
                                WriteReg    <= '1';
                            when "0000001" =>               --MULHSU
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "01110";
                                WriteReg    <= '1';
                            when others => 
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00000";
                                WriteReg    <= '0';
                        end case;
                    when "011" =>                           
                        case funct7 is 
                            when "0000000" =>               --SLTU
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "01001";
                                WriteReg    <= '1';
                            when "0000001" =>               --MULHU
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "01111";
                                WriteReg    <= '1';
                            when others => 
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00000";
                                WriteReg    <= '0';
                        end case;
                    when "100" =>                           
                        case funct7 is
                            when "0000000" =>               --XOR
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00010";
                                WriteReg    <= '1';
                            when "0000001" =>               --DIV
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "10000";
                                WriteReg    <= '1';
                            when others => 
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "10000";
                                WriteReg    <= '0';
                        end case;
                    when "101"  =>                          
                        case funct7 is
                            when "0000000" =>               --SRL
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00111";
                                WriteReg    <= '1';
                            when "0000001" =>               --DIVU
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "10001";
                                WriteReg    <= '1';
                            when "0100000" =>               --SRA
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "01000";
                                WriteReg    <= '1';
                            when others => 
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00000";
                                WriteReg    <= '0';
                        end case;
                    when "110"  =>                          
                        case funct7 is
                            when "0000000" =>               --OR
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00001";
                                WriteReg    <= '1';
                            when "0000001" =>               --REM
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "10010";
                                WriteReg    <= '1';
                            when others =>
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00000";
                                WriteReg    <= '0';
                        end case;
                    when "111"  =>                          --AND
                        case funct7 is
                            when "0000000" =>
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00000";
                                WriteReg    <= '1';
                            when "0000001" =>               --REMU
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '1';
                                ALUSrc1     <= '1';
                                ALUOp       <= "10011";
                                WriteReg    <= '1';
                            when others =>
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00000";
                                WriteReg    <= '0';
                        end case;
                    when others =>
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00000";
                        WriteReg    <= '0';
                end case;
            when "0010011" =>                           --I-type (immediate arithm)
                MemRead     <= '0';         -- veranderd subLab3
                LoadSel     <= "00";        
                case funct3 is
                    when "000" =>                   --ADDI
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00100";
                        WriteReg    <= '1';
                    when "001" =>                   --SLLI
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00110";
                        WriteReg    <= '1';
                    when "010" =>                   --SLTI
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00011";
                        WriteReg    <= '1';
                    when "011" =>                   --SLTIU
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "01001";
                        WriteReg    <= '1';
                    when "111" =>                   --ANDI
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00000";
                        WriteReg    <= '1';
                    when "101" =>                   --SLLI
                        case funct7 is
                            when "0000000" =>       --SRLI
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00111";
                                WriteReg    <= '1';
                            when "0100000" =>       --SRAI
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "01000";
                                WriteReg    <= '1';
                            when others =>
                                jump        <= '0';
                                Branch      <= "0000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= "00";
                                ALUSrc2     <= '0';
                                ALUSrc1     <= '1';
                                ALUOp       <= "00000";
                                WriteReg    <= '0';
                        end case;
                    when "100" =>                   --XORI
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00010";
                        WriteReg    <= '1';
                    when "110" =>                   --ORI
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00001";
                        WriteReg    <= '1';
                    when others =>
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00000";
                        WriteReg    <= '0';                                      
                end case;
            when "0000011" =>                           --I-type (Loads)
                case funct3 is
                    when "000" =>                   --LB
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "001";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00100";
                        WriteReg    <= '1';
                        MemRead     <= '1';         -- veranderd subLab3
                        LoadSel     <= "00";
                    when "010" =>                   --LW
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "010";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00100";
                        WriteReg    <= '1';
                        MemRead     <= '1';         -- veranderd subLab3
                        LoadSel     <= "00";
                    when "100" =>                   --LBU
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "001";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00100";
                        WriteReg    <= '1';
                        MemRead     <= '1';         -- veranderd subLab3
                        LoadSel     <= "01";
                    when "001" =>                   --LH
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "001";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00100";
                        WriteReg    <= '1';
                        MemRead     <= '1';         -- veranderd subLab3
                        LoadSel     <= "10";
                    when "101" =>                   --LHU
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "001";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00100";
                        WriteReg    <= '1';
                        MemRead     <= '1';         -- veranderd subLab3
                        LoadSel     <= "11";
                    when others =>
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00000";
                        WriteReg    <= '0';   
                        MemRead     <= '0';         -- veranderd subLab3    
                        LoadSel     <= "00";                              
                end case;
            when "0010111" =>                           --U-type (AUIPC)
                jump        <= '0';
                Branch      <= "0000";
                ToRegister  <= "000";
                MemWrite    <= '0';
                StoreSel    <= "00";
                ALUSrc2     <= '0';
                ALUSrc1     <= '0';
                ALUOp       <= "00100";
                WriteReg    <= '1';
                MemRead     <= '0';
                LoadSel     <= "00";         
            when "0110111" =>                           --U-type (LUI)
                jump        <= '0';
                Branch      <= "0000";
                ToRegister  <= "000";
                MemWrite    <= '0';
                StoreSel    <= "00";
                ALUSrc2     <= '0';
                ALUSrc1     <= '1';
                ALUOp       <= "01011";                  -- forwarding op2 for LUI
                WriteReg    <= '1';
                MemRead     <= '0';  
                LoadSel     <= "00";       
            when "0100011" =>                           --S-type (Stores)
                MemRead     <= '0';         -- veranderd subLab3
                LoadSel     <= "00";
                case funct3 is
                    when "000" =>                   --SB
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '1';
                        StoreSel    <= "01";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00100";
                        WriteReg    <= '0';
                    when "001" =>                   --SH
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '1';
                        StoreSel    <= "10";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00100";
                        WriteReg    <= '0';
                    when "010" =>                   --SW
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '1';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00100";
                        WriteReg    <= '0';
                    when others =>
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00000";
                        WriteReg    <= '0';                                      
                end case;
            when "1100011" =>                           --SB-type (Branches)
                MemRead     <= '0';         -- veranderd subLab3
                LoadSel     <= "00";
                case funct3 is
                    when "000" =>                   --BEQ
                        jump        <= '0';
                        Branch      <= "0001";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '1';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00101";
                        WriteReg    <= '0';
                    when "001" =>                   --BNE
                        jump        <= '0';
                        Branch      <= "0010";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '1';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00101";
                        WriteReg    <= '0';
                    when "100" =>                  --BLT
                        jump        <= '0';
                        Branch      <= "0011";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '1';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00101";
                        WriteReg    <= '0';
                    when "101" =>                  --BGE 
                        jump        <= '0';
                        Branch      <= "0100";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '1';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00101";
                        WriteReg    <= '0';
                    when "110" =>                  --BLTU
                        jump        <= '0';
                        Branch      <= "0111";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '1';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00101";
                        WriteReg    <= '0';
                    when "111" =>                  --BGEU
                        jump        <= '0';
                        Branch      <= "1000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '1';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00101";
                        WriteReg    <= '0';
                    when others =>
                        jump        <= '0';
                        Branch      <= "0000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= "00";
                        ALUSrc2     <= '0';
                        ALUSrc1     <= '1';
                        ALUOp       <= "00000";
                        WriteReg    <= '0';                                     
                end case;
            when "1100111" =>                           --I-type (JALR)
                    jump        <= '1';
                    Branch      <= "0101";
                    ToRegister  <= "011";           --PC
                    MemWrite    <= '0';
                    StoreSel    <= "00";
                    ALUSrc2     <= '0';
                    ALUSrc1     <= '1';
                    ALUOp       <= "00100";       -- was 0101
                    WriteReg    <= '1';
                    MemRead     <= '0';         -- veranderd subLab3
                    LoadSel     <= "00";
            when "1101111" =>                           --UJ-type (JAL)
                    jump        <= '0';
                    Branch      <= "0110";
                    ToRegister  <= "101";           --PC+4
                    MemWrite    <= '0';
                    StoreSel    <= "00";
                    ALUSrc2     <= '1';
                    ALUSrc1     <= '1';
                    ALUOp       <= "00000";      
                    WriteReg    <= '1';         -- was fout, stond op 0
                    MemRead     <= '0';         -- veranderd subLab3
                    LoadSel     <= "00";
            when others =>                  
                    jump        <= '0';
                    Branch      <= "0000";
                    ToRegister  <= "000";           
                    MemWrite    <= '0';
                    StoreSel    <= "00";
                    ALUSrc2     <= '0';
                    ALUSrc1     <= '1';
                    ALUOp       <= "00000";
                    WriteReg    <= '0';
                    MemRead     <= '0';         -- veranderd subLab3
                    LoadSel     <= "00";
        end case;    
    end process;
end architecture Behavioral;