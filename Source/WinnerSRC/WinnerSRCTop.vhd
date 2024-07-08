library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.WinnerPKG.all;

entity WinnerSRCTop is
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
		 COM_SAFE_ARM_OUT		: out std_logic;--SEU_LSR_COM/LSR_SEU_COM
		 COM_SAFE_ARM_IN		: in std_logic;--RS422
--		RS422
		 SN_2_GPS_DAT			: out std_logic;--LASER_SEU_COM/SEU_LASER_COM
		 GPS_2_SN_DAT			: in std_logic;--RS422
--		RS422
		 SN_2_IMU_DAT			: out std_logic;--Servo_SEU_COM/SEU_Servo_COM
		 IMU_2_SN_DAT			: in std_logic;--RS422
--		RS422
		 SN_2_IMU_CLK			: out std_logic;--DIMU_SEU_COM/SEU_DIMU_COM
		 IMU_2_SN_CLK			: in std_logic;--RS422
--		RS422
		 SN_2_ZABAD				: out std_logic;--RS422_RX_Spare2/RS422_TX_Spare2
		 ZABAD_2_SN				: in std_logic;--RS422
--		RS422
		 TEL_COM_RS485_1		: inout std_logic;--RS485/RS422_RX_Spare1
		 TEL_COM_RS485_1_DE		: out std_logic;--RS485
		 TEL_COM_RS485_2		: inout std_logic;--RS422_TX_Spare1
		 TEL_COM_RS485_2_DE		: out std_logic;--RS485
--		RS422
		 TEL_COM_RS485_3		: inout std_logic;--SERVO 232 Debug_TX/SERVO 232 Debug_RX
		 TEL_COM_RS485_3_DE		: out std_logic;--RS485
		 TEL_COM_RS485_4		: inout std_logic;
		 TEL_COM_RS485_4_DE		: out std_logic;--RS485
--		RS422
		 TEL_COM_RS485_5		: inout std_logic;--ESC_AGG_COM
		 TEL_COM_RS485_5_DE		: out std_logic;--RS485
--		RS485
		 COM					: inout std_logic;--MCC RS422 Comm
		 COM_DE					: out std_logic;--RS485
		 COM_WH					: inout std_logic;
		 COM_WH_DE				: out std_logic;--RS485
--		RS422
		 GPS_2_SN_CLK			: in std_logic;--RS422
--		Input IO
		 VIDEO_SYNC				: inout std_logic;
		 VIDEO_SYNC_DE			: out std_logic;--RS485
--		Input IO
		 SERVO_COM				: inout std_logic;--
		 SERVO_COM_DE			: out std_logic;--RS485
--		Input IO
		 TEL_CLK				: inout std_logic;--
		 TEL_CLK_DE				: out std_logic;--RS485
--		Output IO
		 -- COM_PF					: inout std_logic;--
		 -- COM_PF_DE				: out std_logic;--RS485
		 PIB_COM				: inout std_logic;--
		 PIB_COM_DE				: out std_logic--;--RS485
--		Spare
--************************* export signals ***************************************
		);
end WinnerSRCTop;

