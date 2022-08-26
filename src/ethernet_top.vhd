library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ethernet_pkg.all;


entity ethernet_top is 
	port (
		--  CLOCK 
		-- MAX10_CLK1_50: 	in 		std_logic;
		
		--  KEY 
		KEY: 			in 		std_logic_vector(1 downto 0);
		
		--  LED 
		LED: 			out 	std_logic_vector(7 downto 0) := b"11111111";
		
		--  Ethernet 
		NET_COL:		in		std_logic := '0';
		NET_CRS:		in 		std_logic := '0';
		NET_MDC:		out 	std_logic := '0';
		NET_MDIO:		inout 	std_logic := '0';
		NET_PCF_EN:		out 	std_logic := '0';
		NET_RESET_n:	out 	std_logic := '0';
		NET_RX_CLK:		in 		std_logic := '0';
		NET_RX_DV:		in 		std_logic := '0';
		NET_RX_ER:		in 		std_logic := '0';
		NET_RXD:		in 		std_logic_vector(3 downto 0);
		NET_TX_CLK:		in 		std_logic := '0';
		NET_TX_EN:		out 	std_logic := '0';
		NET_TXD:		out 	std_logic_vector(3 downto 0) := x"0"

		--  SW 
		-- SW: 			in 		std_logic_vector(1 downto 0)
	);
end ethernet_top;

architecture behavioral of ethernet_top is
	component ethernet is
		generic (
			PACKET_DATA_SIZE: 		integer := 100;
			MAC_SOURCE: 			std_logic_vector(47 downto 0) := x"001122334455";
			MAC_DESTINATION: 		std_logic_vector(47 downto 0) := x"00D86119493B"
		);
		port (
			eth_rst_n:		in 		std_logic := '0';
			
			rx_clk:			in 		std_logic := '0';
			rx_dv:			in 		std_logic := '0';
			rxd:			in 		std_logic_vector(3 downto 0);
			rx_fifo_en:		in	 	std_logic;
			rx_fifo_dout: 	out		std_logic_vector(3 downto 0);
			rx_pkt_rdy:		out 	std_logic;

			tx_clk:			in 		std_logic := '0';
			tx_en:			out 	std_logic := '0';
			txd:			out 	std_logic_vector(3 downto 0) := x"0";
			tx_fifo_w_en:	in		std_logic;
			tx_fifo_din:	in		std_logic_vector(3 downto 0) := x"0"
		);
	end component;



	signal counter: 	integer := 0;

	signal fifo_w_en: 	std_logic := '0';
	signal fifo_en: 	std_logic := '0';
	signal fifo_din: 	std_logic_vector(3 downto 0) := x"0";
	signal fifo_dout: 	std_logic_vector(3 downto 0) := x"0";

	type t_STATE is (IDLE, LOADING);
	signal state: 		t_STATE := IDLE;
	signal next_state: 	t_STATE := IDLE;

	signal pkt_rdy: 	std_logic := '0';
begin
	NET_RESET_n <= KEY(1);
	fifo_din <= fifo_dout;
	state <= next_state;
	
	process (NET_RX_CLK)
	begin
		if rising_edge(NET_RX_CLK) then
			case (state) is
				when IDLE =>
					fifo_w_en <= '0';
					fifo_en <= '0';
					counter <= 0;
				
					if pkt_rdy = '1' then
						next_state <= LOADING;
					end if;

				when LOADING =>
					counter <= counter + 1;
					fifo_w_en <= '1';
					fifo_en <= '1';

					if counter > 2*100 then
						next_state <= IDLE;
					end if;
			end case;
		end if;
	end process;



	eth1: ethernet
		port map (
			eth_rst_n => KEY(1),
			
			rx_clk => NET_RX_CLK,
			rx_dv => NET_RX_DV,
			rxd => NET_RXD,
			rx_fifo_en => fifo_en,
			rx_fifo_dout => fifo_dout,
			rx_pkt_rdy => pkt_rdy,
			
			tx_clk => NET_TX_CLK,
			tx_en => NET_TX_EN,
			txd => NET_TXD,
			tx_fifo_w_en => fifo_w_en,
			tx_fifo_din => fifo_din
		);


end behavioral ;

