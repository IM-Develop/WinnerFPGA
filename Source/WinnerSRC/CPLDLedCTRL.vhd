library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity CPLDLedCTRL is
	port(
		 nReset    		: in std_logic;
		 UartClk       	: in std_logic;--27MHz
--*********************** Global signals *****************************************
		 CPLDLed		: buffer std_logic_vector(5 downto 0)
		);
end CPLDLedCTRL;

ARCHITECTURE Arc_CPLDLedCTRL OF CPLDLedCTRL IS

	signal	Puls1HzCounter		: std_logic_vector(31 downto 0);
	
	signal	PWM10Khz			: std_logic_vector(15 downto 0);
	
BEGIN

	PWM_Proc : process(nReset, UartClk)
		begin	
			if (nReset = '0')then
				Puls1HzCounter <= (others => '0');
				CPLDLed <= "111110";
			else
				if rising_edge (UartClk)then
					if (Puls1HzCounter = x"019BFCC0") then
						CPLDLed <= CPLDLed(4 downto 0) & CPLDLed(5);
						Puls1HzCounter <= (others => '0');
					else
						CPLDLed <= CPLDLed;
						Puls1HzCounter <= Puls1HzCounter + 1;
					end if;
				end if;
			end if;
		end process PWM_Proc;

END Arc_CPLDLedCTRL;