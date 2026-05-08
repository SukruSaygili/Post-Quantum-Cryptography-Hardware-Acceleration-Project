--------------------------------------------------------------------------------
-- Module Name:     ex_mem - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Ex-Mem pipeline register, which holds the outputs of the EX 
--                  stage and passes them to the MEM stage.
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author     Comments
-- v0.1         10.11.2024   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;


entity ex_mem is
    Port (
        --INPUTS
        clk                 : in STD_LOGIC;
        rst                 : in STD_LOGIC;
        enable              : in STD_LOGIC;
        flush               : in STD_LOGIC;

        -- Data
        result_EX_IN        : in STD_LOGIC_VECTOR (31 downto 0);
        dataIn_EX_IN        : in STD_LOGIC_VECTOR (31 downto 0); 
        product_EX_IN       : in STD_LOGIC_VECTOR (63 downto 0); 
        PC_EX_IN            : in STD_LOGIC_VECTOR (31 downto 0);
        PC4_EX_IN           : in STD_LOGIC_VECTOR (31 downto 0);

        -- Addresses of data
        instrRD_EX_IN       : in STD_LOGIC_VECTOR (4 downto 0);

        instrRS2_EX_IN      : in STD_LOGIC_VECTOR (4 downto 0);

        -- Mem
        MemWrite_EX_IN      : in STD_LOGIC;
        StoreSel_EX_IN      : in STD_LOGIC_VECTOR (1 downto 0);
        MemRead_EX_IN       : in STD_LOGIC;

        -- WB
        MemtoReg_EX_IN      : in STD_LOGIC_VECTOR (2 downto 0);
        RegWrite_EX_IN      : in STD_LOGIC;
        LoadSel_EX_IN       : in STD_LOGIC_VECTOR (1 downto 0);

        --OUTPUTS
        -- Data
        result_MEM_OUT      : out STD_LOGIC_VECTOR (31 downto 0);
        dataIn_MEM_OUT      : out STD_LOGIC_VECTOR (31 downto 0); 
        product_MEM_OUT     : out STD_LOGIC_VECTOR (63 downto 0);
        PC_MEM_OUT          : out STD_LOGIC_VECTOR (31 downto 0);
        PC4_MEM_OUT         : out STD_LOGIC_VECTOR (31 downto 0);

        -- Addresses of data
        instrRD_MEM_OUT     : out STD_LOGIC_VECTOR (4 downto 0);
        
        instrRS2_MEM_OUT    : out STD_LOGIC_VECTOR (4 downto 0);
        
        -- Mem
        MemWrite_MEM_OUT    : out STD_LOGIC;
        StoreSel_MEM_OUT    : out STD_LOGIC_VECTOR (1 downto 0);
        MemRead_MEM_OUT     : out STD_LOGIC;

        -- WB
        MemtoReg_MEM_OUT    : out STD_LOGIC_VECTOR (2 downto 0);
        RegWrite_MEM_OUT    : out STD_LOGIC;
        LoadSel_MEM_OUT     : out STD_LOGIC_VECTOR (1 downto 0)
    );
end entity ex_mem;

architecture Behavioral of ex_mem is
    
        -- (DE-)LOCALISING IN/OUTPUTS
        signal PC_MEM_REG           : STD_LOGIC_VECTOR(31 downto 0);
        signal PC4_MEM_REG          : STD_LOGIC_VECTOR(31 downto 0);
        signal result_MEM_REG       : STD_LOGIC_VECTOR(31 downto 0);
        signal dataIn_MEM_REG       : STD_LOGIC_VECTOR(31 downto 0);
        signal product_MEM_REG      : STD_LOGIC_VECTOR(63 downto 0);
        signal instrRD_MEM_REG      : STD_LOGIC_VECTOR(4 downto 0);
        signal MemWrite_MEM_REG     : STD_LOGIC;
        signal MemRead_MEM_REG      : STD_LOGIC;
        signal StoreSel_MEM_REG     : STD_LOGIC_VECTOR (1 downto 0);
        signal MemtoReg_MEM_REG     : STD_LOGIC_VECTOR(2 downto 0);
        signal RegWrite_MEM_REG     : STD_LOGIC;
        signal LoadSel_MEM_REG      : STD_LOGIC_VECTOR(1 downto 0);
        signal instrRS2_MEM_REG     : STD_LOGIC_VECTOR(4 downto 0);

