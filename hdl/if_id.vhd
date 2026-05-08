--------------------------------------------------------------------------------
-- Module Name:     ex_mem - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     If_Id pipeline register, which holds the outputs of the If 
--                  stage and passes them to the Id stage.
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author          Comments
-- v0.1         16.09.2024   VlJo-MyKr       Initial version
--------------------------------------------------------------------------------

library ieee;
use ieee.STD_LOGIC_1164.all;   

entity if_id is
    port (
		clk					:in STD_LOGIC;
		rst					:in STD_LOGIC;
		enable				:in STD_LOGIC;
		flush				:in STD_LOGIC;
		
		instruction_if_in   :in STD_LOGIC_VECTOR(31 downto 0);
		PC_if_in			:in STD_LOGIC_VECTOR(31 downto 0);
		PC4_if_in			:in STD_LOGIC_VECTOR(31 downto 0);
        
        instruction_id_out  :out STD_LOGIC_VECTOR(31 downto 0);
		PC_id_out			:out STD_LOGIC_VECTOR(31 downto 0);
		PC4_id_out			:out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity if_id;

architecture Behavioral of if_id is		  
begin	
    -------------------------------------------------------------------------------
    -- COMBINATIONAL/SEQUENTIAL LOGIC
    -------------------------------------------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then 	
			if rst = '0' then
            	PC_id_out <=  (others => '0'); 
				PC4_id_out <= (others => '0');
				instruction_id_out <= (others => '0'); 
        	else
				if enable = '1' then
                    if flush = '0' then
                        PC_id_out <=  (others => '0'); 
				        PC4_id_out <= (others => '0');
				        instruction_id_out <= (others => '0');
                    else
					    PC_id_out <= PC_if_in;  
					    PC4_id_out <= PC4_if_in;								  
					    instruction_id_out<= instruction_if_in;
                    end if;
            	end if;
        	end if;		
		end if;
    end process;

end architecture Behavioral;		   