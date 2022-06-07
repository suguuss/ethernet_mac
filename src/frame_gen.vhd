library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ethernet_pkg.all;

entity frame_gen is
	port (
		tx_clk: 	in		std_logic;
		rst_n:		in		std_logic;
		tx_send:	in		std_logic;
		tx_header:  in		t_ethernet_header;

		tx_en: 		out 	std_logic := '1';
		tx_d:		out 	std_logic_vector(3 downto 0)
	) ;
end frame_gen;

architecture behavioral of frame_gen is
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
	constant DATA_BYTES: 		integer := 46;
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
	signal header_buf: 			std_logic_vector(HEADER_BYTES*8-1 downto 0); --   
	-- signal data_buf: 			std_logic_vector(DATA_BYTES*8-1 downto 0) :=    x"13030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303";
	signal data_buf: 			std_logic_vector(DATA_BYTES*8-1 downto 0) :=    x"31303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030";
	signal fcs_buf: 			std_logic_vector(FCS_BYTES*8-1 downto 0) := x"00000000";
	signal test_buf: 			std_logic_vector(FCS_BYTES*8-1 downto 0) := x"00000000";


	type t_STATE is (IDLE, PREAMBLE, SFD, HEADER, DATA, FCS, INTERGAP);
	signal state: 		t_STATE := IDLE;
	signal next_state: 	t_STATE := state;
	signal tx_data: 	std_logic_vector(MII_LEN-1 downto 0);
	signal tx_data_r: 	std_logic_vector(MII_LEN-1 downto 0);
	signal tx_e: 		std_logic := '0';

	signal fcs_rst:		std_logic := '1';
	signal en_crc: 		std_logic := '0';

	signal counter: 	integer := 0;

begin

	tx_en <= tx_e;
	tx_d  <= tx_data;
	
	tx_data_r(3) <= tx_data(0);
	tx_data_r(2) <= tx_data(1);
	tx_data_r(1) <= tx_data(2);
	tx_data_r(0) <= tx_data(3);
	

	process (tx_clk)
	begin
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
					-- data_buf <= x"31303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030";
					data_buf <= x"33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333";
					
					tx_e <= '0';
					en_crc <= '0';
					fcs_rst <= '0';

					-- Change of state
					if tx_send = '1' then
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
					tx_data <= data_buf(MII_LEN-1 downto 0);
					data_buf <= std_logic_vector(shift_right(unsigned(data_buf), MII_LEN));

					tx_e <= '1';
					en_crc <= '1';
					fcs_rst <= '1';

					-- Change of state
					if counter = DATA_LEN-1 then
						next_state <= FCS;
						fcs_buf <= test_buf;
					else
						next_state <= state;
					end if;

				when FCS =>
					tx_data <= fcs_buf(MII_LEN-1 downto 0);
					fcs_buf <= std_logic_vector(shift_right(unsigned(fcs_buf), MII_LEN));

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

			
			end case ;

		end if;

	end process;


	crc: crc_gen port 
		map(
			clk => tx_clk,
			rst => fcs_rst,
			crc_en => en_crc,
			data_in => tx_data,
			crc_out => test_buf
		);


end behavioral ; -- frame_gen