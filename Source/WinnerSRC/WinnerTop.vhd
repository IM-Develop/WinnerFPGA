library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity WinnerTop is
	port(
		 RefClkp				: in std_logic;
		 RefClkn				: in std_logic;
		 nReset					: in std_logic;
--*********************** Global signals *****************************************
		 pPCIeIn				: in std_logic;
		 nPCIeIn				: in std_logic;
		 pPCIeOut				: out std_logic;
		 nPCIeOut				: out std_logic;
--*********************** PCIe signals *******************************************
		 MIPI0_SELECT			: out std_logic;
		 MIPI1_SELECT			: out std_logic;
		 FPGA_VIDCLK			: in std_logic;
		 -- CL_SPR					: out std_logic_vector(3 downto 0);
--*********************** Global signals *****************************************
		 COM					: inout std_logic;--
		 COM_DE					: out std_logic;--RS485
		 -- COM_PF					: inout std_logic;--
		 -- COM_PF_DE				: out std_logic;--RS485
		 COM_SAFE_ARM_OUT		: out std_logic;--
		 COM_SAFE_ARM_IN		: in std_logic;--RS422
		 COM_WH					: inout std_logic;
		 COM_WH_DE				: out std_logic;--RS485
		 PIB_COM				: inout std_logic;--
		 PIB_COM_DE				: out std_logic;--RS485
		 SERVO_COM				: inout std_logic;--
		 SERVO_COM_DE			: out std_logic;--RS485
		 SN_2_GPS_DAT			: out std_logic;--
		 GPS_2_SN_DAT			: in std_logic;--RS422
		 GPS_2_SN_CLK			: in std_logic;--RS422
		 SN_2_IMU_CLK			: out std_logic;--
		 SN_2_IMU_DAT			: out std_logic;--
		 IMU_2_SN_DAT			: in std_logic;--RS422
		 IMU_2_SN_CLK			: in std_logic;--RS422
		 TEL_CLK				: inout std_logic;--
		 TEL_CLK_DE				: out std_logic;--RS485
		 TEL_COM_RS485_1		: inout std_logic;
		 TEL_COM_RS485_1_DE		: out std_logic;--RS485
		 TEL_COM_RS485_2		: inout std_logic;
		 TEL_COM_RS485_2_DE		: out std_logic;--RS485
		 TEL_COM_RS485_3		: inout std_logic;
		 TEL_COM_RS485_3_DE		: out std_logic;--RS485
		 TEL_COM_RS485_4		: inout std_logic;
		 TEL_COM_RS485_4_DE		: out std_logic;--RS485
		 TEL_COM_RS485_5		: inout std_logic;--
		 TEL_COM_RS485_5_DE		: out std_logic;--RS485
		 VIDEO_SYNC				: inout std_logic;
		 VIDEO_SYNC_DE			: out std_logic;--RS485
		 SN_2_ZABAD				: out std_logic;--
		 ZABAD_2_SN				: in std_logic--RS422
--************************* UARTs signals ****************************************
		);
end WinnerTop;

