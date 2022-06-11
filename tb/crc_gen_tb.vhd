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

	function reverse_any_vector (a: in std_logic_vector)
	return std_logic_vector is
	variable result: std_logic_vector(a'RANGE);
	alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
	begin
	for i in aa'RANGE loop
		result(i) := aa(i);
	end loop;
	return result;
	end; -- function reverse_any_vector


	signal tx_clk: std_logic := '0';
	signal fcs_rst: std_logic := '1';
	signal en_crc: std_logic := '0';
	signal tx_data: std_logic_vector(3 downto 0);
	signal tx_data_r: std_logic_vector(3 downto 0);
	signal test_buf: std_logic_vector(31 downto 0) 	:= x"00000000";
	signal test_buf_r: std_logic_vector(31 downto 0):= x"00000000";
	signal out_buf: std_logic_vector(31 downto 0):= x"00000000";
	signal out_buf_r: std_logic_vector(31 downto 0):= x"00000000";
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


	tx_data <= frame(479 downto 476);

	tx_data_r(3) <= frame(476);
	tx_data_r(2) <= frame(477);
	tx_data_r(1) <= frame(478);
	tx_data_r(0) <= frame(479);

	out_buf <= reverse_any_vector(test_buf);
	out_buf_r <= reverse_any_vector(test_buf_r);

	process begin

		fcs_rst <= '0';
		tx_clk <= '0'; wait for 1 ns;
		tx_clk <= '1'; wait for 1 ns;
		fcs_rst <= '1';

		en_crc <= '1';
		for i in 121 downto 0 loop
			tx_clk <= '0'; wait for 1 ns;
			tx_clk <= '1'; wait for 1 ns;	
			frame <= std_logic_vector(shift_left(unsigned(frame), 4));
			frame_r <= std_logic_vector(shift_left(unsigned(frame_r), 4));
			if i < 3 then
				if i = 1 then
					report "---";
				end if;

				report "crc   = 0x" & to_hstring(std_ulogic_vector(test_buf));
				report "crc_r = 0x" & to_hstring(std_ulogic_vector(test_buf_r));
				report "out   = 0x" & to_hstring(std_ulogic_vector(out_buf));
				report "out_r = 0x" & to_hstring(std_ulogic_vector(out_buf_r));

				if i = 1 then
					report "---";
				end if;
			end if;
		end loop ;

			
		assert false report "crc_gen test done" severity note;

		wait; 
	end process;
end test;