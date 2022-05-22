library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethernet is 
	port (
		--  CLOCK 
		MAX10_CLK1_50: 	in 		std_logic;
		
		--  KEY 
		KEY: 			in 		std_logic_vector(1 downto 0);
		
		--  LED 
		LED: 			out 	std_logic_vector(7 downto 0) := b"11111111";
		
		--  Ethernet 
		NET_COL:		in		std_logic;
		NET_CRS:		in 		std_logic;
		NET_MDC:		out 	std_logic := '0';
		NET_MDIO:		inout 	std_logic;
		NET_PCF_EN:		out 	std_logic := '0';
		NET_RESET_n:	out 	std_logic;
		NET_RX_CLK:		in 		std_logic;
		NET_RX_DV:		in 		std_logic;
		NET_RX_ER:		in 		std_logic;
		NET_RXD:		in 		std_logic_vector(3 downto 0);
		NET_TX_CLK:		in 		std_logic;
		NET_TX_EN:		out 	std_logic := '0';
		NET_TXD:		out 	std_logic_vector(3 downto 0) := x"0";

		--  SW 
		SW: 			in 		std_logic_vector(1 downto 0)
	);
end ethernet;

architecture behavioral of ethernet is
	component packet_sender
		port (
			tx_clk: 	in		std_logic;
			rst_n:		in		std_logic;
			tx_go: 		in		std_logic;
			tx_en: 		out 	std_logic := '1';
			tx_d:		out 	std_logic_vector(3 downto 0)	
		) ;
	end component;
	
	signal counter: integer := 0;
	signal go: std_logic := '0';
begin

	process (NET_TX_CLK)
	begin
		if rising_edge(NET_TX_CLK) then
			
			if (counter = 2500) then
				go <= '1';
				counter <= counter + 1;
			elsif (counter = 2510) then
				go <= '0';
				counter <= 0;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;
	
	NET_RESET_n <= KEY(1);
	-- go <= not(KEY(0));
	u1: packet_sender port map(tx_clk => NET_TX_CLK, rst_n => '1', tx_go =>go, tx_en => NET_TX_EN, tx_d => NET_TXD);
	
end behavioral ;

