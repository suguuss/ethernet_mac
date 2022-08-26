library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ethernet_pkg.all;


entity ethernet is
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
end ethernet;

architecture behavioral of ethernet is
	component ethernet_tx
		generic (
			DATA_BYTES: integer := 46
		);
		port (
			tx_clk: 	in		std_logic;
			rst_n:		in		std_logic;
			fifo_w_en:	in		std_logic;
			fifo_din:	in		std_logic_vector(3 downto 0);
			tx_header:  in		t_ethernet_header;

			tx_en: 		out 	std_logic := '1';
			tx_d:		out 	std_logic_vector(3 downto 0)
		);
	end component;
	
	component ethernet_rx
		generic (
			DATA_BYTES: 		integer := 46;
			MAC_SOURCE:			std_logic_vector(48-1 downto 0) := x"001122334455"
		);
		port (
			rx_clk: 	in		std_logic;
			rst_n:		in		std_logic;
			rx_d:		in		std_logic_vector(3 downto 0);
			rx_dv:		in		std_logic;
			fifo_en:	in		std_logic := '0';

			fifo_out:	out		std_logic_vector(3 downto 0);
			pkt_ready:	out		std_logic
		);
	end component;


	signal header: t_ethernet_header := (
		mac_dst => MAC_DESTINATION,
		mac_src => MAC_SOURCE,
		ip_type => x"0000"
	);

begin


	eth_rx: ethernet_rx 
		generic map(
			DATA_BYTES => PACKET_DATA_SIZE
		)
		port map(
			rx_clk => rx_clk,
			rst_n => eth_rst_n,
			rx_d => rxd,
			rx_dv => rx_dv,
			fifo_en => rx_fifo_en,
			fifo_out => rx_fifo_dout,
			pkt_ready => rx_pkt_rdy
		);

	eth_tx: ethernet_tx 
		generic map(
			DATA_BYTES => PACKET_DATA_SIZE
		)
		port map(
			tx_clk => tx_clk,
			rst_n => eth_rst_n,
			fifo_w_en => tx_fifo_w_en,
			fifo_din => tx_fifo_din,
			tx_header => header,
			tx_en => tx_en,
			tx_d => txd
		);
	

	-- state <= next_state;
	-- fifo_din <= fifo_dout;

	-- process (rx_clk)
	-- begin
	-- 	if rising_edge(rx_clk) then
	-- 		case (state) is
	-- 			when IDLE =>
	-- 				fifo_w_en <= '0';
	-- 				fifo_en <= '0';
	-- 				counter <= 0;
				
	-- 				if pkt_rdy = '1' then
	-- 					next_state <= LOADING;
	-- 				end if;

	-- 			when LOADING =>
	-- 				counter <= counter + 1;
	-- 				fifo_w_en <= '1';
	-- 				fifo_en <= '1';

	-- 				if counter > 2*PACKET_DATA_SIZE then
	-- 					next_state <= IDLE;
	-- 				end if;

	-- 			when EDGE_WAIT =>
	-- 		end case;
	-- 	end if;
	-- end process;


end behavioral ;

