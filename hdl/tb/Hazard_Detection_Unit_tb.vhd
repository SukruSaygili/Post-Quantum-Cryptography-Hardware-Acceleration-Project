--------------------------------------------------------------------------------
-- Module Name:     Hazard_Detection_Unit_tb - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Testbench for the Hazard_Detection_Unit
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author    Comments
-- v0.1         20.11.2024   SaSu      Initial version
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Hazard_Detection_Unit_tb is
end entity Hazard_Detection_Unit_tb;

architecture testbench of Hazard_Detection_Unit_tb is
    -- Component declaration
    component Hazard_Detection_Unit
        port (
            instrRS1_ID_IN      : in STD_LOGIC_VECTOR(4 downto 0);
            instrRS2_ID_IN      : in STD_LOGIC_VECTOR(4 downto 0);
            instrRD_EX_IN       : in STD_LOGIC_VECTOR(4 downto 0);
            MemRead_EX_IN       : in STD_LOGIC;
            noOpSelector_OUT    : out STD_LOGIC;
            PCWrite_OUT         : out STD_LOGIC;
            IFIDWriteEnable_OUT : out STD_LOGIC
        );
    end component;

    -- Signals
    signal instrRS1_ID_IN      : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal instrRS2_ID_IN      : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal instrRD_EX_IN       : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal MemRead_EX_IN       : STD_LOGIC := '0';
    signal noOpSelector_OUT    : STD_LOGIC;
    signal PCWrite_OUT         : STD_LOGIC;
    signal IFIDWriteEnable_OUT : STD_LOGIC;

    -- Expected outputs for automatic checking
    signal expected_noOpSelector_OUT    : STD_LOGIC := '0';
    signal expected_PCWrite_OUT         : STD_LOGIC := '1';
    signal expected_IFIDWriteEnable_OUT : STD_LOGIC := '1';

begin
    -- Instantiate the Hazard Detection Unit
    DUT: Hazard_Detection_Unit
        port map (
            instrRS1_ID_IN      => instrRS1_ID_IN,
            instrRS2_ID_IN      => instrRS2_ID_IN,
            instrRD_EX_IN       => instrRD_EX_IN,
            MemRead_EX_IN       => MemRead_EX_IN,
            noOpSelector_OUT    => noOpSelector_OUT,
            PCWrite_OUT         => PCWrite_OUT,
            IFIDWriteEnable_OUT => IFIDWriteEnable_OUT
        );

    -- Test process
    stimulus: process
    begin
        -- Test case 1: No hazard (MemRead = '0')
        instrRS1_ID_IN <= "00001";
        instrRS2_ID_IN <= "00010";
        instrRD_EX_IN  <= "00011";
        MemRead_EX_IN  <= '0';
        expected_noOpSelector_OUT <= '0';
        expected_PCWrite_OUT <= '1';
        expected_IFIDWriteEnable_OUT <= '1';
        wait for 10 ns;
        assert (noOpSelector_OUT = expected_noOpSelector_OUT and
                PCWrite_OUT = expected_PCWrite_OUT and
                IFIDWriteEnable_OUT = expected_IFIDWriteEnable_OUT)
            report "Test case 1 failed: No hazard signals incorrect" severity error;

        -- Test case 2: Hazard detected (instrRS1 matches instrRD_EX)
        instrRS1_ID_IN <= "00011"; -- Matches instrRD_EX
        instrRS2_ID_IN <= "00010";
        instrRD_EX_IN  <= "00011";
        MemRead_EX_IN  <= '1';
        expected_noOpSelector_OUT <= '1';
        expected_PCWrite_OUT <= '0';
        expected_IFIDWriteEnable_OUT <= '0';
        wait for 10 ns;
        assert (noOpSelector_OUT = expected_noOpSelector_OUT and
                PCWrite_OUT = expected_PCWrite_OUT and
                IFIDWriteEnable_OUT = expected_IFIDWriteEnable_OUT)
            report "Test case 2 failed: Hazard detection signals incorrect" severity error;

        -- Test case 3: Hazard detected (instrRS2 matches instrRD_EX)
        instrRS1_ID_IN <= "00001";
        instrRS2_ID_IN <= "00011"; -- Matches instrRD_EX
        instrRD_EX_IN  <= "00011";
        MemRead_EX_IN  <= '1';
        expected_noOpSelector_OUT <= '1';
        expected_PCWrite_OUT <= '0';
        expected_IFIDWriteEnable_OUT <= '0';
        wait for 10 ns;
        assert (noOpSelector_OUT = expected_noOpSelector_OUT and
                PCWrite_OUT = expected_PCWrite_OUT and
                IFIDWriteEnable_OUT = expected_IFIDWriteEnable_OUT)
            report "Test case 3 failed: Hazard detection signals incorrect" severity error;

        -- Test case 4: No hazard (instrRD_EX is zero)
        instrRS1_ID_IN <= "00011";
        instrRS2_ID_IN <= "00010";
        instrRD_EX_IN  <= "00000"; -- instrRD_EX is zero
        MemRead_EX_IN  <= '1';
        expected_noOpSelector_OUT <= '0';
        expected_PCWrite_OUT <= '1';
        expected_IFIDWriteEnable_OUT <= '1';
        wait for 10 ns;
        assert (noOpSelector_OUT = expected_noOpSelector_OUT and
                PCWrite_OUT = expected_PCWrite_OUT and
                IFIDWriteEnable_OUT = expected_IFIDWriteEnable_OUT)
            report "Test case 4 failed: No hazard signals incorrect" severity error;

        -- Test case 5: No hazard (MemRead = '0')
        instrRS1_ID_IN <= "00011";
        instrRS2_ID_IN <= "00010";
        instrRD_EX_IN  <= "00011";
        MemRead_EX_IN  <= '0';
        expected_noOpSelector_OUT <= '0';
        expected_PCWrite_OUT <= '1';
        expected_IFIDWriteEnable_OUT <= '1';
        wait for 10 ns;
        assert (noOpSelector_OUT = expected_noOpSelector_OUT and
                PCWrite_OUT = expected_PCWrite_OUT and
                IFIDWriteEnable_OUT = expected_IFIDWriteEnable_OUT)
            report "Test case 5 failed: No hazard signals incorrect" severity error;

        -- End simulation
        report "All test cases passed!" severity note;
        wait;
    end process;
end architecture testbench;
