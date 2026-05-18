library ieee;
use ieee.std_logic_1164.all;

package uart_pkg is 
    function parity_check(test_data: std_logic_vector := (others => '0'); parity_type: std_logic := '1') return std_logic;
end package uart_pkg;
    
package body uart_pkg is
    function parity_check(test_data: std_logic_vector := (others => '0'); parity_type: std_logic := '1') return std_logic is
		variable running_positive_parity: std_logic := '0'; -- Because 0 xor A = A identity  
	begin
		for i in test_data'range loop
			running_positive_parity := running_positive_parity xor test_data(i);
		end loop;

		if parity_type='1' then
			return running_positive_parity;
		else
			return (not running_positive_parity);
		end if;
	end function parity_check;
end package body;