ARCHITECTURE Arc_WinnerTop OF WinnerTop IS

	component top_basic
		port(   
			 refclkp				: in std_logic;
			 refclkn				: in std_logic;
			 rstn					: in std_logic;
			 SysClk					: out std_logic;--125MHz
			 hdinp					: in std_logic;
			 hdinn					: in std_logic;
			 hdoutp					: out std_logic;
			 hdoutn					: out std_logic;
			 Cycle					: out std_logic;
			 STB					: out std_logic;
			 WRIn					: out std_logic;
			 SelectIn				: out std_logic_vector(1 downto 0);
			 CTI					: out std_logic_vector(2 downto 0);
			 Addrss					: out std_logic_vector(31 downto 0);
			 DataIn					: out std_logic_vector(15 downto 0);
			 DataOut				: in std_logic_vector(15 downto 0);
			 ACK					: in std_logic;
			 -- ERR					: in std_logic;
			 -- RTY					: in std_logic;
			 CA_PD					: out std_logic_vector(12 downto 0);
			 CA_NPH					: out std_logic_vector(8 downto 0);
			 DL_UP					: out std_logic;
			 MSIIn					: in std_logic_vector(7 downto 0)
			);
	end component;
	
	component WinnerSRCTop
		-- generic	(
				 -- Version			: std_logic_vector(31 downto 0) := x"FCAB0001"
				-- );
		port(
			 nReset					: in std_logic;--avalon #reset
			 Clk					: in std_logic;--avalon clock 125MHz
			 FPGA_VIDCLK			: in std_logic;--27MHz
	--*********************** Global signals *****************************************
			 Cycle					: in std_logic;
			 STB					: in std_logic;
			 WRIn					: in std_logic;
			 SelectIn				: in std_logic_vector(1 downto 0);
			 CTI					: in std_logic_vector(2 downto 0);
			 Addrss					: in std_logic_vector(31 downto 0);
			 DataIn					: in std_logic_vector(15 downto 0);
			 DataOut				: buffer std_logic_vector(15 downto 0);
			 ACK					: buffer std_logic;
			 ERR					: out std_logic;
			 RTY					: out std_logic;
			 CA_PD					: in std_logic_vector(12 downto 0);
			 CA_NPH					: in std_logic_vector(8 downto 0);
			 DL_UP					: in std_logic;
			 MSI					: out std_logic_vector(7 downto 0);
	--************************* Avalon-MM Slave **************************************
			 COM					: inout std_logic;--
			 COM_DE					: out std_logic;--RS485
			 -- COM_PF					: inout std_logic;--
			 -- COM_PF_DE				: out std_logic;--RS485
			 COM_SAFE_ARM_OUT		: out std_logic;--
			 COM_SAFE_ARM_IN		: in std_logic;--RS422
			 COM_WH					: inout std_logic;
			 COM_WH_DE				: out std_logic;--RS485
			 PIB_COM				: inout std_logic;--
			 PIB_COM_DE				: out std_logic;--RS485
			 SERVO_COM				: inout std_logic;--
			 SERVO_COM_DE			: out std_logic;--RS485
			 SN_2_GPS_DAT			: out std_logic;--
			 GPS_2_SN_DAT			: in std_logic;--RS422
			 GPS_2_SN_CLK			: in std_logic;--RS422
			 SN_2_IMU_CLK			: out std_logic;--
			 SN_2_IMU_DAT			: out std_logic;--
			 IMU_2_SN_DAT			: in std_logic;--RS422
			 IMU_2_SN_CLK			: in std_logic;--RS422
			 TEL_CLK				: inout std_logic;--
			 TEL_CLK_DE				: out std_logic;--RS485
			 TEL_COM_RS485_1		: inout std_logic;
			 TEL_COM_RS485_1_DE		: out std_logic;--RS485
			 TEL_COM_RS485_2		: inout std_logic;
			 TEL_COM_RS485_2_DE		: out std_logic;--RS485
			 TEL_COM_RS485_3		: inout std_logic;
			 TEL_COM_RS485_3_DE		: out std_logic;--RS485
			 TEL_COM_RS485_4		: inout std_logic;
			 TEL_COM_RS485_4_DE		: out std_logic;--RS485
			 TEL_COM_RS485_5		: inout std_logic;--
			 TEL_COM_RS485_5_DE		: out std_logic;--RS485
			 VIDEO_SYNC				: inout std_logic;
			 VIDEO_SYNC_DE			: out std_logic;--RS485
			 SN_2_ZABAD				: out std_logic;--
			 ZABAD_2_SN				: in std_logic--RS422
	--************************* export signals ***************************************
			);
	end component;
	
	signal	SysClk		: std_logic;
	signal	Cycle		: std_logic;
	signal	STB			: std_logic;
	signal	WRIn		: std_logic;
	signal	SelectIn	: std_logic_vector(1 downto 0);
	signal	CTI			: std_logic_vector(2 downto 0);
	signal	Addrss		: std_logic_vector(31 downto 0);
	signal	DataIn		: std_logic_vector(15 downto 0);
	signal	DataOut		: std_logic_vector(15 downto 0);
	signal	ACK			: std_logic;
	-- signal	ERR			: std_logic;
	-- signal	RTY			: std_logic;
	signal	CA_PD		: std_logic_vector(12 downto 0);
	signal	CA_NPH		: std_logic_vector(8 downto 0);
	signal	DL_UP		: std_logic;
	signal	MSI			: std_logic_vector(7 downto 0);

	-- signal	BaudCount	: std_logic_vector(31 downto 0);
	
	-- constant BaudRate  	: std_logic_vector(31 downto 0) := x"0000043D";

