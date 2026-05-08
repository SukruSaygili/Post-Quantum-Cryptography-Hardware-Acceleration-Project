--------------------------------------------------------------------------------
-- Module Name:     iterative_divider_32c - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Iterative divider for 32-bit signed and unsigned division 
--                  and remainder based on p. 185 of 
--                  D. A. . Patterson en J. L. . Hennessy, Computer organization 
--                  and design RISC-V edition : the hardware software interface, 
--                  Second. Morgan Kaufmann, 2020.
  
-- Revision     Date         Author     Comments
-- v0.1         09.03.2026   SaSu       Initial version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity iterative_divider_32c is
    port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        start       : in  STD_LOGIC;        -- Pulse high to start
        is_signed   : in  STD_LOGIC;        -- 1 for DIV/REM, 0 for DIVU/REMU
        operator1   : in  STD_LOGIC_VECTOR(31 downto 0); -- Dividend
        operator2   : in  STD_LOGIC_VECTOR(31 downto 0); -- Divisor
        quotient    : out STD_LOGIC_VECTOR(31 downto 0);
        remainder   : out STD_LOGIC_VECTOR(31 downto 0);
        busy        : out STD_LOGIC;        -- High while calculating
        done        : out STD_LOGIC         -- High for one cycle when finished
    );
end entity iterative_divider_32c;

architecture Behavioral of iterative_divider_32c is
    -- INTERNAL SIGNALS
    type state_type is (IDLE, PREPARE, CALCULATE, FINISH);
    signal state      : state_type := IDLE;
    
    signal count      : UNSIGNED(5 downto 0);
    signal reg_q      : UNSIGNED(31 downto 0); -- Quotient register
    signal reg_r      : UNSIGNED(31 downto 0); -- Remainder register
    signal reg_d      : UNSIGNED(31 downto 0); -- Divisor register
    
    signal sign_q     : STD_LOGIC;
    signal sign_r     : STD_LOGIC;
    
    -- Corner Cases
    signal div_by_zero : STD_LOGIC;
    signal overflow    : STD_LOGIC;

begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process(clk, rst)
        variable sub_temp : UNSIGNED(32 downto 0);
    begin
        if rst = '0' then
            state <= IDLE;
            busy <= '0';
            done <= '0';
            quotient <= (others => '0');
            remainder <= (others => '0');
            reg_q <= (others => '0');
            reg_r <= (others => '0');
            reg_d <= (others => '0');
            sign_q <= '0';
            sign_r <= '0';
            div_by_zero <= '0';
            overflow <= '0';
        elsif rising_edge(clk) then
            done <= '0';
            
            case state is
                when IDLE =>
                    if start = '1' then
                        busy <= '1';
                        -- Corner Cases
                        if UNSIGNED(operator2) = 0 then
                            div_by_zero <= '1';
                        else
                            div_by_zero <= '0';
                        end if;

                        if is_signed = '1' and operator1 = x"80000000" and operator2 = x"FFFFFFFF" then
                            overflow <= '1';
                        else
                            overflow <= '0';
                        end if;
                        
                        -- Determine signs for signed division
                        sign_q <= is_signed and (operator1(31) xor operator2(31));
                        sign_r <= is_signed and operator1(31);
                        
                        -- Prepare absolute values
                        if is_signed = '1' and operator1(31) = '1' then
                            reg_q <= UNSIGNED(-SIGNED(operator1));
                        else
                            reg_q <= UNSIGNED(operator1);
                        end if;
                        
                        if is_signed = '1' and operator2(31) = '1' then
                            reg_d <= UNSIGNED(-SIGNED(operator2));
                        else
                            reg_d <= UNSIGNED(operator2);
                        end if;
                        
                        reg_r <= (others => '0');
                        count <= to_unsigned(32, 6);
                        state <= PREPARE;
                    end if;

                when PREPARE =>
                    -- Handle RISC-V specific exceptions before starting loop
                    if div_by_zero = '1' then
                        quotient  <= (others => '1'); -- -1 in signed, max in unsigned
                        remainder <= operator1;
                        state     <= FINISH;
                    elsif overflow = '1' then
                        quotient  <= x"80000000";
                        remainder <= (others => '0');
                        state     <= FINISH;
                    else
                        state <= CALCULATE;
                    end if;

                when CALCULATE =>
                    -- Shift and Subtract Algorithm
                    -- sub_temp = (Remainder << 1 | next bit of Q) - Divisor
                    sub_temp := unsigned(('0' & reg_r(30 downto 0) & reg_q(31)) - ('0' & reg_d));
                    
                    if sub_temp(32) = '1' then -- Subtraction failed (negative)
                        reg_r <= reg_r(30 downto 0) & reg_q(31);
                        reg_q <= reg_q(30 downto 0) & '0';
                    else
                        reg_r <= sub_temp(31 downto 0);
                        reg_q <= reg_q(30 downto 0) & '1';
                    end if;

                    if count = 1 then
                        state <= FINISH;
                    else
                        count <= count - 1;
                    end if;

                when FINISH =>
                    -- Adjust signs for signed operations
                    if div_by_zero = '0' and overflow = '0' then
                        if sign_q = '1' then
                            quotient <= STD_LOGIC_VECTOR(-SIGNED(reg_q));
                        else
                            quotient <= STD_LOGIC_VECTOR(reg_q);
                        end if;

                        if sign_r = '1' then
                            remainder <= STD_LOGIC_VECTOR(-SIGNED(reg_r));
                        else
                            remainder <= STD_LOGIC_VECTOR(reg_r);
                        end if;
                    end if;
                    
                    busy  <= '0';
                    done  <= '1';
                    state <= IDLE;

            end case;
        end if;
    end process;

end architecture Behavioral;