library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ethernet_pkg.all;


entity ethernet is 
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
	
	constant MAC_ADDRESS: std_logic_vector(6*8-1 downto 0) := x"001122334455";

	signal counter: 	integer := 0;
	signal header: t_ethernet_header := (mac_dst => x"00D86119493B", mac_src => MAC_ADDRESS, ip_type => x"0000");

	signal fifo_w_en: 	std_logic := '0';
	signal fifo_din: 	std_logic_vector(3 downto 0) := x"0";

	type t_STATE is (IDLE, LOADING, EDGE_WAIT);
	signal state: 		t_STATE := IDLE;
	signal next_state: 	t_STATE := IDLE;


	type t_RXSTATE is (IDLE, CHECK_MAC, LOADING, DONE);
	signal rx_state:	t_RXSTATE := IDLE;
	signal nrx_state:	t_RXSTATE := IDLE;
	signal dst_mac:		std_logic_vector(6*8-1 downto 0) := (others => '0');
begin

	-- fifo_din <= std_logic_vector(to_unsigned(counter, fifo_din'length));
	-- state <= next_state;

	-- process (NET_TX_CLK)
	-- begin
	-- 	if rising_edge(NET_TX_CLK) then
	-- 		case( state ) is
	-- 			when IDLE =>
	-- 				fifo_w_en <= '0';

	-- 				if KEY(0) = '0' then
	-- 					next_state <= LOADING;
	-- 				else
	-- 					next_state <= IDLE;
	-- 					counter <= 0;
	-- 				end if;
					
	-- 			when LOADING =>
	-- 				counter <= counter + 1;
	-- 				fifo_w_en <= '1';

	-- 				if counter >= 92 then
	-- 					next_state <= EDGE_WAIT;
	-- 				end if;
					
	-- 			when EDGE_WAIT =>
	-- 				fifo_w_en <= '0';
	-- 				if KEY(0) = '1' then
	-- 					next_state <= IDLE;
	-- 				else
	-- 					next_state <= EDGE_WAIT;
	-- 				end if;
	-- 		end case;
	-- 	end if;
	-- end process;

	rx_state <= nrx_state;

	process (NET_RX_CLK)
	begin

		if rising_edge(NET_RX_CLK) then
			case (rx_state) is 
				when IDLE =>
					LED <= not x"01";
					fifo_w_en <= '0';

					if NET_RXD = x"d" and NET_RX_DV = '1' then
						nrx_state <= CHECK_MAC;
					else
						counter <= 0;
						nrx_state <= IDLE;
					end if;

				when CHECK_MAC =>
					LED <= not x"02";
					counter <= counter + 1;
					dst_mac <= dst_mac(6*8-5 downto 0) & NET_RXD;

					if dst_mac(6*8-5 downto 0) & NET_RXD = MAC_ADDRESS then
						nrx_state <= LOADING;
						counter <= 0;
					end if;

					if counter > 12 then 
						counter <= 0;
						nrx_state <= DONE;
					end if;

				when LOADING =>
					LED <= not x"04";
					counter <= counter + 1;
					fifo_w_en <= '1';
					fifo_din <= NET_RXD;

					if counter >= 92 then
						nrx_state <= IDLE;
					end if;

				when DONE =>
					LED <= not x"08";
					if NET_RX_DV = '0' then
						nrx_state <= IDLE;
					end if;
					
			end case;
		end if;
	end process;
	
	NET_RESET_n <= KEY(1);
	u1: ethernet_tx port 
		map(
			tx_clk => NET_TX_CLK,
			rst_n => KEY(1),
			fifo_w_en => fifo_w_en,
			fifo_din => fifo_din,
			tx_header => header,
			tx_en => NET_TX_EN,
			tx_d => NET_TXD
		);
	
end behavioral ;