begin

    --------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    --------------------------------
    PC_MEM_OUT          <= PC_MEM_REG;
    PC4_MEM_OUT         <= PC4_MEM_REG;
    result_MEM_OUT      <= result_MEM_REG;
    dataIn_MEM_OUT      <= dataIn_MEM_REG;
    product_MEM_OUT     <= product_MEM_REG;
    instrRD_MEM_OUT     <= instrRD_MEM_REG;
    MemWrite_MEM_OUT    <= MemWrite_MEM_REG;
    MemRead_MEM_OUT     <= MemRead_MEM_REG;
    StoreSel_MEM_OUT    <= StoreSel_MEM_REG;
    MemtoReg_MEM_OUT    <= MemtoReg_MEM_REG;
    RegWrite_MEM_OUT    <= RegWrite_MEM_REG;
    LoadSel_MEM_OUT     <= LoadSel_MEM_REG;
    instrRS2_MEM_OUT    <= instrRS2_MEM_REG;

    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    --------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                PC_MEM_REG          <=  (others => '0');
                PC4_MEM_REG         <=  (others => '0');
                result_MEM_REG      <=  (others => '0');  
                dataIn_MEM_REG      <=  (others => '0');
                product_MEM_REG     <=  (others => '0');
                instrRD_MEM_REG     <=  (others => '0');
                MemWrite_MEM_REG    <=  '0';
                MemRead_MEM_REG     <=  '0';
                StoreSel_MEM_REG    <=  (others => '0');
                MemtoReg_MEM_REG    <=  (others => '0');
                RegWrite_MEM_REG    <=  '0';
                LoadSel_MEM_REG     <=  (others => '0');
                instrRS2_MEM_REG    <=  (others => '0');

            elsif enable = '1' then
                if flush = '0' then 
                    PC_MEM_REG          <=  (others => '0');
                    PC4_MEM_REG         <=  (others => '0');
                    result_MEM_REG      <=  (others => '0');  
                    dataIn_MEM_REG      <=  (others => '0');
                    product_MEM_REG     <=  (others => '0');
                    instrRD_MEM_REG     <=  (others => '0');
                    MemWrite_MEM_REG    <=  '0';
                    MemRead_MEM_REG     <=  '0';
                    StoreSel_MEM_REG    <=  (others => '0');
                    MemtoReg_MEM_REG    <=  (others => '0');
                    RegWrite_MEM_REG    <=  '0';
                    LoadSel_MEM_REG     <=  (others => '0');
                    instrRS2_MEM_REG    <=  (others => '0');
                else 
                    PC_MEM_REG          <=  PC_EX_IN;
                    PC4_MEM_REG         <=  PC4_EX_IN;
                    result_MEM_REG      <=  result_EX_IN;
                    dataIn_MEM_REG      <=  dataIn_EX_IN;
                    product_MEM_REG     <=  product_EX_IN;
                    instrRD_MEM_REG     <=  instrRD_EX_IN;
                    MemWrite_MEM_REG    <=  MemWrite_EX_IN;
                    MemRead_MEM_REG     <=  MemRead_EX_IN;
                    StoreSel_MEM_REG    <=  StoreSel_EX_IN;
                    MemtoReg_MEM_REG    <=  MemtoReg_EX_IN;
                    RegWrite_MEM_REG    <=  RegWrite_EX_IN;
                    LoadSel_MEM_REG     <=  LoadSel_EX_IN;
                    instrRS2_MEM_REG    <= instrRS2_EX_IN;
                end if;
            end if;
        end if;
    end process;

end architecture Behavioral;