BEGIN

	-- BaudRateGenerator_Proc : process(nReset, SysClk)
		-- begin
			-- if (nReset = '0') then
				-- BaudCount <= (others => '0');
				-- COM <= '0';
				-- COM_PF <= '0';
				-- COM_SAFE_ARM_OUT <= '0';
				-- COM_WH <= '0';
				-- PIB_COM <= '0';
				-- SERVO_COM <= '0';
				-- SN_2_GPS_DAT <= '0';
				-- SN_2_IMU_CLK <= '0';
				-- SN_2_IMU_DAT <= '0';
				-- TEL_CLK <= '0';
				-- TEL_COM_RS485_1 <= '0';
				-- TEL_COM_RS485_2 <= '0';
				-- TEL_COM_RS485_3 <= '0';
				-- TEL_COM_RS485_4 <= '0';
				-- TEL_COM_RS485_5 <= '0';
				-- VIDEO_SYNC <= '0';
				-- SN_2_ZABAD <= '0';
			-- else
				-- if rising_edge(SysClk) then
					-- if (BaudCount = BaudRate) then
						-- BaudCount <= (others => '0');
						-- COM <= not(COM);
						-- COM_PF <= not(COM_PF);
						-- COM_SAFE_ARM_OUT <= not(COM_SAFE_ARM_OUT);
						-- COM_WH <= not(COM_WH);
						-- PIB_COM <= not(PIB_COM);
						-- SERVO_COM <= not(SERVO_COM);
						-- SN_2_GPS_DAT <= not(SN_2_GPS_DAT);
						-- SN_2_IMU_CLK <= not(SN_2_IMU_CLK);
						-- SN_2_IMU_DAT <= not(SN_2_IMU_DAT);
						-- TEL_CLK <= not(TEL_CLK);
						-- TEL_COM_RS485_1 <= not(TEL_COM_RS485_1);
						-- TEL_COM_RS485_2 <= not(TEL_COM_RS485_2);
						-- TEL_COM_RS485_3 <= not(TEL_COM_RS485_3);
						-- TEL_COM_RS485_4 <= not(TEL_COM_RS485_4);
						-- TEL_COM_RS485_5 <= not(TEL_COM_RS485_5);
						-- VIDEO_SYNC <= not(VIDEO_SYNC);
						-- SN_2_ZABAD <= not(SN_2_ZABAD);
					-- else
						-- BaudCount <= BaudCount + 1;
					-- end if;
				-- end if;
			-- end if;
		-- end process BaudRateGenerator_Proc;

	-- VIDEO_SYNC_DE <= '1';
	-- COM_DE <= '1';
	-- COM_PF_DE <= '1';
	-- COM_WH_DE <= '1';
	-- PIB_COM_DE <= '1';
	-- SERVO_COM_DE <= '1';
	-- TEL_CLK_DE <= '1';
	-- TEL_COM_RS485_1_DE <= '1';
	-- TEL_COM_RS485_2_DE <= '1';
	-- TEL_COM_RS485_3_DE <= '1';
	-- TEL_COM_RS485_4_DE <= '1';
	-- TEL_COM_RS485_5_DE <= '1';
	-- VIDEO_SYNC_DE <= '1';

	U1 : top_basic
		port map(   
				 refclkp => RefClkp,
				 refclkn => RefClkn,
				 rstn => nReset,
				 SysClk => SysClk,
				 hdinp => pPCIeIn,
				 hdinn => nPCIeIn,
				 hdoutp => pPCIeOut,
				 hdoutn => nPCIeOut,
				 Cycle => Cycle,
				 STB => STB,
				 WRIn => WRIn,
				 SelectIn => SelectIn,
				 CTI => CTI,
				 Addrss => Addrss,
				 DataIn => DataIn,
				 DataOut => DataOut,
				 ACK => ACK,
				 -- ERR					: in std_logic;
				 -- RTY					: in std_logic;
				 CA_PD => CA_PD,
				 CA_NPH => CA_NPH,
				 DL_UP => DL_UP,
				 MSIIn => MSI
				);
				
	U2 : WinnerSRCTop
		-- generic	map(
				 -- Version				=> x"FCAB0002"
				-- )
		port map(
				 nReset					=> nReset,
				 Clk					=> SysClk,
				 FPGA_VIDCLK			=> FPGA_VIDCLK,
				 Cycle					=> Cycle,
				 STB					=> STB,
				 WRIn					=> WRIn,
				 SelectIn				=> SelectIn,
				 CTI					=> CTI,
				 Addrss					=> Addrss,
				 DataIn					=> DataIn,
				 DataOut				=> DataOut,
				 ACK					=> ACK,
				 -- ERR					=> ERR,
				 -- RTY					=> RTY,
				 CA_PD					=> CA_PD,
				 CA_NPH					=> CA_NPH,
				 DL_UP					=> DL_UP,
				 MSI					=> MSI,
				 COM					=> COM,
				 COM_DE					=> COM_DE,
				 -- COM_PF					=> COM_PF,
				 -- COM_PF_DE				=> COM_PF_DE,
				 COM_SAFE_ARM_OUT		=> COM_SAFE_ARM_OUT,
				 COM_SAFE_ARM_IN		=> COM_SAFE_ARM_IN,
				 COM_WH					=> COM_WH,
				 COM_WH_DE				=> COM_WH_DE,
				 PIB_COM				=> PIB_COM,
				 PIB_COM_DE				=> PIB_COM_DE,
				 SERVO_COM				=> SERVO_COM,
				 SERVO_COM_DE			=> SERVO_COM_DE,
				 SN_2_GPS_DAT			=> SN_2_GPS_DAT,
				 GPS_2_SN_DAT			=> GPS_2_SN_DAT,
				 GPS_2_SN_CLK			=> GPS_2_SN_CLK,
				 SN_2_IMU_CLK			=> SN_2_IMU_CLK,
				 SN_2_IMU_DAT			=> SN_2_IMU_DAT,
				 IMU_2_SN_DAT			=> IMU_2_SN_DAT,
				 IMU_2_SN_CLK			=> IMU_2_SN_CLK,
				 TEL_CLK				=> TEL_CLK,
				 TEL_CLK_DE				=> TEL_CLK_DE,
				 TEL_COM_RS485_1		=> TEL_COM_RS485_1,
				 TEL_COM_RS485_1_DE		=> TEL_COM_RS485_1_DE,
				 TEL_COM_RS485_2		=> TEL_COM_RS485_2,
				 TEL_COM_RS485_2_DE		=> TEL_COM_RS485_2_DE,
				 TEL_COM_RS485_3		=> TEL_COM_RS485_3,
				 TEL_COM_RS485_3_DE		=> TEL_COM_RS485_3_DE,
				 TEL_COM_RS485_4		=> TEL_COM_RS485_4,
				 TEL_COM_RS485_4_DE		=> TEL_COM_RS485_4_DE,
				 TEL_COM_RS485_5		=> TEL_COM_RS485_5,
				 TEL_COM_RS485_5_DE		=> TEL_COM_RS485_5_DE,
				 VIDEO_SYNC				=> VIDEO_SYNC,
				 VIDEO_SYNC_DE			=> VIDEO_SYNC_DE,
				 SN_2_ZABAD				=> SN_2_ZABAD,
				 ZABAD_2_SN				=> ZABAD_2_SN
				);

END Arc_WinnerTop;
