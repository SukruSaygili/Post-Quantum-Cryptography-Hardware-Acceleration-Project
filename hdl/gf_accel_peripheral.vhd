--------------------------------------------------------------------------------
-- Module Name:     gf_accel_peripheral - Behavioral
-- Project Name:    Hardware-software co-design of HQC-KEM for all security 
--                  levels using an application-specific RISC-V processor 
--                  (Master's thesis)
-- Description:     Wrapper module for the gf-accelerator
--
-- Revision     Date         Author     Comments
-- v0.1         24.04.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity gf_accel_peripheral is
    port (
        clk   : in STD_LOGIC;
        rst   : in STD_LOGIC;
        sel   : in STD_LOGIC;
        we    : in STD_LOGIC;
        re    : in STD_LOGIC;
        addr  : in STD_LOGIC_VECTOR(31 downto 0);
        wdata : in STD_LOGIC_VECTOR(31 downto 0);
        rdata : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity gf_accel_peripheral;

architecture Behavioral of gf_accel_peripheral is

    -- COMPONENT DECLARATIONS
    component addshift is
        generic (
            N : INTEGER := 8
        );
        port (
            multiplier   : in  UNSIGNED(N-1 downto 0);
            multiplicand : in  UNSIGNED(N-1 downto 0);
            product      : out UNSIGNED(2*N-1 downto 0)
        );
    end component;

    component gf_square is
        port (
            a  : in  UNSIGNED(7 downto 0);
            s  : out UNSIGNED(15 downto 0)
        );
    end component;

    component gf_reduce_core is
        port (
            x      : in  UNSIGNED(63 downto 0);
            result : out UNSIGNED(15 downto 0)
        );
    end component;

    -- INTERNAL SIGNALS
    -- State Machine Definition
    type state_type is (IDLE, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11);
    signal state : state_type;
    
    -- Registers (Software mapped)
    signal a_reg_lo  : UNSIGNED(31 downto 0); 
    signal b_reg     : UNSIGNED(31 downto 0);
    signal mode_reg  : STD_LOGIC_VECTOR(1 downto 0);
    signal a_reg_hi  : UNSIGNED(31 downto 0); 
    signal ctrl_reg  : STD_LOGIC;
    
    -- Internal FSM registers for the inverse calculation
    signal reg_a_orig : UNSIGNED(15 downto 0);
    signal reg_inv    : UNSIGNED(15 downto 0);
    signal reg_tmp1   : UNSIGNED(15 downto 0);
    signal reg_tmp2   : UNSIGNED(15 downto 0);
    signal latched_result : UNSIGNED(15 downto 0);

    -- Multiplexer output signals
    signal eff_mode  : STD_LOGIC_VECTOR(1 downto 0);
    signal eff_sq_a  : UNSIGNED(7 downto 0);
    signal eff_mul_a : UNSIGNED(7 downto 0);
    signal eff_mul_b : UNSIGNED(7 downto 0);

    -- Internal combinatorial signals
    signal mul_out        : UNSIGNED(15 downto 0);
    signal square_out     : UNSIGNED(15 downto 0);
    signal reduce_in      : UNSIGNED(63 downto 0);
    signal comb_final_res : UNSIGNED(15 downto 0);

begin
    -------------------------------------------------------------------------------
    -- COMPONENTS MAPPING
    -------------------------------------------------------------------------------
    mul_inst: addshift
        generic map ( N => 8 )
        port map (
            multiplier   => eff_mul_a,
            multiplicand => eff_mul_b,
            product      => mul_out
        );

    sq_inst: gf_square
        port map (
            a => eff_sq_a,
            s => square_out
        );

    red_inst: gf_reduce_core
        port map (
            x      => reduce_in,
            result => comb_final_res
        );
        
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    -- Determines whether the combinational blocks are fed by the bus registers (for regular operations) or the FSM (for Inverse).
    comb_routing: process(state, mode_reg, a_reg_lo, b_reg, reg_inv, reg_tmp1, reg_tmp2, reg_a_orig)
    begin
        -- Default (IDLE)
        eff_mode  <= mode_reg;
        eff_sq_a  <= a_reg_lo(7 downto 0);
        eff_mul_a <= a_reg_lo(7 downto 0);
        eff_mul_b <= b_reg(7 downto 0);

        -- FSM overrides the bus-inputs during inverse
        case state is
            when S1 => -- sq(a)
                eff_mode <= "01";
                eff_sq_a <= reg_a_orig(7 downto 0);
            when S2 => -- mul(inv, a)
                eff_mode  <= "00";
                eff_mul_a <= reg_inv(7 downto 0);
                eff_mul_b <= reg_a_orig(7 downto 0);
            when S3 => -- sq(inv)
                eff_mode <= "01";
                eff_sq_a <= reg_inv(7 downto 0);
            when S4 => -- mul(inv, tmp1)
                eff_mode  <= "00";
                eff_mul_a <= reg_inv(7 downto 0);
                eff_mul_b <= reg_tmp1(7 downto 0);
            when S5 => -- mul(inv, tmp2)
                eff_mode  <= "00";
                eff_mul_a <= reg_inv(7 downto 0);
                eff_mul_b <= reg_tmp2(7 downto 0);
            when S6 => -- mul(tmp1, inv)
                eff_mode  <= "00";
                eff_mul_a <= reg_tmp1(7 downto 0);
                eff_mul_b <= reg_inv(7 downto 0);
            when S7 | S8 | S9 | S11 => -- sq(inv)
                eff_mode <= "01";
                eff_sq_a <= reg_inv(7 downto 0);
            when S10 => -- mul(inv, tmp2)
                eff_mode  <= "00";
                eff_mul_a <= reg_inv(7 downto 0);
                eff_mul_b <= reg_tmp2(7 downto 0);
            when others => null;
        end case;
    end process;

    input_reducer: process(eff_mode, mul_out, square_out, a_reg_lo, a_reg_hi)
    begin
        case eff_mode is
            when "00" => -- MUL_REDUCE
                reduce_in <= (others => '0');
                reduce_in(15 downto 0) <= mul_out;
            when "01" => -- SQUARE_REDUCE
                reduce_in <= (others => '0');
                reduce_in(15 downto 0) <= square_out;
            when "10" => -- REDUCE_ONLY (64-bit mode)
                reduce_in <= a_reg_hi & a_reg_lo;
            when others =>
                reduce_in <= (others => '0');
        end case;
    end process;

    seq_proc_FSM: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                state <= IDLE;
                a_reg_lo  <= (others => '0');
                a_reg_hi  <= (others => '0');
                b_reg     <= (others => '0');
                mode_reg  <= (others => '0');
                ctrl_reg  <= '0';
                latched_result <= (others => '0');
            else
                -- FSM & Hardware Execution
                case state is
                    when IDLE =>
                        if ctrl_reg = '1' then
                            if mode_reg = "11" then 
                                -- start inverse
                                state <= S1;
                                reg_a_orig <= a_reg_lo(15 downto 0);
                            else
                                -- combinational mode
                                latched_result <= comb_final_res;
                                ctrl_reg <= '0'; -- auto clear
                            end if;
                        end if;

                    when S1 =>
                        reg_inv <= comb_final_res;
                        state <= S2;
                    when S2 =>
                        reg_tmp1 <= comb_final_res;
                        state <= S3;
                    when S3 =>
                        reg_inv <= comb_final_res;
                        state <= S4;
                    when S4 =>
                        reg_tmp2 <= comb_final_res;
                        state <= S5;
                    when S5 =>
                        reg_tmp1 <= comb_final_res;
                        state <= S6;
                    when S6 =>
                        reg_inv <= comb_final_res;
                        state <= S7;
                    when S7 =>
                        reg_inv <= comb_final_res;
                        state <= S8;
                    when S8 =>
                        reg_inv <= comb_final_res;
                        state <= S9;
                    when S9 =>
                        reg_inv <= comb_final_res;
                        state <= S10;
                    when S10 =>
                        reg_inv <= comb_final_res;
                        state <= S11;
                    when S11 =>
                        latched_result <= comb_final_res;
                        ctrl_reg <= '0'; -- auto clear
                        state <= IDLE;
                end case;

                -- Bus write override
                if sel = '1' and we = '1' then
                    case addr(4 downto 2) is
                        when "000" => a_reg_lo <= UNSIGNED(wdata);        -- 0x00
                        when "001" => a_reg_hi <= UNSIGNED(wdata);        -- 0x04
                        when "010" => b_reg    <= UNSIGNED(wdata);        -- 0x08
                        when "011" => mode_reg <= wdata(1 downto 0);      -- 0x0C
                        when "100" => ctrl_reg <= wdata(0);               -- 0x10
                        when others => null;
                    end case;
                end if;
            end if;
        end if;
    end process;

    read_decoder: process(sel, re, addr, a_reg_lo, a_reg_hi, b_reg, mode_reg, ctrl_reg, latched_result)
    begin
        rdata <= (others => '0'); 
        if sel = '1' and re = '1' then
            case addr(4 downto 2) is
                when "100" => rdata(0) <= ctrl_reg;                                     -- 0x10
                when "101" => rdata(15 downto 0) <= STD_LOGIC_VECTOR(latched_result);   -- 0x14
                when others => null;
            end case;
        end if;
    end process;

end architecture Behavioral;
