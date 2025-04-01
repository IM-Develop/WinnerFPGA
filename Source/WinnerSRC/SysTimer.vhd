library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SysTimer is
	port(
		 nReset   				: in std_logic;
		 Clk     				: in std_logic;--125MHz
		 FPGA_VIDCLK			: in std_logic;--27MHz (25MHz in versa)
--*********************** Global signals *****************************************
		 s0_read				: in std_logic;
		 s0_write				: in std_logic;
		 s0_chipselect			: in std_logic;
		 s0_address				: in std_logic_vector(3 downto 0);
		 s0_readdata			: buffer std_logic_vector(31 downto 0);
		 s0_writedata			: in std_logic_vector(31 downto 0);
--************************* Avalon-MM Slave **************************************
		 SystemTimer			: buffer std_logic_vector(63 downto 0);
		 SyncOut				: buffer std_logic
		);
end SysTimer;

ARCHITECTURE Arc_SysTimer OF SysTimer IS

    -- shared variable SysTimerSig : std_logic_vector(63 downto 0);
	signal	SysTimerSig	: std_logic_vector(63 downto 0);
	signal	Counter		: std_logic_vector(7 downto 0);
	-- signal	CountEN		: std_logic;

BEGIN

	Avalon_Proc : process(nReset, Clk)
		begin	
			if (nReset = '0')then
				SystemTimer <= (others => '0');
				s0_readdata	<= (others => '0');
				-- CountEN <= '0';
			else
				if rising_edge (Clk)then
					SystemTimer <= SysTimerSig;
					-- if (s0_write = '1' and s0_chipselect = '1') then
						-- CountEN <= '0';
						-- case s0_address is
							-- when x"0" =>
								-- SysTimerSig(15 downto 0) := s0_writedata;
							-- when x"2" =>
								-- SysTimerSig(31 downto 16) := s0_writedata;
							-- when x"4" =>
								-- SysTimerSig(47 downto 32) := s0_writedata;
							-- when x"6" =>
								-- SysTimerSig(63 downto 48) := s0_writedata;
							-- when others =>
								-- null;
						-- end case;
					-- else
						-- if (SyncOut = '1') then
							-- CountEN <= '1';
							-- if (CountEN = '0') then
								-- SystemTimer <= SystemTimer + 1;
							-- else
								-- SystemTimer <= SystemTimer;
							-- end if;
						-- else
							-- SystemTimer <= SystemTimer;
							-- CountEN <= '0';
						-- end if;
					-- end if;
					if (s0_read = '1' and s0_chipselect = '1') then
						case s0_address is
							when x"0" =>
								s0_readdata <= SystemTimer(31 downto 0);
							when x"4" =>
								s0_readdata <= SystemTimer(63 downto 32);
							when others =>
								s0_readdata	<= (others => '0');
						end case;
					end if;
				end if;
			end if;
		end process Avalon_Proc;

	Clocked_Proc : process(nReset, FPGA_VIDCLK)
		begin
			if (nReset = '0')then
				SysTimerSig <= (others => '0');
				Counter <= x"00";
				SyncOut <= '0';
			else
				if rising_edge (FPGA_VIDCLK)then
					-- if (Counter = x"1A") then--1uSec At 27MHz
					if (Counter >= x"18") then--1uSec At 25MHz
						Counter <= x"00";
						SyncOut <= '1';
						SysTimerSig <= SysTimerSig + 1;
					else
						Counter <= Counter + 1;
						SyncOut <= '0';
						SysTimerSig <= SysTimerSig;
					end if;
				end if;
			end if;
		end process Clocked_Proc;

END Arc_SysTimer;