ARCHITECTURE Arc_WinnerSRCTop OF WinnerSRCTop IS

	component WinnerUART
		port(
			 nReset   				: in std_logic;
			 Clk     				: in std_logic;
			 -- Clk108MHz				: in std_logic;
	--*********************** Global signals *****************************************
			 s0_read				: in std_logic;
			 s0_write				: in std_logic;
			 s0_chipselect			: in std_logic;
			 s0_address				: in std_logic_vector(4 downto 0);
			 s0_readdata			: buffer std_logic_vector(15 downto 0);
			 -- s0_readdatavalid		: out std_logic;
			 s0_writedata			: in std_logic_vector(15 downto 0);
			 -- s0_waitrequest			: out std_logic;
	--************************* Avalon-MM Slave **************************************
			 SystemTimer			: in std_logic_vector(63 downto 0);
			 RS485EN				: in std_logic;
			 Int     				: buffer std_logic;--interrupt on ready and end of trans
			 DIR					: buffer std_logic;
			 RxD     				: in std_logic;
			 TxD     				: out std_logic;
	--*********************** External signals ***************************************
			 TestOut				: out std_logic--;
			 -- TrigOut				: buffer std_logic
			);
	end component;

	component SysTimer
		port(
			 nReset   				: in std_logic;
			 Clk     				: in std_logic;--125MHz
			 FPGA_VIDCLK			: in std_logic;--27MHz
	--*********************** Global signals *****************************************
			 s0_read				: in std_logic;
			 s0_write				: in std_logic;
			 s0_chipselect			: in std_logic;
			 s0_address				: in std_logic_vector(3 downto 0);
			 s0_readdata			: buffer std_logic_vector(15 downto 0);
			 s0_writedata			: in std_logic_vector(15 downto 0);
	--************************* Avalon-MM Slave **************************************
			 SystemTimer			: buffer std_logic_vector(63 downto 0);
			 SyncOut				: buffer std_logic
			);
	end component;
	
	component WinnerSyncInput
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
	end component;

	component WinnerSyncOutput
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
	end component;

	component Pll27MHz is
		port(
			 Module_Pll27MHz_CLKI	: in std_logic;
			 Module_Pll27MHz_CLKOP	: out std_logic;
			 Module_Pll27MHz_CLKOS	: out std_logic;
			 Module_Pll27MHz_LOCK	: out std_logic
			);
	end component Pll27MHz; -- sbp_module=true 
	
	signal 	RD			: std_logic;
	signal	WR			: std_logic;
	-- signal	Data		: std_logic_vector(15 downto 0);
	
	signal	ScratchPad	: std_logic_vector(31 downto 0);
	
	signal	DebugReg	: std_logic_vector(15 downto 0);
	
	subtype Reg is std_logic_vector(15 downto 0);
	type matrix is array (0 to 19) of Reg;
	
	signal	DataOutReg		: matrix;
	
	-- signal	UARTReadValid	: std_logic_vector(16 downto 0);--number of UARTS
	signal	ChipSelect		: std_logic_vector(31 downto 0);--number of UARTS;
	signal	Irq				: std_logic_vector(31 downto 0);--number of UARTS;
	signal	RxD, TxD, DIR	: std_logic_vector(16 downto 0);--number of UARTS;
	signal	RS485EN			: std_logic_vector(16 downto 0);--number of UARTS;
	signal	IRQMaskReg		: std_logic_vector(31 downto 0);
	signal	IRQReg			: std_logic_vector(31 downto 0);
	signal	HoldIRQReg		: std_logic_vector(31 downto 0);
	signal	EnableReg		: std_logic_vector(31 downto 0);
	
	signal	InputIO			: std_logic_vector(2 downto 0);
	
	signal	SystemTimer		: std_logic_vector(63 downto 0);
	
	signal	Clk108MHz		: std_logic;
	signal	Clk27MHz		: std_logic;
	signal	nReset108MHz	: std_logic;
	
	signal	TestOut			: std_logic_vector(31 downto 0);
	-- signal	TrigOut			: std_logic_vector(31 downto 0);
	signal	SyncOut			: std_logic;
	
	signal	ClrIRQ			: std_logic_vector(1 downto 0);
	signal	MSISSF			: std_logic_vector(15 downto 0);
	
BEGIN

	COM_SAFE_ARM_OUT		<= TxD(0);--test
	RxD(0)					<= COM_SAFE_ARM_IN;
	RS485EN(0)				<= '0';--RS422
--************** SEU_LSR_COM/LSR_SEU_COM **************
	SN_2_GPS_DAT			<= TxD(1);
	RxD(1)					<= GPS_2_SN_DAT;--optocapular
	RS485EN(1)				<= '0';--RS422
