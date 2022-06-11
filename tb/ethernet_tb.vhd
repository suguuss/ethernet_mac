library ieee;
use ieee.std_logic_1164.all;

entity ethernet_tb is
end ethernet_tb;

architecture test of ethernet_tb is
	component ethernet
		port (
			--  CLOCK 
			-- MAX10_CLK1_50: 	in 		std_logic;
			
			--  KEY 
			KEY: 			in 		std_logic_vector(1 downto 0);
			
			-- --  LED 
			-- LED: 			out 	std_logic_vector(7 downto 0) := b"11111111";
			
			--  Ethernet 
			-- NET_COL:		in		std_logic;
			-- NET_CRS:		in 		std_logic;
			-- NET_MDC:		out 	std_logic;
			-- NET_MDIO:		inout 	std_logic;
			-- NET_PCF_EN:		out 	std_logic;
			NET_RESET_n:	out 	std_logic;
			-- NET_RX_CLK:		in 		std_logic;
			-- NET_RX_DV:		in 		std_logic;
			-- NET_RX_ER:		in 		std_logic;
			-- NET_RXD:		in 		std_logic_vector(3 downto 0);
			NET_TX_CLK:		in 		std_logic;
			NET_TX_EN:		out 	std_logic;
			NET_TXD:		out 	std_logic_vector(3 downto 0)

			--  SW 
			-- SW: 			in 		std_logic_vector(1 downto 0)
		);
	end component;

	signal clk, en: std_logic := '1';
	signal d: std_logic_vector(3 downto 0) := "0000";
	signal rst: std_logic := '1';
	signal sw: std_logic_vector(1 downto 0) := "00";

begin 
	uut: ethernet port map(NET_TX_CLK => clk, NET_RESET_n => rst, NET_TXD => d, NET_TX_EN => en, KEY => sw);

	process begin

			sw <= b"00";
			clk <= '0'; wait for 1 ns;
			clk <= '1'; wait for 1 ns;
			clk <= '0'; wait for 1 ns;
			clk <= '1'; wait for 1 ns;
			sw <= b"11";

		for i in 0 to 7500 loop
			clk <= '0'; wait for 1 ns;
			clk <= '1'; wait for 1 ns;
		end loop;

		-- sw <= "01";

		-- for i in 0 to 160 loop
		-- 	clk <= '0'; wait for 5 ns;
		-- 	clk <= '1'; wait for 5 ns;

		-- 	sw <= "00";
		-- end loop;

		assert false report "test done" severity note;

		wait; 
	end process;
end test;