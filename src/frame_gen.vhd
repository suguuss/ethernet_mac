library ieee;
library work;
use ieee.std_logic_1164.all;
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
	
	constant MII_LEN:			integer := 4;

	constant PREAMBLE_BYTES: 	integer := 7;
	constant SFD_BYTES: 		integer := 1;
	constant HEADER_BYTES: 		integer := 14;
	constant DATA_BYTES: 		integer := 64;
	constant FCS_BYTES: 		integer := 4;
	constant INTERGAP_BYTES: 	integer := 12;

	constant PREAMBLE_LEN: 		integer := PREAMBLE_BYTES*8/MII_LEN;
	constant SFD_LEN: 			integer := SFD_BYTES*8/MII_LEN;
	constant HEADER_LEN: 		integer := HEADER_BYTES*8/MII_LEN;
	constant DATA_LEN: 			integer := DATA_BYTES*8/MII_LEN;
	constant FCS_LEN: 			integer := FCS_BYTES*8/MII_LEN;
	constant INTERGAP_LEN: 		integer := INTERGAP_BYTES*8/MII_LEN;

	signal preamble_buf: 		std_logic_vector(PREAMBLE_BYTES*8-1 downto 0) := x"55555555555555";
	signal sfd_buf: 			std_logic_vector(SFD_BYTES*8-1 downto 0) := x"5D";
	signal header_buf: 			std_logic_vector(HEADER_BYTES*8-1 downto 0);
	signal data_buf: 			std_logic_vector(DATA_BYTES*8-1 downto 0);
	signal fcs_buf: 			std_logic_vector(FCS_BYTES*8-1 downto 0);


	type t_STATE is (IDLE, PREAMBLE, SFD, HEADER, DATA, FCS, INTERGAP);
	signal state: t_STATE := IDLE;

begin

process (tx_clk)
begin
	if rising_edge(tx_clk) then
		if rst_n = '0' then
			state <= IDLE;

			preamble_buf <= x"55555555555555";
			sfd_buf <= x"5D";
			header_buf <= tx_header.mac_dst;
		else

		end if;
	end if;

end process;

end behavioral ; -- frame_gen