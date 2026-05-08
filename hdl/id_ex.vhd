--------------------------------------------------------------------------------
-- Module Name:     id_ex - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Id_Ex pipeline register, which holds the outputs of the Id 
--                  stage and passes them to the Ex stage.
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author     Comments
-- v0.1         10.11.2024   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity id_ex is
    Port (
        --INPUTS
        clk             : in STD_LOGIC;
        rst             : in STD_LOGIC;
        enable          : in STD_LOGIC;
        flush           : in STD_LOGIC;

        -- Data 
        data1_ID_IN     : in STD_LOGIC_VECTOR (31 downto 0);
        data2_ID_IN     : in STD_LOGIC_VECTOR (31 downto 0);
        
        newAddress_ID_IN: in STD_LOGIC_VECTOR (31 downto 0);

        PC_ID_IN        : in STD_LOGIC_VECTOR (31 downto 0);
        PC4_ID_IN       : in STD_LOGIC_VECTOR (31 downto 0);
        imm_ID_IN       : in STD_LOGIC_VECTOR (31 downto 0);

        -- Addresses of data
        instrRD_ID_IN   : in STD_LOGIC_VECTOR (4 downto 0);
        instrRS1_ID_IN  : in STD_LOGIC_VECTOR (4 downto 0);
        instrRS2_ID_IN  : in STD_LOGIC_VECTOR (4 downto 0);
        -- Exec
        StoreSel_ID_IN  : in STD_LOGIC_VECTOR (1 downto 0);
        ALUOp_ID_IN     : in STD_LOGIC_VECTOR (4 downto 0);
        ALUSrc2_ID_IN   : in STD_LOGIC;
        ALUSrc1_ID_IN   : in STD_LOGIC;
        -- Mem
        branch_ID_IN    : in STD_LOGIC_VECTOR (3 downto 0);
        MemRead_ID_IN   : in STD_LOGIC;
        MemWrite_ID_IN  : in STD_LOGIC;
        -- Wb
        MemtoReg_ID_IN  : in STD_LOGIC_VECTOR (2 downto 0);
        RegWrite_ID_IN  : in STD_LOGIC;
        LoadSel_ID_IN   : in STD_LOGIC_VECTOR (1 downto 0);
        
        --OUTPUTS
        -- Data 
        data1_EX_OUT     : out STD_LOGIC_VECTOR (31 downto 0);
        data2_EX_OUT     : out STD_LOGIC_VECTOR (31 downto 0);

        newAddress_EX_OUT: out STD_LOGIC_VECTOR (31 downto 0);

        PC_EX_OUT        : out STD_LOGIC_VECTOR (31 downto 0); 
        PC4_EX_OUT       : out STD_LOGIC_VECTOR (31 downto 0); 
        imm_EX_OUT       : out STD_LOGIC_VECTOR (31 downto 0);

        -- Addresses of data
        instrRD_EX_OUT   : out STD_LOGIC_VECTOR (4 downto 0);
        instrRS1_EX_OUT  : out STD_LOGIC_VECTOR (4 downto 0);
        instrRS2_EX_OUT  : out STD_LOGIC_VECTOR (4 downto 0);
        -- EX
        StoreSel_EX_OUT  : out STD_LOGIC_VECTOR (1 downto 0);
        ALUOp_EX_OUT     : out STD_LOGIC_VECTOR (4 downto 0);
        ALUSrc2_EX_OUT   : out STD_LOGIC;
        ALUSrc1_EX_OUT   : out STD_LOGIC;
        -- MEM
        branch_EX_OUT    : out STD_LOGIC_VECTOR (3 downto 0);
        MemRead_EX_OUT   : out STD_LOGIC;
        MemWrite_EX_OUT  : out STD_LOGIC;
        -- WB
        MemtoReg_EX_OUT  : out STD_LOGIC_VECTOR (2 downto 0);
        RegWrite_EX_OUT  : out STD_LOGIC;
        LoadSel_EX_OUT   : out STD_LOGIC_VECTOR (1 downto 0)
        );
end entity id_ex;

architecture Behavioral of id_ex is

    -- (DE-)LOCALISING IN/OUTPUTS
    
    signal imm_EX_REG       : STD_LOGIC_VECTOR (31 downto 0);
    signal PC_EX_REG        : STD_LOGIC_VECTOR (31 downto 0);
    signal PC4_EX_REG       : STD_LOGIC_VECTOR (31 downto 0);

    signal newAdress_EX_REG : STD_LOGIC_VECTOR (31 downto 0);

    signal data1_EX_REG     : STD_LOGIC_VECTOR(31 downto 0);
    signal data2_EX_REG     : STD_LOGIC_VECTOR(31 downto 0);
    signal instrRD_EX_REG   : STD_LOGIC_VECTOR(4 downto 0);
    signal instrRS1_EX_REG  : STD_LOGIC_VECTOR(4 downto 0);
    signal instrRS2_EX_REG  : STD_LOGIC_VECTOR(4 downto 0);
    signal branch_EX_REG    : STD_LOGIC_VECTOR(3 downto 0);
    signal ALUOp_EX_REG     : STD_LOGIC_VECTOR(4 downto 0);
    signal ALUSrc2_EX_REG   : STD_LOGIC;
    signal ALUSrc1_EX_REG   : STD_LOGIC;
    signal StoreSel_EX_REG  : STD_LOGIC_VECTOR (1 downto 0);
    signal MemRead_EX_REG   : STD_LOGIC;
    signal MemWrite_EX_REG  : STD_LOGIC;
    signal MemtoReg_EX_REG  : STD_LOGIC_VECTOR(2 downto 0);
    signal RegWrite_EX_REG  : STD_LOGIC; 
    signal LoadSel_EX_REG   : STD_LOGIC_VECTOR (1 downto 0);

