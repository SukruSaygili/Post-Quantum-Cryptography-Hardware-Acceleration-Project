--------------------------------------------------------------------------------
-- Module Name:     ALU_RV32 - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     ALU for the RV32IM instruction set (modified)
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author               Comments
-- v0.2         16.09.2024   VlJo-MyKr-SaSu       Modified version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;


entity ALU_RV32 is
    port (
        clk         :in STD_LOGIC;
        rst         :in STD_LOGIC;
        operator1   :in STD_LOGIC_VECTOR(31 downto 0);
        operator2   :in STD_LOGIC_VECTOR(31 downto 0);
        ALUOp       :in STD_LOGIC_VECTOR(4 downto 0);
        result      :out STD_LOGIC_VECTOR(31 downto 0);
        zero        :out STD_LOGIC;
        carryOut    :out STD_LOGIC;
        signo  		:out STD_LOGIC;
        divider_busy:out STD_LOGIC
    );
end entity ALU_RV32;

architecture Behavioral of ALU_RV32 is

    component iterative_divider_32c is
        port (
            clk         : in  STD_LOGIC;
            rst         : in  STD_LOGIC;
            start       : in  STD_LOGIC;        -- Pulse high to start
            is_SIGNED   : in  STD_LOGIC;        -- 1 for DIV/REM, 0 for DIVU/REMU
            operator1   : in  STD_LOGIC_VECTOR(31 downto 0); -- Dividend
            operator2   : in  STD_LOGIC_VECTOR(31 downto 0); -- Divisor
            quotient    : out STD_LOGIC_VECTOR(31 downto 0);
            remainder   : out STD_LOGIC_VECTOR(31 downto 0);
            busy        : out STD_LOGIC;        -- High while calculating
            done        : out STD_LOGIC         -- High for one cycle when finished
        );
    end component iterative_divider_32c;

    constant ALU_AND    : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    constant ALU_OR     : STD_LOGIC_VECTOR(4 downto 0) := "00001";
    constant ALU_XOR    : STD_LOGIC_VECTOR(4 downto 0) := "00010";
    constant ALU_SLT    : STD_LOGIC_VECTOR(4 downto 0) := "00011"; -- SLT or SLTI
    constant ALU_ADD    : STD_LOGIC_VECTOR(4 downto 0) := "00100";
    constant ALU_SUB    : STD_LOGIC_VECTOR(4 downto 0) := "00101";
    constant ALU_SLL    : STD_LOGIC_VECTOR(4 downto 0) := "00110"; -- SLL or SLI
    constant ALU_SRL    : STD_LOGIC_VECTOR(4 downto 0) := "00111";
    constant ALU_SRA    : STD_LOGIC_VECTOR(4 downto 0) := "01000"; -- SRA or SRAI
    constant ALU_SLTU   : STD_LOGIC_VECTOR(4 downto 0) := "01001"; -- SLTU or SLTIU
    constant ALU_FWD1   : STD_LOGIC_VECTOR(4 downto 0) := "01010";
    constant ALU_FWD2   : STD_LOGIC_VECTOR(4 downto 0) := "01011";
    constant ALU_MUL    : STD_LOGIC_VECTOR(4 downto 0) := "01100";
    constant ALU_MULH   : STD_LOGIC_VECTOR(4 downto 0) := "01101";
    constant ALU_MULHSU : STD_LOGIC_VECTOR(4 downto 0) := "01110";
    constant ALU_MULHU  : STD_LOGIC_VECTOR(4 downto 0) := "01111";
    constant ALU_DIV    : STD_LOGIC_VECTOR(4 downto 0) := "10000";
    constant ALU_DIVU   : STD_LOGIC_VECTOR(4 downto 0) := "10001";
    constant ALU_REM    : STD_LOGIC_VECTOR(4 downto 0) := "10010";
    constant ALU_REMU   : STD_LOGIC_VECTOR(4 downto 0) := "10011";
    
    signal aluResult        : STD_LOGIC_VECTOR(31 downto 0);
    signal temp_sign        : STD_LOGIC_VECTOR(31 downto 0); 
    signal temp_unsign      : STD_LOGIC_VECTOR(31 downto 0); 
    signal subtraction      : STD_LOGIC_VECTOR(32 downto 0);
    signal addition         : STD_LOGIC_VECTOR(32 downto 0);
    signal shiftNumb        : STD_LOGIC_VECTOR(4 downto 0);
	signal shift1l, shift2l, shift4l, shift8l, shift16l : STD_LOGIC_VECTOR(31 downto 0);
    signal shift1r, shift2r, shift4r, shift8r, shift16r : STD_LOGIC_VECTOR(31 downto 0);

    signal mul_ss : SIGNED(63 downto 0);   -- SIGNED x SIGNED
    signal mul_uu : UNSIGNED(63 downto 0); -- UNSIGNED x UNSIGNED
    signal mul_su : SIGNED(65 downto 0);   -- Mixed (extended to 33-bit each)

    signal divider_start, divider_busy_o, divider_SIGNED, divider_done : STD_LOGIC;
    signal divider_quotient, divider_remainder : STD_LOGIC_VECTOR(31 downto 0);

