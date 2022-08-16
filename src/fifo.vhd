library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
	port (
		clk: 		in 		std_logic;
		rst: 		in 		std_logic;
		enable: 	in 		std_logic;
		data_in: 	in 		std_logic_vector(7 downto 0) := (others => '0');
		data_out: 	out 	std_logic_vector(7 downto 0) := (others => '0');
		full: 		out 	std_logic
	);
end fifo;

architecture behavioral of fifo is

	constant FIFO_SIZE: integer := 10;
	constant BYTE_SIZE: integer :=  8;

	signal counter: 	integer := 0;
	signal fifo_data: 	std_logic_vector(BYTE_SIZE*FIFO_SIZE-1 downto 0) := (others => '0');
	signal buffer_full: std_logic;

begin

	data_out <= fifo_data(7 downto 0);

	

	process (clk)
	begin
		if rising_edge(clk) then
			-- CHECK IF BUFFER IS FULL
			if counter = FIFO_SIZE then
				full <= '1';
				buffer_full <= '1';
			else
				full <= '0';
				buffer_full <= '0';
			end if;

			if rst = '1' then
				counter <= 0;
			else
				if enable = '1' and buffer_full = '0' then
					counter <= counter + 1;
					fifo_data <= data_in & fifo_data(BYTE_SIZE*FIFO_SIZE-1 downto 8);
				end if;
			end if;
		end if;
	end process;

end behavioral ; -- behavioral