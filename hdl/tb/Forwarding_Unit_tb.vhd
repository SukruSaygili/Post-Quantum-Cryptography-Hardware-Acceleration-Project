--------------------------------------------------------------------------------
-- Module Name:     Forwarding_Unit_tb - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Testbench for the Forwarding_Unit
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author    Comments
-- v0.1         20.11.2024   SaSu      Initial version
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity Forwarding_Unit_tb is
    -- No ports for the testbench
end entity Forwarding_Unit_tb;

architecture tb of Forwarding_Unit_tb is
    -- Component declaration for the forwarding unit
    component Forwarding_Unit is
        port (
            instrRS1_EX_IN          : in STD_LOGIC_VECTOR (4 downto 0);
            instrRS2_EX_IN          : in STD_LOGIC_VECTOR (4 downto 0);
            instrRD_MEM_IN          : in STD_LOGIC_VECTOR (4 downto 0);
            instrRD_WB_IN           : in STD_LOGIC_VECTOR (4 downto 0);
            RegWrite_MEM_IN         : in STD_LOGIC;
            RegWrite_WB_IN          : in STD_LOGIC;
            forwardOp1_OUT          : out STD_LOGIC_VECTOR (1 downto 0);
            forwardOp2_OUT          : out STD_LOGIC_VECTOR (1 downto 0);
            forwardDataOutOfMem_OUT : out STD_LOGIC
        );
    end component;

    -- Testbench signals to drive the inputs and capture outputs
    signal instrRS1_EX_IN      : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal instrRS2_EX_IN      : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal instrRD_MEM_IN      : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal instrRD_WB_IN       : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal RegWrite_MEM_IN     : STD_LOGIC := '0';
    signal RegWrite_WB_IN      : STD_LOGIC := '0';
    signal forwardOp1_OUT          : STD_LOGIC_VECTOR(1 downto 0);
    signal forwardOp2_OUT          : STD_LOGIC_VECTOR(1 downto 0);
    signal forwardDataOutOfMem_OUT : STD_LOGIC;

begin
    -- Instantiate the Forwarding Unit
    DUT: Forwarding_Unit
        port map (
            instrRS1_EX_IN => instrRS1_EX_IN,
            instrRS2_EX_IN => instrRS2_EX_IN,
            instrRD_MEM_IN => instrRD_MEM_IN,
            instrRD_WB_IN => instrRD_WB_IN,
            RegWrite_MEM_IN => RegWrite_MEM_IN,
            RegWrite_WB_IN => RegWrite_WB_IN,
            forwardOp1_OUT => forwardOp1_OUT,
            forwardOp2_OUT => forwardOp2_OUT,
            forwardDataOutOfMem_OUT => forwardDataOutOfMem_OUT
        );

    -- Stimulus process to test the Forwarding Unit
    stim_proc: process
    begin
        -- Test Case 1: No forwarding
        instrRS1_EX_IN <= "00001";
        instrRS2_EX_IN <= "00010";
        instrRD_MEM_IN <= "00011";
        instrRD_WB_IN <= "00100";
        RegWrite_MEM_IN <= '0';
        RegWrite_WB_IN <= '0';
        wait for 10 ns;
        assert (forwardOp1_OUT = "00" and forwardOp2_OUT = "00" and forwardDataOutOfMem_OUT = '0')
        report "Test Case 1 Failed: No forwarding should occur" severity error;

        -- Test Case 2: Forward from MEM stage for RS1
        instrRS1_EX_IN <= "00011"; -- RS1 matches RD_MEM
        RegWrite_MEM_IN <= '1';   -- MEM stage is writing
        wait for 10 ns;
        assert (forwardOp1_OUT = "10")
        report "Test Case 2 Failed: Forwarding from MEM stage for RS1 not detected" severity error;

        -- Test Case 3: Forward from WB stage for RS2
        instrRS2_EX_IN <= "00100"; -- RS2 matches RD_WB
        RegWrite_MEM_IN <= '0';    -- MEM stage is not writing
        RegWrite_WB_IN <= '1';     -- WB stage is writing
        wait for 10 ns;
        assert (forwardOp2_OUT = "01")
        report "Test Case 3 Failed: Forwarding from WB stage for RS2 not detected" severity error;

        -- Test Case 4: Conflict resolution: MEM stage takes priority over WB for RS1
        instrRS1_EX_IN <= "00011"; -- RS1 matches RD_MEM
        instrRD_WB_IN <= "00011";  -- WB also writes to same register
        RegWrite_MEM_IN <= '1';    -- MEM is writing
        RegWrite_WB_IN <= '1';     -- WB is writing
        wait for 10 ns;
        assert (forwardOp1_OUT = "10")
        report "Test Case 4 Failed: MEM stage should take priority over WB for RS1" severity error;

        -- Test Case 5: Data forwarding from MEM (forwardDataOutOfMem_OUT)
        instrRS1_EX_IN <= "11111"; -- Dummy RS1
        instrRD_MEM_IN <= "11111"; -- Matches RS1
        RegWrite_MEM_IN <= '1';    -- MEM is writing
        RegWrite_WB_IN <= '0';
        wait for 10 ns;
        assert (forwardDataOutOfMem_OUT = '1')
        report "Test Case 5 Failed: Data forwarding from MEM stage not detected" severity error;

        -- Test Case 6: No forwarding needed (default outputs)
        instrRS1_EX_IN <= "11101";
        instrRS2_EX_IN <= "11110";
        instrRD_MEM_IN <= "00000"; -- MEM stage not writing
        instrRD_WB_IN <= "00000"; -- WB stage not writing
        RegWrite_MEM_IN <= '0';
        RegWrite_WB_IN <= '0';
        wait for 10 ns;
        assert (forwardOp1_OUT = "00" and forwardOp2_OUT = "00" and forwardDataOutOfMem_OUT = '0')
        report "Test Case 6 Failed: Default values not correctly output when no forwarding" severity error;

        -- End of test
        report "All test cases passed successfully!" severity note;
        wait;
    end process;
end architecture tb;