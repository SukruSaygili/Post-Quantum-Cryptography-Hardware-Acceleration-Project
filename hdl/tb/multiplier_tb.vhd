--------------------------------------------------------------------------------
-- Module Name:     multiplier_tb - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Testbench for the multiplier
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author         Comments
-- v0.1         16.09.2024   VlJo-MyKr      Initial version
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-------------------------------------------------------------------------------

entity multiplier_tb is
end entity multiplier_tb;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- At this moment, 15/11/2024, signed (2's complement) multiplication can not be done
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

architecture arch_multiplier of multiplier_tb is

  -- component ports
  signal operator1 : std_logic_vector(31 downto 0) := (others => '0');
  signal operator2 : std_logic_vector(31 downto 0) := (others => '0');
  signal product   : std_logic_vector(63 downto 0);

  constant period  : time := 50 ns;

begin  -- architecture arch_multiplier

  -- component instantiation
  DUT: entity work.multiplier
    generic map(size => 32)
    port map (
      operator1 => operator1,
      operator2 => operator2,
      product   => product
    );

  -- waveform generation and automatic checking
  WaveGen_Proc: process
    -- Local variables for expected product (to verify results)
    variable expected_product : unsigned(63 downto 0);
    variable op1, op2         : unsigned(31 downto 0);
  begin    
    -- Test case 1: 3 * 2 = 6
    wait for period;
    operator1 <= X"00000003";
    operator2 <= X"00000002";
    wait for period;
    op1 := unsigned(operator1);
    op2 := unsigned(operator2);
    expected_product := op1 * op2;
    assert unsigned(product) = expected_product
      report "Test case 1 failed: 3 * 2" severity error;

    -- Test case 2: -4 * 5 = -20
    operator1 <= X"FFFFFFFC";  -- -4 in 2's complement
    operator2 <= X"00000005";
    wait for period;
    op1 := unsigned(operator1);
    op2 := unsigned(operator2);
    expected_product := op1 * op2;
    assert unsigned(product) = expected_product
      report "Test case 2 failed: -4 * 5" severity error;

    -- Test case 3: 7 * -3 = -21
    operator1 <= X"00000007";
    operator2 <= X"FFFFFFFD";  -- -3 in 2's complement
    wait for period;
    op1 := unsigned(operator1);
    op2 := unsigned(operator2);
    expected_product := op1 * op2;
    assert unsigned(product) = expected_product
      report "Test case 3 failed: 7 * -3" severity error;

    -- Test case 4: 0 * 10 = 0
    operator1 <= X"00000000";
    operator2 <= X"0000000A";
    wait for period;
    op1 := unsigned(operator1);
    op2 := unsigned(operator2);
    expected_product := op1 * op2;
    assert unsigned(product) = expected_product
      report "Test case 4 failed: 0 * 10" severity error;

    -- Test case 5: -8 * -8 = 64
    operator1 <= X"FFFFFFF8";  -- -8 in 2's complement
    operator2 <= X"FFFFFFF8";  -- -8 in 2's complement
    wait for period;
    op1 := unsigned(operator1);
    op2 := unsigned(operator2);
    expected_product := op1 * op2;
    assert unsigned(product) = expected_product
      report "Test case 5 failed: -8 * -8" severity error;

    -- End of test
    report "All test cases completed successfully." severity note;
    wait;
  end process WaveGen_Proc;

end architecture arch_multiplier;

-------------------------------------------------------------------------------

configuration multiplier_tb_arch_multiplier_cfg of multiplier_tb is
  for arch_multiplier
  end for;
end multiplier_tb_arch_multiplier_cfg;

-------------------------------------------------------------------------------
