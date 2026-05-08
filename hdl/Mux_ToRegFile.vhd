--------------------------------------------------------------------------------
-- Module Name:     Mux_ToRegFile - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Mux_ToRegFile in WB stage for the RV32IM instruction set (modified)
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author               Comments
-- v0.2         16.09.2024   VlJo-MyKr-SaSu       Modified version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity Mux_ToRegFile is
    generic(
        busWidth    :integer := 32
    );
	port (
        muxIn0          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       -- register
        muxIn1          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       -- LB
        muxIn2          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       -- LW
        muxIn3          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       -- PC
        muxIn4          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       -- immediate
        muxIn5          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       -- PC+4
        muxIn6          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       -- mul
        muxIn7          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       -- mulh
        selector        :in STD_LOGIC_VECTOR(2 downto 0);                -- ToRegister
        loadSelector    :in STD_LOGIC_VECTOR(1 downto 0);                -- loadSel
        muxOut          :out STD_LOGIC_VECTOR(busWidth-1 downto 0)
	);
end entity Mux_ToRegFile;

architecture Behavioral of Mux_ToRegFile is
    -- INTERNALS SIGNALS
    signal selected : STD_LOGIC_VECTOR(busWidth-1 downto 0);
    
begin
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
    process( selector, loadSelector, muxIn0, muxIn1, muxIn2, muxIn3, muxIn4, muxIn5, muxIn6, muxIn7 )
        variable ext_byte : STD_LOGIC_VECTOR(7 downto 0);
        variable ext_hw   : STD_LOGIC_VECTOR(15 downto 0);
    begin
        ext_byte := (others => '0');
        ext_hw   := (others => '0');
        selected <= (others => '0');

        case selector is
            when "000" => selected <= muxIn0;
            when "001" => 

                --extract the correct byte based on the address(=muxIn0), because memory returns just the full word 
                case muxIn0(1 downto 0) is
                    when "00" => ext_byte := muxIn1(7 downto 0);
                    when "01" => ext_byte := muxIn1(15 downto 8);
                    when "10" => ext_byte := muxIn1(23 downto 16);
                    when "11" => ext_byte := muxIn1(31 downto 24);
                    when others => ext_byte := (others => '0');
                end case;
                --extract the correct halfword based on the address (=muxIn0), because memory returns just the full word 
                if muxIn0(1) = '0' then
                    ext_hw := muxIn1(15 downto 0);
                else
                    ext_hw := muxIn1(31 downto 16);
                end if;

                case loadSelector is
                    when "00" => selected <= (31 downto 8 => ext_byte(7)) & ext_byte; -- LB
                    when "01" => selected <= X"000000" & ext_byte; -- LBU
                    when "10" => selected <= (31 downto 16 => ext_hw(15)) & ext_hw; -- LH
                    when "11" => selected <= X"0000" & ext_hw; -- LHU
                    when others => selected <= (others => '0');
                end case;

            when "010" => selected <= muxIn2;   --LW
            when "011" => selected <= muxIn3;
            when "100" => selected <= muxIn4;
            when "101" => selected <= muxIn5;
            when "110" => selected <= muxIn6;
            when "111" => selected <= muxIn7;
            when others => selected <= (others =>'0');
        end case;
    end process ;
    
	muxOut <= selected;

end architecture Behavioral;