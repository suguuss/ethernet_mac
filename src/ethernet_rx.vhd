library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ethernet_pkg.all;

entity ethernet_rx is
	generic (
		DATA_BYTES: 		integer := 46;
		MAC_ADDRESS:		std_logic_vector(48-1 downto 0) := x"001122334455"
	);
	port (
		rx_clk: 	in		std_logic;
		rst_n:		in		std_logic;
		rx_d:		in		std_logic_vector(3 downto 0);
		rx_dv:		in		std_logic;

		fifo_en:	in		std_logic := '0';
		fifo_out:	out		std_logic_vector(3 downto 0);
		pkt_ready:	out		std_logic := '0'
	);
end ethernet_rx;

architecture behavioral of ethernet_rx is
	component rx_fifo
		generic (
			FIFO_SIZE: integer := 2*DATA_BYTES
		);
		port (
			clk: 		in 		std_logic;
			rst_n: 		in 		std_logic;
			enable: 	in 		std_logic;
			write_en: 	in 		std_logic;
			data_in: 	in 		std_logic_vector(3 downto 0);
			data_out: 	out 	std_logic_vector(3 downto 0);
			full: 		out 	std_logic
		);
	end component;

	type t_STATE is (IDLE, MAC_DST, MAC_SRC, PKT_TYPE, DATA, DONE);
	signal state: 				t_STATE := IDLE;
	signal next_state: 			t_STATE := IDLE;

	signal counter: 			integer := 0;


	signal dst_mac:				std_logic_vector(48-1 downto 0) := (others => '0');
	signal src_mac:				std_logic_vector(48-1 downto 0) := (others => '0');

	-- FIFO SIGNALS
	signal fifo_full: 			std_logic := '0';
	signal fifo_w_en:		 	std_logic := '0';
	signal fifo_dout: 			std_logic_vector(3 downto 0) := x"0";
	signal fifo_din: 			std_logic_vector(3 downto 0) := x"0";
begin
	
	state <= next_state;
	fifo_out <= fifo_dout;

	process (rx_clk)
	begin
		if rising_edge(rx_clk) then
			if rst_n = '0' then
				counter <= 0;
				next_state <= IDLE;
			else
				
				case (state) is
					when IDLE =>
						fifo_w_en <= '0';
						pkt_ready <= '0';

						if rx_d = x"d" and rx_dv = '1' then
							next_state <= MAC_DST;
						else
							counter <= 0;
							next_state <= IDLE;
						end if;

					when MAC_DST =>
						counter <= counter + 1;
						dst_mac <= dst_mac(48-5 downto 0) & rx_d;

						if dst_mac(48-5 downto 0) & rx_d = MAC_ADDRESS then
						-- if dst_mac = MAC_ADDRESS then
							next_state <= MAC_SRC;
							counter <= 0;
						end if;

						if counter >= 12 then 
							counter <= 0;
							next_state <= DONE;
						end if;

					when MAC_SRC =>
						counter <= counter + 1;
						src_mac <= src_mac(48-5 downto 0) & rx_d;

						if counter >= 12 then 
							counter <= 0;
							next_state <= PKT_TYPE;
						end if;

					when PKT_TYPE =>
						counter <= counter + 1;

						if counter >= 2 then 
							counter <= 0;
							next_state <= DATA;
						end if;

					when DATA =>
						counter <= counter + 1;
						fifo_w_en <= '1';
						fifo_din <= rx_d;

						--if counter >= 200 then
						if fifo_full = '1' then
							next_state <= DONE;
							pkt_ready <= '1';
						end if;

					when DONE =>
						fifo_w_en <= '0';
						if rx_dv = '0' then
							next_state <= IDLE;
						end if;

				end case;

			end if;
		end if;
	end process;

	receive_fifo: rx_fifo port
		map(
			clk => rx_clk,
			rst_n => rst_n,
			enable => fifo_en,
			write_en => fifo_w_en,
			data_in => fifo_din,
			data_out => fifo_dout,
			full => fifo_full
		);



end behavioral ; -- ethernet_rx