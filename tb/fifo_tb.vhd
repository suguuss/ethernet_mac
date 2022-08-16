library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_tb is
end fifo_tb;

architecture test of fifo_tb is
	component fifo
		generic (
			FIFO_SIZE: integer := 46
		);
		port (
			clk: 		in 		std_logic;
			rst: 		in 		std_logic;
			enable: 	in 		std_logic;
			write_en: 	in 		std_logic;
			data_in: 	in 		std_logic_vector(7 downto 0);
			data_out: 	out 	std_logic_vector(7 downto 0);
			full: 		out 	std_logic
		);
	end component;

	signal clk, en, full: 	std_logic := '0';
	signal rst, rw:			std_logic := '0';
	signal data_in:			std_logic_vector(7 downto 0) := (others => '0');
	signal data_out:		std_logic_vector(7 downto 0) := (others => '0');
begin 
	uut: fifo 
	generic map (
		FIFO_SIZE => 20
	)
	port map(
		clk => clk,
		rst => rst,
		enable => en,
		write_en => rw,
		data_in => data_in,
		data_out => data_out,
		full => full
	);


	process begin

		wait for 10 ns;

		en <= '1';
		rw <= '1';

		for i in 0 to 12 loop
			clk <= '0'; wait for 5 ns;
			data_in <= std_logic_vector(to_unsigned(i, data_in'length));
			clk <= '1'; wait for 5 ns;
		end loop;
		
		rw <= '0';

		for i in 0 to 12 loop
			clk <= '0'; wait for 5 ns;
			data_in <= std_logic_vector(to_unsigned(i, data_in'length));
			clk <= '1'; wait for 5 ns;
		end loop;
		


		-- clk <= '0'; wait for 5 ns;
		-- data_in <= x"01";
		-- clk <= '1'; wait for 5 ns;

		-- en <= '1'; wait for 1 ns;

		-- clk <= '0'; wait for 5 ns;
		-- data_in <= x"01";
		-- clk <= '1'; wait for 5 ns;

		-- clk <= '0'; wait for 5 ns;
		-- data_in <= x"02";
		-- clk <= '1'; wait for 5 ns;

		-- clk <= '0'; wait for 5 ns;
		-- data_in <= x"03";
		-- clk <= '1'; wait for 5 ns;

		-- clk <= '0'; wait for 5 ns;
		-- data_in <= x"04";
		-- clk <= '1'; wait for 5 ns;


		assert false report "test done" severity note;

		wait; 
	end process;
end test;