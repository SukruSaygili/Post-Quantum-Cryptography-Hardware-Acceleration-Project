--------------------------------------------------------------------------------
-- Module Name:     Forwarding_Unit - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Forwarding unit for the EX stage of the pipeline, which 
--                  detects data hazards and generates control signals for forwarding 
--                  data from the MEM and WB stages to the EX stage.
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author     Comments
-- v0.1         20.11.2024   SaSu       Initial version
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Forwarding_Unit is
    port (
        --INPUTS
        -- Addresses of data
        instrRS1_EX_IN          : in STD_LOGIC_VECTOR (4 downto 0);
        instrRS2_EX_IN          : in STD_LOGIC_VECTOR (4 downto 0);
        instrRD_MEM_IN          : in STD_LOGIC_VECTOR (4 downto 0);     -- address of Rd from mem-stage
        instrRD_WB_IN           : in STD_LOGIC_VECTOR (4 downto 0);     -- address of Rd from writeback-stage

        instrRS2_MEM_IN          : in STD_LOGIC_VECTOR (4 downto 0);

        -- Control signals
        RegWrite_MEM_IN         : in STD_LOGIC;                         -- RegWrite signal from mem-stage
        RegWrite_WB_IN          : in STD_LOGIC;                         -- RegWrite signal from writeback-stage
        toRegister_MEM_IN       : in STD_LOGIC_VECTOR (2 downto 0);     -- toRegister signal from mem-stage

        MemWrite_MEM_IN         : in STD_LOGIC;


        --OUTPUTS
        forwardOp1_OUT          : out STD_LOGIC_VECTOR (1 downto 0);
        forwardOp2_OUT          : out STD_LOGIC_VECTOR (1 downto 0);
        forwardDataWbToMem_OUT  : out STD_LOGIC;
        forwardDataWbToEx_OUT   : out STD_LOGIC
    );
end entity Forwarding_Unit;

architecture Behavioral of Forwarding_Unit is
    
begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process(instrRS1_EX_IN, instrRS2_EX_IN, instrRD_MEM_IN, instrRD_WB_IN, RegWrite_MEM_IN, RegWrite_WB_IN, toRegister_MEM_IN, MemWrite_MEM_IN, instrRS2_MEM_IN)
    begin
        -- Default values for forwarding operations
        forwardOp1_OUT <= "00";         -- No forwarding
        forwardOp2_OUT <= "00";         -- No forwarding
        forwardDataWbToMem_OUT <= '0';  -- Default
        forwardDataWbToEx_OUT <= '0';   -- Default

        -- Forwarding for RS1 (input 1)
        if (RegWrite_MEM_IN = '1' and instrRD_MEM_IN /= "00000" and instrRD_MEM_IN = instrRS1_EX_IN) then   -- EX-HAZARD (type 1a)

            if(toRegister_MEM_IN = "110" or toRegister_MEM_IN = "111") then     
                forwardOp1_OUT <= "11"; -- If the previous instruction was a mul or mulh, forward product from EX/MEM
            else
                forwardOp1_OUT <= "10"; -- Forward from EX/MEM pipeline register(product or ALU result? => MuxReg decides it)
            end if;

        elsif (RegWrite_WB_IN = '1'                                                                         -- MEM-HAZARD (type 2a)                                          
            and instrRD_WB_IN /= "00000" 
            and not(RegWrite_MEM_IN = '1' and instrRD_MEM_IN /= "00000" 
                    and instrRD_MEM_IN = instrRS1_EX_IN) 
            and instrRD_WB_IN = instrRS1_EX_IN) then
            forwardOp1_OUT <= "01"; -- Forward from MEM/WB pipeline register (MEM Hazard)
        end if;

        -- Forwarding for RS2 (input 2)
        if (RegWrite_MEM_IN = '1' and instrRD_MEM_IN /= "00000" and instrRD_MEM_IN = instrRS2_EX_IN) then   -- EX-HAZARD (type 1b)

            if(toRegister_MEM_IN = "110" or toRegister_MEM_IN = "111") then
                forwardOp2_OUT <= "11"; -- If the previous instruction was a mul or mulh, forward product from EX/MEM
            else
                forwardOp2_OUT <= "10"; -- Forward from EX/MEM pipeline register(product or ALU result? => MuxReg decides it)
            end if;

        elsif (RegWrite_WB_IN = '1'                                                                         -- MEM-HAZARD (type 2b)
            and instrRD_WB_IN /= "00000" 
            and not(RegWrite_MEM_IN = '1' and instrRD_MEM_IN /= "00000" 
                    and instrRD_MEM_IN = instrRS2_EX_IN) 
            and instrRD_WB_IN = instrRS2_EX_IN) then
            forwardOp2_OUT <= "01"; -- Forward from MEM/WB pipeline register
            forwardDataWbToEx_OUT <= '1'; -- Forward data from MEM/WB pipeline register for SW or SB, when the second previous instruction loads/stores that data to a register that is being used as source 2 in the current instruction in EX stage
        end if;

        -- Data from WB stage for forwarding SW or SB after LW, or add,... forwarding
        if (RegWrite_WB_IN = '1' and instrRD_WB_IN = instrRS2_MEM_IN and MemWrite_MEM_IN = '1') then
            forwardDataWbToMem_OUT <= '1';
        end if;

    end process;
    
end architecture Behavioral;