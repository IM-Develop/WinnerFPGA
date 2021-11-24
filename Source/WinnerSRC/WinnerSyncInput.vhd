library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.WinnerPKG.all;

entity WinnerSyncInput is
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
		 Input     				: in std_logic
--*********************** External signals ***************************************
		);
end WinnerSyncInput;

ARCHITECTURE Arc_WinnerSyncInput OF WinnerSyncInput IS

	type States is(T1, T2, T3);
	signal 	State 		: States;

	signal	Debouncer	: std_logic_vector(3 downto 0);
	signal	DebouncerS	: std_logic_vector(2 downto 0);
	
	signal	Enable		: std_logic;
	signal	Latch		: std_logic;
	
	signal	InputHold	: std_logic;
	signal	EventCount	: std_logic_vector(31 downto 0);
	signal	RiseLatch	: std_logic_vector(63 downto 0);
	signal	FallLatch	: std_logic_vector(63 downto 0);
	
	signal	HoldReg		: std_logic_vector(159 downto 0);

BEGIN

	Debouncer_Proc : process(nReset, Clk)
		begin	
			if (nReset = '0')then
				Debouncer <= x"0";
				DebouncerS <= "111";
			else
				if rising_edge (Clk)then
					DebouncerS(0) <= Input;
					DebouncerS(1) <= DebouncerS(0);
					if (DebouncerS(0) = DebouncerS(1)) then
						if (Debouncer = x"4") then--9 clocks
							DebouncerS(2) <= DebouncerS(1);
							Debouncer <= x"4";
						else
							DebouncerS(2) <= DebouncerS(2);
							Debouncer <= Debouncer + 1;
						end if;
					else
						DebouncerS(2) <= DebouncerS(2);
						Debouncer <= x"0";
					end if;
				end if;
			end if;
		end process Debouncer_Proc;

	Avalon_Proc : process(nReset, Clk)
		begin	
			if (nReset = '0')then
				Enable <= '0';
				Latch <= '0';
				s0_readdata	<= (others => '0');
			else
				if rising_edge (Clk)then
					if (s0_write = '1' and s0_chipselect = '1') then
						case s0_address is
							when "00000" =>
								Enable <= s0_writedata(0);
								Latch <= s0_writedata(1);
							when others =>
								null;
						end case;
					else
						Enable <= Enable;
						Latch <= '0';
					end if;
					if (s0_read = '1' and s0_chipselect = '1') then
						case s0_address is
							when "00000" =>
								s0_readdata <= x"000"&'0'&DebouncerS(2)&Latch&Enable;
							when "00100" =>
								s0_readdata <= HoldReg(15 downto 0);
							when "00110" =>
								s0_readdata <= HoldReg(31 downto 16);
							when "01000" =>
								s0_readdata <= HoldReg(47 downto 32);
							when "01010" =>
								s0_readdata <= HoldReg(63 downto 48);
							when "01100" =>
								s0_readdata <= HoldReg(79 downto 64);
							when "01110" =>
								s0_readdata <= HoldReg(95 downto 80);
							when "10000" =>
								s0_readdata <= HoldReg(111 downto 96);
							when "10010" =>
								s0_readdata <= HoldReg(127 downto 112);
							when "10100" =>
								s0_readdata <= HoldReg(143 downto 128);
							when "10110" =>
								s0_readdata <= HoldReg(159 downto 144);
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
				InputHold <= '0';
				RiseLatch <= (others => '0');
			    FallLatch <= (others => '0');
				EventCount <= (others => '0');
				HoldReg <= (others => '0');
			else
				if rising_edge(Clk) then
					InputHold <= DebouncerS(2);
					if (Latch = '1') then
						HoldReg(63 downto 0) <= RiseLatch;
						HoldReg(127 downto 64) <= FallLatch;
						HoldReg(159 downto 128) <= EventCount;
					else
						HoldReg <= HoldReg;
					end if;
					if (Enable = '1') then
						if (InputHold /= DebouncerS(2)) then
							EventCount <= EventCount + 1;
							if (InputHold = '0') then
								RiseLatch <= SystemTimer;
								FallLatch <= FallLatch;
							else
								RiseLatch <= RiseLatch;
								FallLatch <= SystemTimer;
							end if;
						else
							RiseLatch <= RiseLatch;
							FallLatch <= FallLatch;
							EventCount <= EventCount;
						end if;
					else
						RiseLatch <= (others => '0');
						FallLatch <= (others => '0');
						EventCount <= (others => '0');
					end if;
				end if;
			end if;
		end process Tx_Proc;

END Arc_WinnerSyncInput;

