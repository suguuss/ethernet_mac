library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_fifo_tb is
end rx_fifo_tb;

architecture test of rx_fifo_tb is
	component rx_fifo
		generic (
			FIFO_SIZE: integer := 92
		);
		port (
			clk: 		in 		std_logic;
			rst_n: 		in 		std_logic;
			enable: 	in 		std_logic;
			write_en:	in		std_logic;
			packet_rdy:	in		std_logic;
			data_in: 	in 		std_logic_vector(3 downto 0) := (others => '0');
			data_out: 	out 	std_logic_vector(3 downto 0) := (others => '0');
			full: 		out 	std_logic := '0'
		);
	end component;

	signal clk, en, full: 	std_logic := '0';
	signal rst, rw:			std_logic := '0';
	signal data_in:			std_logic_vector(3 downto 0) := (others => '0');
	signal data_out:		std_logic_vector(3 downto 0) := (others => '0');
	signal packet_ready: 	std_logic := '0';
begin 
	uut: rx_fifo
	generic map (
		FIFO_SIZE => 20
	)
	port map(
		clk => clk,
		rst_n => rst,
		enable => en,
		write_en => rw,
		packet_rdy => packet_ready,
		data_in => data_in,
		data_out => data_out,
		full => full
	);


	process begin

		rst <= '1';

		wait for 10 ns;

		en <= '1';
		rw <= '1';

		for i in 0 to 12 loop
			clk <= '0'; wait for 5 ns;
			data_in <= std_logic_vector(to_unsigned(i, data_in'length));
			clk <= '1'; wait for 5 ns;
		end loop;
		
		en <= '0';
		rw <= '0';
		
		packet_ready <= '1';
		clk <= '0'; wait for 1 ns;
		clk <= '1'; wait for 1 ns;
		packet_ready <= '0';

		en <= '1';
		rw <= '0';

		for i in 0 to 12 loop
			clk <= '0'; wait for 5 ns;
			data_in <= std_logic_vector(to_unsigned(i, data_in'length));
			clk <= '1'; wait for 5 ns;
		end loop;

		assert false report "test done" severity note;

		wait; 
	end process;
end test;