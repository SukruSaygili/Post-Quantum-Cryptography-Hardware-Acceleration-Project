--------------------------------------------------------------------------------
-- Module Name:     instr_control - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Selecting the instruction for the next stage (ID) of the pipeline, 
--                  which is either the current instruction or the previous one, 
--                  depending on the stall signal. The IMEM BRAM does not stall and 
--                  keeps fetching the next instruction, so we need to select the 
--                  previous instruction during a stall to avoid executing the next 
--                  instruction that has been fetched.
--
-- Revision     Date         Author     Comments
-- v0.1         11.03.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity instr_control is
    port (
        clk          : in  STD_LOGIC;
        rst          : in  STD_LOGIC;
        stall        : in  STD_LOGIC;
        instr_sel    : out STD_LOGIC
    );
end entity instr_control;

architecture Behavioral of instr_control is
    -- INTERNAL SIGNALS
    type state_type is (IDLE, PULSE_LOW);
    signal state      : state_type := IDLE;
    signal last_input : std_logic := '0';

begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then 
                state <= IDLE;
                last_input <= '0';
            else
                -- Store the previous value of stall to detect edges
                last_input <= stall;

                case state is
                    when IDLE =>
                        -- Detect falling edge and REACT ONE CLOCK_CYCLE LATER
                        if (stall = '0' and last_input = '1') then
                            state <= PULSE_LOW;
                        else
                            state <= IDLE;
                        end if;

                    when PULSE_LOW =>
                        -- Detect rising edge and REACT ONE CLOCK_CYCLE LATER,
                        -- otherwise stay at PULSE_LOW and keep selecting the previous instruction
                        -- since the IMEM BRAM does not stall and keeps fetching the next instruction.
                        if (stall = '1' and last_input = '0') then
                            state <= IDLE;
                        else
                            state <= PULSE_LOW;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Output logic: normally '1', goes '0' only during the PULSE_LOW state
    instr_sel <= '0' when state = PULSE_LOW else '1';

end architecture Behavioral;