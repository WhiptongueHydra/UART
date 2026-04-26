library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx is
       port (
       		clk: in std_logic;
		rst: in std_logic;
		
       		baud_in: in std_logic;
       		rx: in std_logic;
       	
		byte_received: out std_logic_vector(7 downto 0);
       		err: in std_logic -- For parity errors
	);
end entity rx;

architecture A1 of rx is
	type uart_state is (idle, receiving, done);
	signal p_state, n_state: uart_state := idle;
	-- Enough room for data and parity
	signal shift_reg: std_logic_vector(8 downto 0) := (others => '1');
begin
	shifter_proc: process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				shift_reg <= (others => '1');
			else
				if baud_in='1' then
					shift_reg <= shift_reg(8 downto 1) & rx;
				end if;	
			end if;
		end if;
	end process shifter_proc;

	sync_state_changer: process(clk)
	begin
		if rising_edge(clk) then
			p_state <= n_state;	
		end if;
	end process sync_state_changer;

	comb_proc: process(p_state, rx) 
	begin
		case p_state is
			when idle =>
				if rx='0' then
					n_state <= receiving;
				else
					n_state <= idle;	
				end if;	
			when receiving =>
				
			when done =>

			when others =>
				NULL;
		end case;
	end process comb_proc;


end architecture A1;
