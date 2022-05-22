-- ethernet_package.vhd
-- Type definition and functions used for the ethernet
-- 13/05/2022

library ieee;
use ieee.std_logic_1164.all;

package ethernet_pkg is

	constant BYTE_SIZE : integer := 8;

	type t_ethernet_header is record
		mac_dst : std_logic_vector(6*BYTE_SIZE-1 downto 0);
		mac_src : std_logic_vector(6*BYTE_SIZE-1 downto 0);
		ip_type : std_logic_vector(2*BYTE_SIZE-1 downto 0);
	end record t_ethernet_header;

end package ethernet_pkg;