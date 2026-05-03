library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart_rx is
end entity tb_uart_rx;

architecture sim of tb_uart_rx is
	-- DUT signals
	signal clk: std_logic := '0';
	signal rst: std_logic := '0';
	signal baud_req_wire: std_logic; -- Shared with baud gen
	signal baud_wire: std_logic := '0';
	signal rx: std_logic := '1';
	signal byte_received: std_logic_vector(7 downto 0) := (others => '0');
	-- signal err: std_logic; -- Unused at present

	-- Test data
	type uart_data_t is array (0 to 3) of std_logic_vector(7 downto 0);
	constant uart_data: uart_data_t := (x"DE", x"AD", x"BE", x"EF");

	-- Sim signals
	constant clk_T: time := 10 ns;
	constant baud_T: time := 868 ns;
	constant baud_115200_100M: integer := 868;
	signal simDone: std_logic := '0';
begin
	rx_dut: entity work.uart_rx
		port map (
			clk=>clk,
			rst=>rst,
			baud_req=>baud_req_wire,
			baud_in=>baud_wire, 
			rx=>rx,
			byte_received=>byte_received,
			err=>open	
		);

	baud_gen: entity work.baud_gen
		port map (
			clk=>clk,
			rst=>rst,
			baud_req_rx=>baud_req_wire,
			baud_out_rx=>baud_wire,
			baud_out_tx=>open		
		);

	clk_proc: process
	begin
		while simDone='0' loop
			clk <= not clk;
			wait for clk_T/2;
		end loop;
		wait;
	end process clk_proc;

	stim_proc: process
	begin
		-- Prep idle
		rx <= '1';
		wait for baud_T*10;
	
		for present_byte in uart_data'range loop
			-- Start bit
			rx <= '0';
			wait for baud_T;

			-- Data bits
			for present_bit in uart_data(present_byte)'range loop
				rx <= uart_data(present_byte)(present_bit);
				wait for baud_T;	
			end loop;
			
			-- Parity bit
			-- Fake for now
			rx <= '1';
			wait for baud_T;

			-- Stop bit
			rx <= '1';
			wait for baud_T;
		end loop;

		simDone <= '1';
		wait;	
	end process stim_proc;
end architecture sim;