begin
    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------

    -------------------------------------------------------------------------------
    -- COMPONENTS MAPPING
    -------------------------------------------------------------------------------
    divider: iterative_divider_32c port map (clk => clk, rst => rst, start => divider_start, is_SIGNED => divider_SIGNED, 
        operator1 => operator1, operator2 => operator2, quotient => divider_quotient, remainder => divider_remainder, 
        busy => divider_busy_o, done => divider_done);

    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    divider_SIGNED <= '1' when (ALUOp = ALU_DIV or ALUOp = ALU_REM) else '0';

    divider_start <= '1' when ((ALUOp = ALU_DIV or ALUOp = ALU_DIVU or ALUOp = ALU_REM or ALUOp = ALU_REMU) 
                           and divider_busy_o = '0' and divider_done = '0') else '0';


    divider_busy <= '1' when ((ALUOp = ALU_DIV or ALUOp = ALU_DIVU or ALUOp = ALU_REM or ALUOp = ALU_REMU) 
                    and divider_done = '0') else '0';

    mul_ss <= SIGNED(operator1) * SIGNED(operator2);
    mul_uu <= UNSIGNED(operator1) * UNSIGNED(operator2);
    mul_su <= SIGNED(operator1(31) & operator1) * SIGNED('0' & operator2);

    process(operator1, operator2, ALUOp, addition, subtraction, shift16l, shift16r, temp_sign, temp_unsign, 
        mul_ss, mul_uu, mul_su, divider_quotient, divider_remainder)
    begin
        case(ALUOp) is
            when ALU_AND    => aluResult <= operator1 and operator2;
            when ALU_OR     => aluResult <= operator1 or operator2;
            when ALU_XOR    => aluResult <= operator1 xor operator2;  
            when ALU_SLT    => aluResult <= temp_sign;
            when ALU_SLTU   => aluResult <= temp_unsign;
            when ALU_ADD    => aluResult <= addition(31 downto 0);
            when ALU_SUB    => aluResult <= subtraction(31 downto 0);
            when ALU_SLL    => aluResult <= shift16l;
            when ALU_SRL    => aluResult <= shift16r;
            when ALU_SRA    => aluResult <= STD_LOGIC_VECTOR(shift_right(SIGNED(operator1),to_integer(UNSIGNED(operator2(4 downto 0)))));
            when ALU_FWD1   => aluResult <= operator1;  --no operation, forward op1  
            when ALU_FWD2   => aluResult <= operator2;  --no operation, forward op2  
            when ALU_MUL    => aluResult <= STD_LOGIC_VECTOR(mul_ss(31 downto 0));
            when ALU_MULH   => aluResult <= STD_LOGIC_VECTOR(mul_ss(63 downto 32));
            when ALU_MULHSU => aluResult <= STD_LOGIC_VECTOR(mul_su(63 downto 32));
            when ALU_MULHU  => aluResult <= STD_LOGIC_VECTOR(mul_uu(63 downto 32));
            when ALU_DIV    => aluResult <= divider_quotient;
            when ALU_DIVU   => aluResult <= divider_quotient;
            when ALU_REM    => aluResult <= divider_remainder;
            when ALU_REMU   => aluResult <= divider_remainder;
            when others     => aluResult <= (others => '0');
        end case ;       
    end process ;
    
    shiftNumb   <= operator2(4 downto 0);                                               --it can only be left shifted 32 bits                                                           --vector to put zeros in right
	shift1l  <= operator1(30 downto 0) & '0' when shiftNumb(0) = '1' else operator1;    --shift one or no shift
	shift2l  <= shift1l(29 downto 0) & "00" when shiftNumb(1) = '1' else shift1l;       --shift two, three or no shift
	shift4l  <= shift2l(27 downto 0) & x"0" when shiftNumb(2) = '1' else shift2l;       --shift four,five,six,seven or no shift
	shift8l  <= shift4l(23 downto 0) & x"00" when shiftNumb(3) = '1' else shift4l;      --shift 8 or 9 or ... or 15 or no shift
	shift16l <= shift8l(15 downto 0) & x"0000" when shiftNumb(4) = '1' else shift8l;    --shift 16,17,...,32 or no shift
 
	shift1r  <= '0' & operator1(31 downto 1) when shiftNumb(0) = '1' else operator1;
	shift2r  <= "00" & shift1r(31 downto 2) when shiftNumb(1) = '1' else shift1r;
	shift4r  <= x"0" & shift2r(31 downto 4) when shiftNumb(2) = '1' else shift2r;
	shift8r  <= x"00" & shift4r(31 downto 8)  when shiftNumb(3) = '1' else shift4r;
	shift16r <= x"0000" & shift8r(31 downto 16) when shiftNumb(4) = '1' else shift8r;

    addition    <= STD_LOGIC_VECTOR(UNSIGNED('0' & operator1) + UNSIGNED('0' & operator2)); --append 0 after MSB for carry out detection
    subtraction <= STD_LOGIC_VECTOR(UNSIGNED('0' & operator1) - UNSIGNED('0' & operator2)); --append 0 after MSB for carry out detection
    carryOut    <= addition(32) when ALUOp = ALU_ADD else subtraction(32);                  --the carry will be the MSB bit
    temp_sign   <= X"00000001" when SIGNED(operator1) < SIGNED(operator2) else X"00000000";  
    temp_unsign <= X"00000001" when UNSIGNED(operator1) < UNSIGNED(operator2) else X"00000000";  
    zero        <= '1' when aluResult = X"00000000" else '0';                               --zero flag indicates if the operation is equal to 0
    signo       <= aluResult(31);                                                           --the sign bit is the MSB of the result
    result      <= aluResult;

end architecture Behavioral;