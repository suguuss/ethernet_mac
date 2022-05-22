library ieee;
use ieee.std_logic_1164.all;

entity packet_sender is
	port (
		tx_clk: 	in		std_logic;
		rst_n:		in		std_logic;
		tx_go:		in		std_logic;
		tx_en: 		out 	std_logic := '1';
		tx_d:		out 	std_logic_vector(3 downto 0)	
	) ;
end packet_sender;

architecture behavioral of packet_sender is
	
	-- Full frame hardcoded								  PREAMBLE 7 SDF 1 MAC_DST 6  MAC_SRC 6   TYPE 2
	signal frame : std_logic_vector(72*8-1 downto 0) := X"555555555555555D008D169194B3001122334455000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303AF78CA05";
	signal mask : INTEGER := 72*8-1;
	
	type t_STATE is (IDLE, SENDING);
	signal state: t_STATE := IDLE;
	shared variable next_state: t_STATE := state;
begin

	tx_d(3) <= frame(mask);
	tx_d(2) <= frame(mask - 1);
	tx_d(1) <= frame(mask - 2);
	tx_d(0) <= frame(mask - 3);

	process(tx_clk)
	begin
		if rising_edge(tx_clk) then
			if rst_n = '0' then
				state <= IDLE;
			else
				state <= next_state;
			end if;
		end if;
	
		if falling_edge(tx_clk) then
			case( state ) is
			
				when IDLE =>
					tx_en <= '0';
					mask <= 72*8-1;

					if tx_go = '1' then
						next_state := SENDING;
						tx_en <= '1';
					end if;
			
				when SENDING =>
					tx_en <= '1';

					
					if mask = 3 then
						next_state := IDLE;
						tx_en <= '0';
					else
						mask <= mask - 4;	
					end if;

			end case ;
		end if;

	end process;








	-- tx_d(3) <= frame(mask);
	-- tx_d(2) <= frame(mask - 1);
	-- tx_d(1) <= frame(mask - 2);
	-- tx_d(0) <= frame(mask - 3);


	-- move_mask: process(tx_clk)
	-- begin
	-- 	if rising_edge(tx_clk) then
	-- 		if rst_n = '0' then
	-- 			tx_en <= '1';
	-- 			mask <= 575;
	-- 		else
	-- 			if mask = 3 then
	-- 				tx_en <= '0';
	-- 			else 
	-- 				mask <= mask -4;
	-- 			end if;
	-- 		end if;
	-- 	end if;
	-- end process;

end behavioral ; -- pkt_send