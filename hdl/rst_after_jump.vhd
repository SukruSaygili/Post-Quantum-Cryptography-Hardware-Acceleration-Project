--------------------------------------------------------------------------------
-- Module Name:     rst_after_jump - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Logic to generate a reset signal for one clock cycle after a 
--                  jump instruction, to ensure correct pipeline flushing and state 
--                  resetting in the processor.
--
-- Revision     Date         Author     Comments
-- v0.1         10.03.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity rst_after_jump is
    port (
        clk          : in  STD_LOGIC;
        rst          : in  STD_LOGIC;
        falsePredict : in  STD_LOGIC;
        flush        : out STD_LOGIC
    );
end entity rst_after_jump;

architecture Behavioral of rst_after_jump is
    -- INTERNAL SIGNALS
    type state_type is (IDLE, PULSE_LOW);
    signal state      : state_type := IDLE;
    signal last_input : STD_LOGIC := '0';

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
                last_input <= falsePredict;

                case state is
                    when IDLE =>
                        -- Detect falling edge: current is '0' and previous was '1'
                        if (falsePredict = '0' and last_input = '1') then
                            state <= PULSE_LOW;
                        else
                            state <= IDLE;
                        end if;

                    when PULSE_LOW =>
                        -- Stay here for exactly one clock cycle
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    -- Output logic: normally '1', goes '0' only during the PULSE_LOW state
    flush <= '0' when state = PULSE_LOW else '1';

end architecture Behavioral;