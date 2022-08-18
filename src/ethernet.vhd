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
		-- LED: 			out 	std_logic_vector(7 downto 0) := b"11111111";
		
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
		NET_TXD:		out 	std_logic_vector(3 downto 0) := x"0"

		--  SW 
		-- SW: 			in 		std_logic_vector(1 downto 0)
	);
end ethernet;

architecture behavioral of ethernet is
	component frame_gen
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
	
	signal counter: 	integer := 0;
	signal header: t_ethernet_header := (mac_dst => x"00D86119493B", mac_src => x"001122334455", ip_type => x"0000");

	signal fifo_w_en: 	std_logic := '0';
	signal fifo_din: 	std_logic_vector(3 downto 0) := x"0";

	type t_STATE is (IDLE, LOADING, EDGE_WAIT);
	signal state: 		t_STATE := IDLE;
	signal next_state: 	t_STATE := IDLE;
begin

	fifo_din <= std_logic_vector(to_unsigned(counter, fifo_din'length));
	state <= next_state;

	process (NET_TX_CLK)
	begin
		if rising_edge(NET_TX_CLK) then
			case( state ) is
				when IDLE =>
					fifo_w_en <= '0';

					if KEY(0) = '0' then
						next_state <= LOADING;
					else
						next_state <= IDLE;
						counter <= 0;
					end if;
					
				when LOADING =>
					counter <= counter + 1;
					fifo_w_en <= '1';

					if counter >= 92 then
						next_state <= EDGE_WAIT;
					end if;
					
				when EDGE_WAIT =>
					fifo_w_en <= '0';
					if KEY(0) = '1' then
						next_state <= IDLE;
					else
						next_state <= EDGE_WAIT;
					end if;
			end case;
		end if;
	end process;
	
	NET_RESET_n <= KEY(1);
	u1: frame_gen port 
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

