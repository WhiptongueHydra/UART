library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
	generic (
		positive_parity: std_logic := '1'	
	);
	port (

		clk: in std_logic;
		rst: in std_logic;

		tx: out std_logic;

		baud_req: out std_logic;
		baud_in: in std_logic;
		data_in: in std_logic_vector(7 downto 0);

		start_flag: in std_logic
	);
end entity uart_tx;

architecture A1 of uart_tx is
	type uart_tx_state is (idle, latch, transmitting);
	signal p_state, n_state: uart_tx_t := idle;	

	signal data_reg: std_logic_vector(7 downto 0) := (others => '0');
	signal shift_reg: std_logic_vector(10 downto 0) := (others => '0'); 
	signal parity_reg: std_logic := '1';

	signal tx_ctrl: std_logic := '1';
	signal latch_flag: std_logic := '0';

	function parity_check(test_data: std_logic_vector(data_in'range) := (others => '0'); parity_type: std_logic := '1') return std_logic is
		variable running_positive_parity: std_logic := '0'; -- Because 0 xor A = A identity  
	begin
		for i in (test_data'range) loop
			running_positive_parity := running_positive_parity xor test_data(i);
		end loop;

		if parity_type='1' then
			return running_positive_parity;
		else
			return (not running_positive_parity);
		end if;
	end function parity_check;

begin
	tx <= '1' when tx_ctrl='1' else shift_reg(0);

	parity_reg <= parity_check(data_in);	


	shift_reg_proc: process(clk) begin	
	begin
		if rising_edge(clk) then
			if rst='1' then
				shift_reg <= (others => '1');		
			else
				if latch_flag <= '1' then
					shift_reg(0) <= '0';
					shift_reg(8 downto 1) <= data_in;
					shift_reg(9) <= parity_reg;
					shift_reg(10) <= '1';
				end if;

				if baud='1' then
					shift_reg <= '1' & shift_reg(10 downto 1);
				end if;
			end if;
		end if;
	end process shift_reg;

	sync_proc: process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				p_state <= idle;
			else
				p_state <= n_state;
			end if;
		end if;
	end process sync_proc;

	comb_state_proc: process(p_state, start_flag)
	begin
		case p_state is
			when idle =>
				baud_req <= '0';
				latch_flag <= '0';
				n_state <= idle;
				tx_ctrl <= '1';
				if start_flag='1' then
					n_state <= latch;
				end if;

			when latch =>
				tx_ctrl <= '1';
				latch_flag <= '1';
				baud_req <= '1';
				n_state <= transmitting;

			when transmitting =>
				latch_flag <= '0';
				n_state <= transmitting;
				baud_req <= '1';
				tx_ctrl <= '0';
			 	if done='1' then
					n_state <= idle;
				end if;		

			when others =>
				NULL;
		end case;
	end process comb_state_proc;
end architecture A1;
