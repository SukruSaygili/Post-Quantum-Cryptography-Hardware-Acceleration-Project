--------------------------------------------------------------------------------
-- Module Name:     Hazard_Detection_Unit - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Hazard unit for the ID stage of the pipeline, which 
--                  detects load-use hazards and generates control signals for 
--                  stalling the pipeline and inserting no-ops when necessary.
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author     Comments
-- v0.1         20.11.2024   SaSu       Initial version
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Hazard_Detection_Unit is
    port (
        --INPUTS
        -- Addresses of data
        instrRS1_ID_IN          : in STD_LOGIC_VECTOR (4 downto 0);
        instrRS2_ID_IN          : in STD_LOGIC_VECTOR (4 downto 0);
        instrRD_EX_IN           : in STD_LOGIC_VECTOR (4 downto 0);     -- address of Rd from ex-stage
        -- Control signal
        MemRead_EX_IN           : in STD_LOGIC;                         -- MemRead signal from ex-stage
        MemWrite_ID_IN          : in STD_LOGIC;

        --OUTPUTS
        -- selectors
        noOpSelector_OUT         : out STD_LOGIC;
        IF_ID_stage_enable_OUT   : out STD_LOGIC
    );
end entity Hazard_Detection_Unit;

architecture Behavioral of Hazard_Detection_Unit is
    
begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process(instrRS1_ID_IN, instrRS2_ID_IN, instrRD_EX_IN, MemRead_EX_IN, MemWrite_ID_IN )
    begin
        -- Default operations, no hazard detection (lw)
        noOpSelector_OUT    <= '0';     -- default, NO no-op
        IF_ID_stage_enable_OUT <= '1';     -- IF/ID register and PC update as usual


        if (MemRead_EX_IN = '1' and instrRD_EX_IN /= "00000" 
            and (instrRD_EX_IN = instrRS1_ID_IN or instrRD_EX_IN = instrRS2_ID_IN) and MemWrite_ID_IN /= '1') then
                noOpSelector_OUT    <= '1';
                IF_ID_stage_enable_OUT <= '0';
        end if;
    end process;
    
end architecture Behavioral;