begin
  -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
  -------------------------------------------------------------------------------
    imm_EX_OUT       <= imm_EX_REG;
    PC_EX_OUT        <= PC_EX_REG;
    PC4_EX_OUT       <= PC4_EX_REG;
    data1_EX_OUT     <= data1_EX_REG;
    data2_EX_OUT     <= data2_EX_REG;
    instrRD_EX_OUT   <= instrRD_EX_REG;
    instrRS1_EX_OUT  <= instrRS1_EX_REG;
    instrRS2_EX_OUT  <= instrRS2_EX_REG;
    branch_EX_OUT    <= branch_EX_REG;
    ALUOp_EX_OUT     <= ALUOp_EX_REG;
    ALUSrc2_EX_OUT   <= ALUSrc2_EX_REG;
    ALUSrc1_EX_OUT   <= ALUSrc1_EX_REG;
    StoreSel_EX_OUT  <= StoreSel_EX_REG;
    MemRead_EX_OUT   <= MemRead_EX_REG;
    MemWrite_EX_OUT  <= MemWrite_EX_REG;
    MemtoReg_EX_OUT  <= MemtoReg_EX_REG;
    RegWrite_EX_OUT  <= RegWrite_EX_REG;
    LoadSel_EX_OUT   <= LoadSel_EX_REG;
    newAddress_EX_OUT<= newAdress_EX_REG;
    
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                imm_EX_REG       <= (others => '0');
                PC_EX_REG        <= (others => '0');
                PC4_EX_REG       <= (others => '0');
                data1_EX_REG     <= (others => '0');
                data2_EX_REG     <= (others => '0');
                instrRD_EX_REG   <= (others => '0');
                instrRS1_EX_REG  <= (others => '0');
                instrRS2_EX_REG  <= (others => '0');
                branch_EX_REG    <= (others => '0');
                ALUOp_EX_REG     <= (others => '0');
                ALUSrc2_EX_REG   <= '0';
                ALUSrc1_EX_REG   <= '0';
                StoreSel_EX_REG  <= (others => '0');
                MemRead_EX_REG   <= '0';
                MemWrite_EX_REG  <= '0';
                MemtoReg_EX_REG  <= (others => '0');
                RegWrite_EX_REG  <= '0';
                LoadSel_EX_REG   <= (others => '0');
                newAdress_EX_REG <= (others => '0');
            elsif enable = '1' then
                if flush = '0' then
                    imm_EX_REG       <= (others => '0');
                    PC_EX_REG        <= (others => '0');
                    PC4_EX_REG       <= (others => '0');
                    data1_EX_REG     <= (others => '0');
                    data2_EX_REG     <= (others => '0');
                    instrRD_EX_REG   <= (others => '0');
                    instrRS1_EX_REG  <= (others => '0');
                    instrRS2_EX_REG  <= (others => '0');
                    branch_EX_REG    <= (others => '0');
                    ALUOp_EX_REG     <= (others => '0');
                    ALUSrc2_EX_REG   <= '0';
                    ALUSrc1_EX_REG   <= '0';
                    StoreSel_EX_REG  <= (others => '0');
                    MemRead_EX_REG   <= '0';
                    MemWrite_EX_REG  <= '0';
                    MemtoReg_EX_REG  <= (others => '0');
                    RegWrite_EX_REG  <= '0';
                    LoadSel_EX_REG   <= (others => '0');
                    newAdress_EX_REG <= (others => '0');
                else
                    imm_EX_REG       <= imm_ID_IN;
                    PC_EX_REG        <= PC_ID_IN;
                    PC4_EX_REG       <= PC4_ID_IN;
                    data1_EX_REG     <= data1_ID_IN;
                    data2_EX_REG     <= data2_ID_IN;
                    instrRD_EX_REG   <= instrRD_ID_IN;
                    instrRS1_EX_REG  <= instrRS1_ID_IN;
                    instrRS2_EX_REG  <= instrRS2_ID_IN;
                    branch_EX_REG    <= branch_ID_IN;
                    ALUOp_EX_REG     <= ALUOp_ID_IN;
                    ALUSrc2_EX_REG   <= ALUSrc2_ID_IN;
                    ALUSrc1_EX_REG   <= ALUSrc1_ID_IN;
                    StoreSel_EX_REG  <= StoreSel_ID_IN;
                    MemRead_EX_REG   <= MemRead_ID_IN;
                    MemWrite_EX_REG  <= MemWrite_ID_IN;
                    MemtoReg_EX_REG  <= MemtoReg_ID_IN;
                    RegWrite_EX_REG  <= RegWrite_ID_IN;
                    LoadSel_EX_REG   <= LoadSel_ID_IN;
                    newAdress_EX_REG <= newAddress_ID_IN;
                end if;
            end if;
        end if;    
    end process;

end architecture Behavioral;