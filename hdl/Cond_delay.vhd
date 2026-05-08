--------------------------------------------------------------------------------
-- Module Name:     Cond_delay - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Logic to generate a stall signal when a memory access 
--                  instruction is in the MEM stage
--
-- Revision     Date         Author     Comments
-- v0.1         09.03.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity Cond_delay is
    Port(
        clk             : in STD_LOGIC;
        rst             : in STD_LOGIC;
        enable          : in STD_LOGIC;
        memRead_MEM_IN  : in STD_LOGIC;

        stall_CD_OUT    : out STD_LOGIC
    );
end entity Cond_delay;

architecture Behavioral of Cond_delay is
    -- (DE-)LOCALISING IN/OUTPUTS
    signal mem_req_MEM : STD_LOGIC;
    -- INTERNAL SIGNALS
    type state_type is (IDLE, BUSY);
    signal stateMEM : state_type := IDLE;

begin
    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    mem_req_MEM <= memRead_MEM_IN; -- memWrite_MEM_IN or (no stall for memory writes)

    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    -- We stall if there's a memory request AND we aren't already 
    -- in the middle of a BRAM access cycle (BUSY).
    stall_CD_OUT <= '1' when (stateMEM = IDLE and mem_req_MEM='1' and enable = '1') else '0';

    process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                stateMEM <= IDLE;
            else 
                if enable = '1' then
                    case stateMEM is
                        when IDLE =>
                            if mem_req_MEM = '1' then
                                -- Start the stall immediately
                                -- and move to BUSY to ensure we only stall for one cycle.
                                stateMEM <= BUSY;
                            else
                                stateMEM <= IDLE;
                            end if;
                        when BUSY =>
                            -- After 1 cycle of stalling, we must release the stall 
                            -- even if the next instruction is also a memory op.
                            stateMEM <= IDLE;
                    end case;
                end if;
            end if;
        end if;
    end process;
    
end architecture Behavioral;