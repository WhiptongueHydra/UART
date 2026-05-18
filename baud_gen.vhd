library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity baud_gen is
    generic ( 
        clk_freq: Positive := 125000000;
        baud_rate: Positive := 115200
    );
	port (
		clk: in std_logic;
		rst: in std_logic;
	
		baud_req_rx: in std_logic;
		baud_req_tx: in std_logic;
		
		baud_out_rx: out std_logic;
		baud_out_tx: out std_logic
	);
end entity baud_gen;


architecture A1 of baud_gen is
    -- Updated for any baud
    constant max_count: integer := clk_freq/baud_rate;
    constant half_count: integer := max_count / 2;

	signal half_done: std_logic := '0'; -- Defo a sleeker way to do this
	signal counter_rx: integer range 0 to max_count-1 := 0;
    signal counter_tx: integer range 0 to max_count-1 := 0;	
    
begin
	rx_proc: process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				baud_out_rx <= '0';
				counter_rx <= 0;
				half_done <= '0';
			else
			       	baud_out_rx <= '0';	
				if baud_req_rx='1' then
					if half_done='1' then
						if counter_rx < max_count-1 then
							counter_rx <= counter_rx + 1;	
						else
							counter_rx <= 0;
							baud_out_rx <= '1';
						end if;	
					else
						if counter_rx < half_count-1 then
							counter_rx <= counter_rx + 1;
						else
							counter_rx <= 0;
							half_done <= '1';
						end if;
					end if;
				else
					counter_rx <= 0;
					half_done <= '0';
				end if;				
			end if;
		end if;
	end process rx_proc;

	tx_proc: process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				baud_out_tx <= '0';
				counter_tx <= 0;
			else
			    baud_out_tx <= '0';
			    if baud_req_tx='1' then
                    if counter_tx < max_count-1 then
                        counter_tx <= counter_tx + 1;
                    else
                        counter_tx <= 0;
                        baud_out_tx <= '1';
                    end if;	
				end if;
			end if;
		end if;
	end process;
end architecture A1;
