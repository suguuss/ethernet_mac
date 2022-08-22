library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ethernet_pkg.all;

entity ethernet_tx is
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
end ethernet_tx;

architecture behavioral of ethernet_tx is
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

	component crc_gen 
		port (
			clk: 		in 		std_logic;
			rst: 		in 		std_logic;
			crc_en: 	in 		std_logic;
			data_in: 	in 		std_logic_vector(3 downto 0);
			crc_out: 	out 	std_logic_vector(31 downto 0)
		);
	end component;


	constant MII_LEN:			integer := 4;

	constant PREAMBLE_BYTES: 	integer := 7;
	constant SFD_BYTES: 		integer := 1;
	constant HEADER_BYTES: 		integer := 14;
	-- constant DATA_BYTES: 		integer := data_bytes;
	constant FCS_BYTES: 		integer := 4;
	constant INTERGAP_BYTES: 	integer := 12;

	constant PREAMBLE_LEN: 		integer := PREAMBLE_BYTES*8/MII_LEN;
	constant SFD_LEN: 			integer := SFD_BYTES*8/MII_LEN;
	constant HEADER_LEN: 		integer := HEADER_BYTES*8/MII_LEN;
	constant DATA_LEN: 			integer := DATA_BYTES*8/MII_LEN;
	constant FCS_LEN: 			integer := FCS_BYTES*8/MII_LEN;
	constant INTERGAP_LEN: 		integer := INTERGAP_BYTES*8/MII_LEN;

	signal preamble_buf: 		std_logic_vector(PREAMBLE_BYTES*8-1 downto 0) := x"55555555555555";
	signal sfd_buf: 			std_logic_vector(SFD_BYTES*8-1 downto 0) := x"D5";
	signal header_buf: 			std_logic_vector(HEADER_BYTES*8-1 downto 0);
	-- signal data_buf: 			std_logic_vector(DATA_BYTES*8-1 downto 0);
	signal fcs_buf: 			std_logic_vector(FCS_BYTES*8-1 downto 0) := x"00000000";
	signal crc_out_buf: 		std_logic_vector(FCS_BYTES*8-1 downto 0) := x"00000000";

	type t_STATE is (IDLE, PREAMBLE, SFD, HEADER, DATA, FCS, INTERGAP);
	signal state: 				t_STATE := IDLE;
	signal next_state: 			t_STATE := state;
	signal tx_data: 			std_logic_vector(MII_LEN-1 downto 0);
	signal tx_e: 				std_logic := '0';

	signal fcs_rst:				std_logic := '1';
	signal en_crc: 				std_logic := '0';

	signal counter: 			integer := 0;

	-- FIFO SIGNALS
	signal fifo_full: 			std_logic := '0';
	signal fifo_en:		 		std_logic := '0';
	signal fifo_dout: 			std_logic_vector(3 downto 0) := x"0";
begin

	tx_en <= tx_e;
	tx_d  <= tx_data;

	
	process (tx_clk)
	begin

		if fifo_w_en = '1' or state = DATA then
			fifo_en <= '1';
		else
			fifo_en <= '0';
		end if;

		if rising_edge(tx_clk) then
			-- GOES BACK TO IDLE STATE WHEN RST
			if rst_n = '0' then
				state <= IDLE;
			else
				state <= next_state;

				if state /= next_state then
					counter <= 0;
				else
					counter <= counter + 1;
				end if;
			end if;
		end if;

		if falling_edge(tx_clk) then
			case( state ) is
				when IDLE =>
					-- Set buffer to default state
					preamble_buf <= x"55555555555555";
					sfd_buf <= x"D5";
					header_buf <= ChangeEndian(tx_header.ip_type) & ChangeEndian(tx_header.mac_src) & ChangeEndian(tx_header.mac_dst);
					-- data_buf   <= x"813f2997d9f4a2236c229170277c46ec7d526770951f947810761f299810b7f8947cd9316fe04768becf3dda8e4f";
					
					tx_e <= '0';
					en_crc <= '0';
					fcs_rst <= '0';

					-- Change of state
					if fifo_full = '1' then
						next_state <= PREAMBLE;
					else
						next_state <= state;
					end if;

				when PREAMBLE =>
					tx_data <= preamble_buf(MII_LEN-1 downto 0);
					preamble_buf <= std_logic_vector(shift_right(unsigned(preamble_buf), MII_LEN));

					tx_e <= '1';
					en_crc <= '0';
					fcs_rst <= '0';

					-- Change of state
					if counter = PREAMBLE_LEN-1 then
						next_state <= SFD;
					else
						next_state <= state;
					end if;

				when SFD =>
					tx_data <= sfd_buf(MII_LEN-1 downto 0);
					sfd_buf <= std_logic_vector(shift_right(unsigned(sfd_buf), MII_LEN));

					tx_e <= '1';
					en_crc <= '0';
					fcs_rst <= '0';

					-- Change of state
					if counter = SFD_LEN-1 then
						next_state <= HEADER;
					else
						next_state <= state;
					end if;

				when HEADER =>
					tx_data <= header_buf(MII_LEN-1 downto 0);
					header_buf <= std_logic_vector(shift_right(unsigned(header_buf), MII_LEN));

					tx_e <= '1';
					en_crc <= '1';
					fcs_rst <= '1';

					-- Change of state
					if counter = HEADER_LEN-1 then
						next_state <= DATA;
					else
						next_state <= state;
					end if;

				when DATA =>
					-- tx_data <= data_buf(MII_LEN-1 downto 0);
					-- data_buf <= std_logic_vector(shift_right(unsigned(data_buf), MII_LEN));
					tx_data <= fifo_dout;
					tx_e <= '1';
					en_crc <= '1';
					fcs_rst <= '1';
					
					-- Change of state
					if counter = DATA_LEN-1 then
						next_state <= FCS;
					else
						next_state <= state;
					end if;

				when FCS =>
					if counter = 0 then
						tx_data <= crc_out_buf(MII_LEN-1 downto 0);
						fcs_buf <= std_logic_vector(shift_right(unsigned(crc_out_buf), MII_LEN));
					else
						tx_data <= fcs_buf(MII_LEN-1 downto 0);
						fcs_buf <= std_logic_vector(shift_right(unsigned(fcs_buf), MII_LEN));
					end if;

					tx_e <= '1';
					en_crc <= '0';
					fcs_rst <= '1';

					-- Change of state
					if counter = FCS_LEN-1 then
						next_state <= INTERGAP;
					else
						next_state <= state;
					end if;

				when INTERGAP =>
					tx_data <= b"0000";

					tx_e <= '0';
					en_crc <= '0';
					fcs_rst <= '1';

					-- Change of state
					if counter = INTERGAP_LEN-1 then
						next_state <= IDLE;
					else
						next_state <= state;
					end if;

			end case;
		end if;

	end process;

	send_fifo: rx_fifo port
		map(
			clk => tx_clk,
			rst_n => rst_n,
			enable => fifo_en,
			write_en => fifo_w_en,
			data_in => fifo_din,
			data_out => fifo_dout,
			full => fifo_full
		);


	crc: crc_gen port 
		map(
			clk => tx_clk,
			rst => fcs_rst,
			crc_en => en_crc,
			data_in => tx_data,
			crc_out => crc_out_buf
		);


end behavioral ; -- ethernet_tx