--************** LASER_SEU_COM/SEU_LASER_COM **********
	SN_2_IMU_DAT			<= TxD(2);
	RxD(2)					<= IMU_2_SN_DAT;
	RS485EN(2)				<= '0';--RS422
--************** Servo_SEU_COM/SEU_Servo_COM **********
	SN_2_IMU_CLK			<= TxD(3);
	RxD(3)					<= IMU_2_SN_CLK;
	RS485EN(3)				<= '0';--RS422
--************** DIMU_SEU_COM/SEU_DIMU_COM ************
	SN_2_ZABAD				<= TxD(4);
	RxD(4)					<= ZABAD_2_SN;
	RS485EN(4)				<= '0';--RS422
--************** RS422_RX_Spare2/RS422_TX_Spare2 ******
	TEL_COM_RS485_1			<= TxD(5);
	TEL_COM_RS485_1_DE		<= '1';--Transmit
	RxD(5)					<= TEL_COM_RS485_2;
	TEL_COM_RS485_2_DE		<= '0';--recieve
	RS485EN(5)				<= '0';--RS422
--************** RS422_RX_Spare1/RS422_TX_Spare1 ******
	TEL_COM_RS485_3			<= TxD(6);
	TEL_COM_RS485_3_DE		<= '1';--Transmit
	RxD(6)					<= TEL_COM_RS485_4;
	TEL_COM_RS485_4_DE		<= '0';--recieve
	RS485EN(6)				<= '0';--RS422
--************** SERVO 232 Debug_TX/SERVO 232 Debug_RX *
	TEL_COM_RS485_5			<= TxD(7) when(DIR(7) = '1') else 'Z';
	RxD(7)					<= TEL_COM_RS485_5;
	TEL_COM_RS485_5_DE		<= DIR(7);
	RS485EN(7)				<= '1';--RS485
--************** ESC_AGG_COM ***************************
	COM						<= TxD(8);
	COM_DE					<= '1';--Transmit
	RxD(8)					<= COM_WH;
	COM_WH_DE				<= '0';--recieve
	RS485EN(8)				<= '0';--RS422
--************** AGG MCC RS422 Comm ********************
	InputIO(0)				<= GPS_2_SN_CLK;
--************** DATA_VALID Input IO *******************
	InputIO(1)				<= VIDEO_SYNC;
	VIDEO_SYNC_DE			<= '0';--recieve
--************** DIMU_Sync_400Hz Input IO **************
	InputIO(2)				<= SERVO_COM;
	SERVO_COM_DE			<= '0';--recieve
