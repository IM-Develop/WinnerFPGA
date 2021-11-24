library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.WinnerPKG.all;

entity WinnerSyncOutput is
	port(
		 nReset   				: in std_logic;
		 Clk     				: in std_logic;
--*********************** Global signals *****************************************
		 s0_read				: in std_logic;
		 s0_write				: in std_logic;
		 s0_chipselect			: in std_logic;
		 s0_address				: in std_logic_vector(4 downto 0);
		 s0_readdata			: buffer std_logic_vector(15 downto 0);
		 s0_writedata			: in std_logic_vector(15 downto 0);
--************************* Avalon-MM Slave **************************************
		 SystemTimer			: in std_logic_vector(63 downto 0);
		 Output     			: buffer std_logic
--*********************** External signals ***************************************
		);
end WinnerSyncOutput;

ARCHITECTURE Arc_WinnerSyncOutput OF WinnerSyncOutput IS

	type States is(T1, T2, T3);
	signal 	State 		: States;

	signal	Enable		: std_logic;
	signal	Phase		: std_logic;
	
	signal	EventTime	: std_logic_vector(63 downto 0);

BEGIN

	Avalon_Proc : process(nReset, Clk)
		begin	
			if (nReset = '0')then
				Enable <= '0';
				Phase <= '0';
				EventTime <= (others => '0');
				s0_readdata	<= (others => '0');
			else
				if rising_edge (Clk)then
					if (s0_write = '1' and s0_chipselect = '1') then
						case s0_address is
							when "00000" =>
								Enable <= s0_writedata(0);
								Phase <= s0_writedata(1);
							when "00100" =>
								EventTime(15 downto 0) <= s0_writedata;
							when "00110" =>
								EventTime(31 downto 16) <= s0_writedata;
							when "01000" =>
								EventTime(47 downto 32) <= s0_writedata;
							when "01010" =>
								EventTime(63 downto 48) <= s0_writedata;
							when others =>
								null;
						end case;
					end if;
					if (s0_read = '1' and s0_chipselect = '1') then
						case s0_address is
							when "00000" =>
								s0_readdata <= x"000"&'0'&Output&Phase&Enable;
							when "00100" =>
								s0_readdata <= EventTime(15 downto 0);
							when "00110" =>
								s0_readdata <= EventTime(31 downto 16);
							when "01000" =>
								s0_readdata <= EventTime(47 downto 32);
							when "01010" =>
								s0_readdata <= EventTime(63 downto 48);
							when others =>
								s0_readdata <= x"0000";
						end case;
					else
						s0_readdata <= x"0000";
					end if;
				end if;
			end if;
		end process Avalon_Proc;

	Tx_Proc : process(nReset, Clk)
		begin
			if (nReset = '0') then
				Output <= '0';
			else
				if rising_edge(Clk) then
					if (EventTime = SystemTimer and Enable = '1') then
						Output <= Phase;
					else
						Output <= Output;
					end if;
				end if;
			end if;
		end process Tx_Proc;

END Arc_WinnerSyncOutput;

