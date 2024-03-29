library ieee;
use ieee.std_logic_1164.all;

entity ethernet_tb is
end ethernet_tb;

architecture test of ethernet_tb is
	component ethernet_top
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
			NET_RX_CLK:		in 		std_logic;
			NET_RX_DV:		in 		std_logic;
			-- NET_RX_ER:		in 		std_logic;
			NET_RXD:		in 		std_logic_vector(3 downto 0);
			NET_TX_CLK:		in 		std_logic;
			NET_TX_EN:		out 	std_logic;
			NET_TXD:		out 	std_logic_vector(3 downto 0)

			--  SW 
			-- SW: 			in 		std_logic_vector(1 downto 0)
		);
	end component;

	signal clk,en: std_logic := '1';
	signal d: std_logic_vector(3 downto 0) := "0000";
	signal rst: std_logic := '1';
	signal sw: std_logic_vector(1 downto 0) := "00";
	signal dv: std_logic := '0';
	signal rxd: std_logic_vector(3 downto 0) := x"0";
	signal mac: std_logic_vector(6*8-1 downto 0) := x"112233445566";

	signal frame : std_logic_vector(126*8-1 downto 0) := X"555555555555555D001122334455008D169194B3000014243454142434541424345414243454142434541424345414243454142434541424345414243454142434541424345414243454142434541424345414243454142434541424345414243454142434541424345414243454142434541424345414243454AF78CA05";

begin 
	uut: ethernet_top port map(
		NET_TX_CLK => clk,
		NET_RX_CLK => clk,
		NET_RX_DV => dv,
		NET_RXD => rxd,
		NET_RESET_n => rst,
		NET_TXD => d,
		NET_TX_EN => en,
		KEY => sw
		);

	process begin
			-- rxd <= x"d";
			-- sw <= b"00";
			-- clk <= '0'; wait for 1 ns;
			-- clk <= '1'; wait for 1 ns;
			-- sw <= b"01";
			-- clk <= '0'; wait for 1 ns;
			-- clk <= '1'; wait for 1 ns;
			sw <= b"10";
			clk <= '0'; wait for 1 ns;
			clk <= '1'; wait for 1 ns;
			sw <= b"11";

			for i in 0 to 750 loop
				clk <= '0'; wait for 1 ns;
				clk <= '1'; wait for 1 ns;

			end loop;

		-- dv <= '1';
		-- for i in 0 to 750 loop
		-- 	rxd <= frame(126*8-1 downto 126*8-4);
		-- 	clk <= '0'; wait for 1 ns;
		-- 	frame <= frame(126*8-5 downto 0) & x"0";
		-- 	clk <= '1'; wait for 1 ns;

		-- 	if i > 150 then
		-- 		dv <= '0';
		-- 	end if;
		-- end loop;

		-- frame <= X"555555555555555D001122334455008D169194B3000014243454142434541424345414243454142434541424345414243454142434541424345414243454142434541424345414243454142434541424345414243454142434541424345414243454142434541424345414243454142434541424345414243454AF78CA05";
		-- dv <= '1';
		-- for i in 0 to 750 loop
		-- 	rxd <= frame(126*8-1 downto 126*8-4);
		-- 	clk <= '0'; wait for 1 ns;
		-- 	frame <= frame(126*8-5 downto 0) & x"0";
		-- 	clk <= '1'; wait for 1 ns;

		-- 	if i > 150 then
		-- 		dv <= '0';
		-- 	end if;
		-- end loop;


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