--************** SEU_SYNC Input IO *********************

	RD <= STB and Cycle and not(WRIn);
    WR <= STB and Cycle and WRIn;
	
	ChipSelect <= ChipSelect_func(Addrss(12 downto 8), Cycle) when(Addrss(13) = '0') else (others => '0');--inon 9.12.19
	DataOut <= DataOutReg(conv_integer(Addrss(12 downto 8))) when(Addrss(13) = '0') else--inon 9.12.19
			   (others => '0');
	
	ERR <= '0';
	RTY <= '0';
		   
	Irq(0) <= ScratchPad(0) and Cycle and ChipSelect(0) and DataIn(0);--create irq from bit 0 of scratchpad register
	Irq(31 downto 10) <= (others => '0');

	UART_Gen : for i in 1 to 9 generate--0x100 -> 0x900
		U1 : WinnerUART
			port map(
					 nReset   				=> EnableReg(i),
					 Clk     				=> Clk,
					 -- Clk108MHz				=> Clk,--Clk108MHz,
					 s0_read				=> RD,
					 s0_write				=> WR,
					 s0_chipselect			=> ChipSelect(i),
					 s0_address				=> Addrss(4 downto 0),
					 s0_readdata			=> DataOutReg(i),
					 -- s0_readdatavalid		=> UARTReadValid(i),
					 s0_writedata			=> DataIn,
					 SystemTimer			=> SystemTimer,
					 RS485EN				=> RS485EN(i-1),
					 Int     				=> Irq(i),
					 DIR					=> DIR(i-1),
					 RxD     				=> RxD(i-1),
					 TxD     				=> TxD(i-1),
					 TestOut				=> TestOut(i)--,
					 -- TrigOut				=> TrigOut(i)
					);
	end generate UART_Gen;
	
	U2 : SysTimer--0xA00
		port map(
				 nReset   				=> nReset,
				 Clk     				=> Clk,
				 FPGA_VIDCLK			=> Clk27MHz,
				 s0_read				=> RD,
				 s0_write				=> WR,
				 s0_chipselect			=> ChipSelect(10),
				 s0_address				=> Addrss(3 downto 0),
				 s0_readdata			=> DataOutReg(10),
				 s0_writedata			=> DataIn,
				 SystemTimer			=> SystemTimer,
				 SyncOut				=> SyncOut
				);
				
	PIB_COM <= 	TestOut(1) when(DebugReg(3 downto 0) = x"1") else
				TestOut(2) when(DebugReg(3 downto 0) = x"2") else
				TestOut(3) when(DebugReg(3 downto 0) = x"3") else
				TestOut(4) when(DebugReg(3 downto 0) = x"4") else
				TestOut(5) when(DebugReg(3 downto 0) = x"5") else
				TestOut(6) when(DebugReg(3 downto 0) = x"6") else
				TestOut(7) when(DebugReg(3 downto 0) = x"7") else
				TestOut(8) when(DebugReg(3 downto 0) = x"8") else
				TestOut(9) when(DebugReg(3 downto 0) = x"9") else
				SyncOut	   when(DebugReg(3 downto 0) = x"A") else
				ClrIRQ(0)  when(DebugReg(3 downto 0) = x"B") else
				MSISSF(15) when(DebugReg(3 downto 0) = x"C") else
				-- TrigOut(3) when(DebugReg(3 downto 0) = x"D") else
				-- TrigOut(5) when(DebugReg(3 downto 0) = x"E") else
				'1';
				
	PIB_COM_DE <= '1';
				
	InputIO_Gen : for i in 11 to 13 generate--0xB00 -> 0xD00
		U3 : WinnerSyncInput
			port map(
					 nReset   				=> nReset,
					 Clk     				=> Clk,
					 s0_read				=> RD,
					 s0_write				=> WR,
					 s0_chipselect			=> ChipSelect(i),
					 s0_address				=> Addrss(4 downto 0),
					 s0_readdata			=> DataOutReg(i),
					 s0_writedata			=> DataIn,
					 SystemTimer			=> SystemTimer,
					 Input     				=> InputIO(i-11)
					);
	end generate InputIO_Gen;
	
	U4 : WinnerSyncOutput--0xE00
		port map(
				 nReset   				=> nReset,
				 Clk     				=> Clk,
				 s0_read				=> RD,
				 s0_write				=> WR,
				 s0_chipselect			=> ChipSelect(14),
				 s0_address				=> Addrss(4 downto 0),
				 s0_readdata			=> DataOutReg(14),
				 s0_writedata			=> DataIn,
				 SystemTimer			=> SystemTimer,
				 Output     			=> TEL_CLK
				);
				
	U5 : Pll27MHz
		port map(
				 Module_Pll27MHz_CLKI	=> FPGA_VIDCLK,
				 Module_Pll27MHz_CLKOP	=> Clk108MHz,
				 Module_Pll27MHz_CLKOS	=> Clk27MHz,
				 Module_Pll27MHz_LOCK	=> nReset108MHz
				);
				
	TEL_CLK_DE <= '1';--Transmit
	
	PCIe_Proc : process(nReset, Clk)
		begin	
			if (nReset = '0')then
				ACK <= '0';
				DataOutReg(0) <= (others => '0');
				ScratchPad <= (others => '0');
				IRQMaskReg <= (others => '0');
				IRQReg <= (others => '0');
				HoldIRQReg <= (others => '0');
				MSI <= x"00";
				EnableReg <= (others => '0');
				DebugReg <= x"0000";
				ClrIRQ <= "00";
				MSISSF <= x"0000";
			else
				if rising_edge (Clk)then
					ACK <= Cycle and STB and not(ACK);
					IRQReg <= Irq and IRQMaskReg;
					if (IRQReg /= 0) then
						MSI <= x"01";
						MSISSF <= x"FFFF";
						HoldIRQReg <= HoldIRQReg or IRQReg;
					else
						MSI <= x"00";
						MSISSF <= MSISSF(14 downto 0) & '0';
						if (ClrIRQ(0) = '1' and RD = '0') then
							HoldIRQReg(15 downto 0) <= (others => '0');
						else
							HoldIRQReg(15 downto 0) <= HoldIRQReg(15 downto 0);
						end if;
						if (ClrIRQ(1) = '1' and RD = '0') then
							HoldIRQReg(31 downto 16) <= (others => '0');
						else
							HoldIRQReg(31 downto 16) <= HoldIRQReg(31 downto 16);
						end if;
					end if;
					if (ChipSelect(0) = '1') then
						case Addrss(7 downto 0) is
							when x"00" =>
								if (RD = '1') then
									DataOutReg(0) <= Version(15 downto 0);
								end if;
							when x"02" =>
								if (RD = '1') then
									DataOutReg(0) <= Version(31 downto 16);
								end if;
							when x"04" =>
								if (RD = '1') then
									DataOutReg(0) <= ScratchPad(15 downto 0);
								elsif (WR = '1') then
									ScratchPad(15 downto 0) <= DataIn;
								end if;
							when x"06" =>
								if (RD = '1') then
									DataOutReg(0) <= ScratchPad(31 downto 16);
								elsif (WR = '1') then
									ScratchPad(31 downto 16) <= DataIn;
								end if;
							when x"08" =>
								if (RD = '1') then
									DataOutReg(0) <= EnableReg(15 downto 0);
								elsif (WR = '1') then
									EnableReg(15 downto 0) <= DataIn;
								end if;
							when x"0A" =>
								if (RD = '1') then
									DataOutReg(0) <= EnableReg(31 downto 16);
								elsif (WR = '1') then
									EnableReg(31 downto 16) <= DataIn;
								end if;
							when x"0C" =>
								if (RD = '1') then
									DataOutReg(0) <= IRQMaskReg(15 downto 0);
								elsif (WR = '1') then
									IRQMaskReg(15 downto 0) <= DataIn;
								end if;
							when x"0E" =>
								if (RD = '1') then
									DataOutReg(0) <= IRQMaskReg(31 downto 16);
								elsif (WR = '1') then
									IRQMaskReg(31 downto 16) <= DataIn;
								end if;
							when x"10" =>
								if (RD = '1') then
									DataOutReg(0) <= HoldIRQReg(15 downto 0);
									ClrIRQ(0) <= '1';
									-- HoldIRQReg(15 downto 0) <= x"0000" or IRQReg(15 downto 0);
								end if;
							when x"12" =>
								if (RD = '1') then
									DataOutReg(0) <= HoldIRQReg(31 downto 16);
									ClrIRQ(1) <= '1';
									-- HoldIRQReg(31 downto 16) <= x"0000" or IRQReg(31 downto 16);
								end if;
							when x"14" =>
								if (RD = '1') then
									DataOutReg(0) <= DebugReg;
								elsif (WR = '1') then
									DebugReg <= DataIn;
								end if;
							when others =>
								DataOutReg(0) <= (others => '0');
								ClrIRQ <= "00";
						end case;
					else
						-- if (IRQReg /= 0) then
							-- HoldIRQReg <= HoldIRQReg or IRQReg;
						-- else
							-- HoldIRQReg <= HoldIRQReg;
						-- end if;
						DataOutReg(0) <= (others => '0');
						ClrIRQ <= "00";
					end if;
				end if;
			end if;
		end process PCIe_Proc;

END Arc_WinnerSRCTop;