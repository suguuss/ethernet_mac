library ieee;
use ieee.std_logic_1164.all;

entity packet_sender_tb is
end packet_sender_tb;

architecture test of packet_sender_tb is
	component packet_sender
		port (
			tx_clk: 	in		std_logic;
			rst_n:		in		std_logic;
			tx_go:		in		std_logic;
			tx_en: 		out 	std_logic := '1';
			tx_d:		out 	std_logic_vector(3 downto 0)	
		) ;
	end component;

	signal clk, en: std_logic := '1';
	signal d: std_logic_vector(3 downto 0) := "0000";
	signal tx_en_out: std_logic;
	signal rst: std_logic := '1';
	signal go: std_logic := '0';
begin 
	uut: packet_sender port map(tx_clk => clk, rst_n => rst, tx_go =>go, tx_en => en, tx_d => d);


	process begin

		wait for 100 ns;

		for i in 0 to 160 loop
			clk <= '0'; wait for 5 ns;
			clk <= '1'; wait for 5 ns;
		end loop;

		go <= '1';

		for i in 0 to 160 loop
			clk <= '0'; wait for 5 ns;
			clk <= '1'; wait for 5 ns;

			go <= '0';
		end loop;

		assert false report "test done" severity note;

		wait; 
	end process;
end test;