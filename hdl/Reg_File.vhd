--------------------------------------------------------------------------------
-- Module Name:     Reg_File - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Register file for the RV32IM instruction set
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author          Comments
-- v0.1         16.09.2024   VlJo-MyKr       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Reg_File is
    port (
        clk         :in STD_LOGIC;
        writeReg    :in STD_LOGIC;                          --signal for write in register
        sourceReg1  :in STD_LOGIC_VECTOR(4 downto 0);       --address of rs1
        sourceReg2  :in STD_LOGIC_VECTOR(4 downto 0);       --address of rs2
        destinyReg  :in STD_LOGIC_VECTOR(4 downto 0);       --address of rd
        data        :in STD_LOGIC_VECTOR(31 downto 0);      --Data to be written
        readData1   :out STD_LOGIC_VECTOR(31 downto 0);     --data in rs1
        readData2   :out STD_LOGIC_VECTOR(31 downto 0)      --data in rs2
    );
end entity Reg_File;

architecture Behavioral of Reg_File is
    -- INTERNAL SIGNALS
    type Mem is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);    --Mem is an array of 32 registers of 32 bits
    signal registers : Mem := (others => (others => '0'));          --registers is a Mem
    
begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process( clk, writeReg, sourceReg1, sourceReg2, destinyReg, data, registers )   
    begin
        -- Write operation on the falling edge of the clock
        if falling_edge(clk) then
            if writeReg = '1' and destinyReg /= "00000" then    --check for write register and destiny diff from address zero
                registers(conv_integer(destinyReg)) <= data;
            end if;
        end if;

        -- Read operation on the rising edge of the clock
        if sourceReg1 /= "00000" then
            readData1 <= registers(conv_integer(sourceReg1));
        else
            readData1 <= (others => '0');
        end if;

        if sourceReg2 /= "00000" then
            readData2 <= registers(conv_integer(sourceReg2));
        else
            readData2 <= (others => '0');
        end if;
    end process;

end architecture Behavioral;