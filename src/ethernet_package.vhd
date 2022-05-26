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

	function ChangeEndian(vec : std_ulogic_vector) return std_ulogic_vector;
	function ChangeEndian(vec : std_logic_vector) return std_logic_vector;
	
end package ethernet_pkg;
	
package body ethernet_pkg is

	-- changes the endianess BIG <-> LITTLE
	function ChangeEndian(vec : std_ulogic_vector) return std_ulogic_vector is
		variable vRet      : std_ulogic_vector(vec'range);
		constant cNumBytes : natural := vec'length / 8;
	begin


		for i in 0 to cNumBytes-1 loop
			for j in 7 downto 0 loop
				vRet(8*i + j) := vec(8*(cNumBytes-1-i) + j);
			end loop;  -- j
		end loop;  -- i


		return vRet;
	end function ChangeEndian;


	function ChangeEndian(vec : std_logic_vector) return std_logic_vector is
	begin
		return std_logic_vector(ChangeEndian(std_ulogic_vector(vec)));
	end function ChangeEndian;

end package body;