library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity crc_gen is
	port (
		clk: 		in 		std_logic;
		rst: 		in 		std_logic;
		crc_en: 	in 		std_logic;
		data_in: 	in 		std_logic_vector(3 downto 0);
		crc_out: 	out 	std_logic_vector(31 downto 0)
	);
end crc_gen;

architecture behavioral of crc_gen is
	signal lfsr_q: std_logic_vector(31 downto 0) := x"FFFFFFFF";
	signal lfsr_c: std_logic_vector(31 downto 0) := x"FFFFFFFF";
begin

	-- xor on the output
	crc_out <= lfsr_q xor x"ffffffff";

	-- -------------------------------------------------------------------------
	--                              0xEDB88320 (hex)
	-- CRC width:                   32 bits
	-- CRC shift direction:         right (little endian)
	-- Input word width:            4 bits


	lfsr_c(0) <= lfsr_q(4);
	lfsr_c(1) <= lfsr_q(5);
	lfsr_c(2) <= (data_in(0) xor lfsr_q(0) xor lfsr_q(6));
	lfsr_c(3) <= (data_in(1) xor lfsr_q(1) xor lfsr_q(7));
	lfsr_c(4) <= (data_in(2) xor lfsr_q(2) xor lfsr_q(8));
	lfsr_c(5) <= (data_in(0) xor data_in(3) xor lfsr_q(0) xor lfsr_q(3) xor lfsr_q(9));
	lfsr_c(6) <= (data_in(0) xor data_in(1) xor lfsr_q(0) xor lfsr_q(1) xor lfsr_q(10));
	lfsr_c(7) <= (data_in(1) xor data_in(2) xor lfsr_q(1) xor lfsr_q(2) xor lfsr_q(11));
	lfsr_c(8) <= (data_in(2) xor data_in(3) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(12));
	lfsr_c(9) <= (data_in(3) xor lfsr_q(3) xor lfsr_q(13));
	lfsr_c(10) <= lfsr_q(14);
	lfsr_c(11) <= lfsr_q(15);
	lfsr_c(12) <= (data_in(0) xor lfsr_q(0) xor lfsr_q(16));
	lfsr_c(13) <= (data_in(1) xor lfsr_q(1) xor lfsr_q(17));
	lfsr_c(14) <= (data_in(2) xor lfsr_q(2) xor lfsr_q(18));
	lfsr_c(15) <= (data_in(3) xor lfsr_q(3) xor lfsr_q(19));
	lfsr_c(16) <= (data_in(0) xor lfsr_q(0) xor lfsr_q(20));
	lfsr_c(17) <= (data_in(0) xor data_in(1) xor lfsr_q(0) xor lfsr_q(1) xor lfsr_q(21));
	lfsr_c(18) <= (data_in(0) xor data_in(1) xor data_in(2) xor lfsr_q(0) xor lfsr_q(1) xor lfsr_q(2) xor lfsr_q(22));
	lfsr_c(19) <= (data_in(1) xor data_in(2) xor data_in(3) xor lfsr_q(1) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(23));
	lfsr_c(20) <= (data_in(0) xor data_in(2) xor data_in(3) xor lfsr_q(0) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(24));
	lfsr_c(21) <= (data_in(0) xor data_in(1) xor data_in(3) xor lfsr_q(0) xor lfsr_q(1) xor lfsr_q(3) xor lfsr_q(25));
	lfsr_c(22) <= (data_in(1) xor data_in(2) xor lfsr_q(1) xor lfsr_q(2) xor lfsr_q(26));
	lfsr_c(23) <= (data_in(0) xor data_in(2) xor data_in(3) xor lfsr_q(0) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(27));
	lfsr_c(24) <= (data_in(0) xor data_in(1) xor data_in(3) xor lfsr_q(0) xor lfsr_q(1) xor lfsr_q(3) xor lfsr_q(28));
	lfsr_c(25) <= (data_in(1) xor data_in(2) xor lfsr_q(1) xor lfsr_q(2) xor lfsr_q(29));
	lfsr_c(26) <= (data_in(0) xor data_in(2) xor data_in(3) xor lfsr_q(0) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(30));
	lfsr_c(27) <= (data_in(0) xor data_in(1) xor data_in(3) xor lfsr_q(0) xor lfsr_q(1) xor lfsr_q(3) xor lfsr_q(31));
	lfsr_c(28) <= (data_in(0) xor data_in(1) xor data_in(2) xor lfsr_q(0) xor lfsr_q(1) xor lfsr_q(2));
	lfsr_c(29) <= (data_in(1) xor data_in(2) xor data_in(3) xor lfsr_q(1) xor lfsr_q(2) xor lfsr_q(3));
	lfsr_c(30) <= (data_in(2) xor data_in(3) xor lfsr_q(2) xor lfsr_q(3));
	lfsr_c(31) <= (data_in(3) xor lfsr_q(3));
	
	
	-- -------------------------------------------------------------------------



	process (clk, rst) begin
		if rising_edge(clk) then
			if rst = '0' then
				lfsr_q <= x"ffffffff";
			else
				if crc_en = '1' then
					lfsr_q <= lfsr_c;
				else 
					lfsr_q <= lfsr_q;
				end if;
			end if;
		end if;
	end process;
end behavioral;