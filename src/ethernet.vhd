library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ethernet_pkg.all;


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
	component frame_gen
		port (
			tx_clk: 	in		std_logic;
			rst_n:		in		std_logic;
			tx_send:	in		std_logic;
			tx_header:  in		t_ethernet_header;
	
			tx_en: 		out 	std_logic := '1';
			tx_d:		out 	std_logic_vector(3 downto 0)
		) ;
	end component;
	
	signal counter: integer := 0;
	signal go: std_logic := '0';
	signal header: t_ethernet_header := (mac_dst => x"00D86119493B", mac_src => x"001122334455", ip_type => x"0000");
	signal debug_mac_src: std_logic_vector(6*8-1 downto 0) := header.mac_src;
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
	u1: frame_gen port map(tx_clk => NET_TX_CLK, tx_header => header, rst_n => KEY(0), tx_send => go, tx_en => NET_TX_EN, tx_d => NET_TXD);
	
end behavioral ;

