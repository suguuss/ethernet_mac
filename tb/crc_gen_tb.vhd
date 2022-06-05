library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.std_logic_1164_additions.all;

entity crc_gen_tb is
end crc_gen_tb;

architecture test of crc_gen_tb is
	component crc_gen
		port (
			clk: 		in 		std_logic;
			rst: 		in 		std_logic;
			crc_en: 	in 		std_logic;
			data_in: 	in 		std_logic_vector(0 to 3);
			crc_out: 	out 	std_logic_vector(31 downto 0)
		);
	end component;

	signal tx_clk: std_logic := '0';
	signal fcs_rst: std_logic := '1';
	signal en_crc: std_logic := '0';
	signal tx_data: std_logic_vector(3 downto 0);
	signal tx_data_r: std_logic_vector(3 downto 0);
	signal test_buf: std_logic_vector(31 downto 0) 	:= x"00000000";
	signal test_buf_r: std_logic_vector(31 downto 0):= x"00000000";
	signal frame: std_logic_vector(479 downto 0)   	:= x"00D86119493B001122334455000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030";
	signal frame_r: std_logic_vector(479 downto 0) 	:= x"008D169194B3001122334455000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303";
begin
	uut: crc_gen port 
	map(
		clk => tx_clk,
		rst => fcs_rst,
		crc_en => en_crc,
		data_in => tx_data,
		crc_out => test_buf
	);
	
	uut_r: crc_gen port 
	map(
		clk => tx_clk,
		rst => fcs_rst,
		crc_en => en_crc,
		data_in => tx_data_r,
		crc_out => test_buf_r
	);

	-- ------------------------------------------------------------------------------------------
	--                              0x4C11DB7 (hex)
	-- CRC width:                   32 bits
	-- CRC shift direction:         left (big endian)
	-- Input word width:            4 bits

	-- tx_data(3) <= frame(476);
	-- tx_data(2) <= frame(477);
	-- tx_data(1) <= frame(478);
	-- tx_data(0) <= frame(479);
	-- crc : 0382837F

	-- tx_data <= frame(479 downto 476);
	-- crc : E6F3801F
	
	-- tx_data_r(3) <= frame_r(476);
	-- tx_data_r(2) <= frame_r(477);
	-- tx_data_r(1) <= frame_r(478);
	-- tx_data_r(0) <= frame_r(479);
	-- crc : 947984F5

	-- tx_data_r <= frame_r(479 downto 476);
	-- crc : 101A5CF1

	-- ------------------------------------------------------------------------------------------
	--                              0xEDB88320 (hex)
	-- CRC width:                   32 bits
	-- CRC shift direction:         right (little endian)
	-- Input word width:            4 bits

	tx_data(3) <= frame(476);
	tx_data(2) <= frame(477);
	tx_data(1) <= frame(478);
	tx_data(0) <= frame(479);
	-- crc : F801CF67

	-- tx_data <= frame(479 downto 476);
	-- crc : FEC141C0
	
	tx_data_r(3) <= frame_r(476);
	tx_data_r(2) <= frame_r(477);
	tx_data_r(1) <= frame_r(478);
	tx_data_r(0) <= frame_r(479);
	-- crc : 8F3A5808

	-- tx_data_r <= frame_r(479 downto 476);
	-- crc : AF219E29

	-- ------------------------------------------------------------------------------------------
	
	process begin

		fcs_rst <= '0';
		tx_clk <= '0'; wait for 1 ns;
		tx_clk <= '1'; wait for 1 ns;
		fcs_rst <= '1';


		en_crc <= '1';
		for i in 120 downto 0 loop
			tx_clk <= '0'; wait for 1 ns;
			frame <= std_logic_vector(shift_left(unsigned(frame), 4));
			frame_r <= std_logic_vector(shift_left(unsigned(frame_r), 4));
			tx_clk <= '1'; wait for 1 ns;	
		end loop ;
		
		report "Entity: data_in=" & to_hstring(std_ulogic_vector(test_buf)) & "h";
		assert false report "crc_gen test done" severity note;

		wait; 
	end process;
end test;