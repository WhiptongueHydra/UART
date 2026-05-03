library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart_rx is
       port (
       		clk: in std_logic;
		rst: in std_logic;
		
       		baud_req: out std_logic;
       		baud_in: in std_logic;
       		rx: in std_logic;

		byte_received: out std_logic_vector(7 downto 0);
       		err: out std_logic -- For parity errors
	);
end entity uart_rx;


architecture A1 of uart_rx is
	type uart_state is (idle, receiving);
	signal p_state, n_state: uart_state := idle;
	-- Enough room for data and parity
	signal shift_reg: std_logic_vector(8 downto 0) := (others => '1');
	signal latched_rx: std_logic_vector(8 downto 0) := (others => '1');

	signal baud_en: std_logic := '0';
	signal done: std_logic := '0';

	signal count_en: std_logic := '0'; 
	constant max_count: integer := 8; 
	signal counter: integer range 0 to 8 := 0;

	signal parity_int: std_logic := '0';
begin
	latched_rx <= shift_reg when done='1' else latched_rx;
	byte_received <= latched_rx(8 downto 1);
	baud_req <= baud_en;

	shifter_proc: process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				shift_reg <= (others => '1');
			else
				--if done='1' then
				--	latched_rx <= shift_reg;
				--end if;		
			
				-- Not sure how I feel about this actually. 	
				if baud_in='1' then
					-- shift_reg <= shift_reg(8 downto 1) & rx;
					-- Im an idiot, comment of shame. ^
					shift_reg <= shift_reg(7 downto 0) & rx;
				end if;						
			end if;
		end if;
	end process shifter_proc;

	sync_state_changer: process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				p_state <= idle;
			else
				p_state <= n_state;	
			end if;
		end if;
	end process sync_state_changer;

	counter_proc: process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				counter <= 0;
			else
				done <= '0';
				if baud_in='1' then
					if counter < max_count then
						counter <= counter + 1;
					else
						counter <= 0;
						done <= '1';
					end if;
				end if;
			end if;
		end if;
	end process counter_proc;

	-- Need to add baud rate requester tomorrow to external module
	-- Also need to write test bench
	comb_proc: process(p_state, rx, done) 
	begin
		n_state <= p_state;
		count_en <= '0';
		baud_en <= '0';
		case p_state is
			when idle =>				
				if rx='0' then
					n_state <= receiving;
					baud_en <= '1';	
				end if;	
			when receiving =>
				baud_en <= '1';
				if done='1' then
					n_state <= idle;
				end if;		
			when others =>
				NULL;
		end case;
	end process comb_proc;
end architecture A1;

