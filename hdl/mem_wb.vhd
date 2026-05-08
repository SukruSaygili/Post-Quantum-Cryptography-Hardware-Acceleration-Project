--------------------------------------------------------------------------------
-- Module Name:     mem_wb - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Mem_Wb pipeline register, which holds the outputs of the MEM 
--                  stage and passes them to the WB stage.
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author     Comments
-- v0.1         10.11.2024   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity mem_wb is
    port (
        -- INPUTS
        clk              : in  STD_LOGIC;
        rst              : in  STD_LOGIC;
        enable           : in  STD_LOGIC;
        flush            : in  STD_LOGIC;

        -- Data
        dataOut_MEM_IN   : in  STD_LOGIC_VECTOR(31 downto 0);
        result_MEM_IN    : in  STD_LOGIC_VECTOR(31 downto 0);
        product_MEM_IN   : in  STD_LOGIC_VECTOR(63 downto 0);

        PC_MEM_IN        : in  STD_LOGIC_VECTOR(31 downto 0);
        PC4_MEM_IN       : in  STD_LOGIC_VECTOR(31 downto 0);

        -- Addresses
        instrRD_MEM_IN   : in  STD_LOGIC_VECTOR(4 downto 0);

        -- Wb control signals
        MemtoReg_MEM_IN  : in  STD_LOGIC_VECTOR(2 downto 0);
        RegWrite_MEM_IN  : in  STD_LOGIC;
        LoadSel_MEM_IN   : in  STD_LOGIC_VECTOR(1 downto 0);


        -- OUTPUTS
        -- Data
        dataOut_WB_OUT   : out STD_LOGIC_VECTOR(31 downto 0);
        result_WB_OUT    : out STD_LOGIC_VECTOR(31 downto 0);
        product_WB_OUT   : out STD_LOGIC_VECTOR(63 downto 0);

        PC_WB_OUT        : out STD_LOGIC_VECTOR(31 downto 0);
        PC4_WB_OUT       : out STD_LOGIC_VECTOR(31 downto 0);

        -- Addresses
        instrRD_WB_OUT   : out STD_LOGIC_VECTOR(4 downto 0);

        -- Wb control signals
        MemtoReg_WB_OUT  : out STD_LOGIC_VECTOR(2 downto 0);
        RegWrite_WB_OUT  : out STD_LOGIC;
        LoadSel_WB_OUT   : out STD_LOGIC_VECTOR(1 downto 0)
    );
end entity mem_wb;

architecture Behavioral of mem_wb is
    -- (DE-)LOCALISING IN/OUTPUTS
    signal dataOut_WB_REG  : STD_LOGIC_VECTOR(31 downto 0);
    signal result_WB_REG   : STD_LOGIC_VECTOR(31 downto 0);
    signal product_WB_REG  : STD_LOGIC_VECTOR(63 downto 0);
    signal instrRD_WB_REG  : STD_LOGIC_VECTOR(4 downto 0);
    signal MemtoReg_WB_REG : STD_LOGIC_VECTOR(2 downto 0);
    signal RegWrite_WB_REG : STD_LOGIC;
    signal LoadSel_WB_REG  : STD_LOGIC_VECTOR(1 downto 0);
    signal PC_WB_REG       : STD_LOGIC_VECTOR(31 downto 0);
    signal PC4_WB_REG      : STD_LOGIC_VECTOR(31 downto 0);

begin
    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    dataOut_WB_OUT  <= dataOut_WB_REG;
    result_WB_OUT   <= result_WB_REG;
    product_WB_OUT  <= product_WB_REG;
    instrRD_WB_OUT  <= instrRD_WB_REG;
    MemtoReg_WB_OUT <= MemtoReg_WB_REG;
    RegWrite_WB_OUT <= RegWrite_WB_REG;
    LoadSel_WB_OUT <= LoadSel_WB_REG;
    PC_WB_OUT       <= PC_WB_REG;
    PC4_WB_OUT      <= PC4_WB_REG;

    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                dataOut_WB_REG  <= (others => '0');
                result_WB_REG   <= (others => '0');
                product_WB_REG  <= (others => '0');
                instrRD_WB_REG  <= (others => '0');
                MemtoReg_WB_REG <= (others => '0');
                RegWrite_WB_REG <= '0';
                LoadSel_WB_REG  <= (others => '0');
                PC_WB_REG       <= (others => '0');
                PC4_WB_REG      <= (others => '0');

            elsif enable = '1' then
                if flush = '0' then
                    dataOut_WB_REG  <= (others => '0');
                    result_WB_REG   <= (others => '0');
                    product_WB_REG  <= (others => '0');
                    instrRD_WB_REG  <= (others => '0');
                    MemtoReg_WB_REG <= (others => '0');
                    RegWrite_WB_REG <= '0';
                    LoadSel_WB_REG  <= (others => '0');
                    PC_WB_REG       <= (others => '0');
                    PC4_WB_REG      <= (others => '0');
                else
                    dataOut_WB_REG  <= dataOut_MEM_IN;
                    result_WB_REG   <= result_MEM_IN;
                    product_WB_REG  <= product_MEM_IN;
                    instrRD_WB_REG  <= instrRD_MEM_IN;
                    MemtoReg_WB_REG <= MemtoReg_MEM_IN;
                    RegWrite_WB_REG <= RegWrite_MEM_IN;
                    LoadSel_WB_REG  <= LoadSel_MEM_IN;
                    PC_WB_REG       <= PC_MEM_IN;
                    PC4_WB_REG      <= PC4_MEM_IN;
                end if;
            end if;
        end if;
    end process;

end architecture Behavioral;