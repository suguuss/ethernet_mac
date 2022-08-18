library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
	generic (
		FIFO_SIZE: integer := 92
	);
	port (
		clk: 		in 		std_logic;
		rst_n: 		in 		std_logic;
		enable: 	in 		std_logic;
		write_en:	in		std_logic;
		data_in: 	in 		std_logic_vector(3 downto 0) := (others => '0');
		data_out: 	out 	std_logic_vector(3 downto 0) := (others => '0');
		full: 		out 	std_logic := '0'
	);
end fifo;

architecture behavioral of fifo is

	constant BYTE_SIZE: integer :=  4;

	signal counter: 	integer := 0;
	signal fifo_data: 	std_logic_vector(BYTE_SIZE*FIFO_SIZE-1 downto 0) := (3 downto 0 => '1', others => '0');
	signal buffer_full: std_logic := '0';

begin

	data_out <= fifo_data(3 downto 0);

	process (clk)
	begin
		if rising_edge(clk) then
			-- CHECK IF BUFFER IS FULL
			if counter >= (FIFO_SIZE-1) then
				full <= '1';
				buffer_full <= '1';
			else
				full <= '0';
				buffer_full <= '0';
			end if;

			if rst_n = '0' then
				counter <= 0;
				buffer_full <= '0';
			else
				if write_en = '1' then
					if enable = '1' and buffer_full = '0' then
						counter <= counter + 1;
						fifo_data <= data_in & fifo_data(BYTE_SIZE*FIFO_SIZE-1 downto 4);
					end if;
				else
					if enable = '1' then
						if counter > 0 then
							counter <= counter - 1;
						end if;
						fifo_data <= x"0" & fifo_data(BYTE_SIZE*FIFO_SIZE-1 downto 4);
					end if;
				end if;
			end if;
		end if;
	end process;

end behavioral ; -- behavioral