library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.WinnerPKG.all;

entity WinnerUART is
	port(
		 nReset   				: in std_logic;
		 Clk     				: in std_logic;
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
end WinnerUART;

ARCHITECTURE Arc_WinnerUART OF WinnerUART IS

	-- component FWFT_FIFO
		-- Generic(
				-- DATA_WIDTH  : positive := 8;
				-- FIFO_DEPTH	: positive := 256
				-- );
		-- Port( 
			 -- CLK		: in  STD_LOGIC;
			 -- nRST		: in  STD_LOGIC;
			 -- WriteEn	: in  STD_LOGIC;
			 -- DataIn	: in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
			 -- ReadEn	: in  STD_LOGIC;
			 -- DataOut	: out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
			 -- Empty	: out STD_LOGIC;
			 -- Full	: out STD_LOGIC
			-- );
	-- end component;

	component UARTFifo
		generic(
				DATA_WIDTH :integer := 8;
				ADDR_WIDTH :integer := 8
			   );
		port(
		   ---- Reading port.
			 Data_out   	: out std_logic_vector (DATA_WIDTH-1 downto 0);
			 Empty_out  	: out std_logic;
			 ReadEn_in  	: in  std_logic;
			 RClk       	: in  std_logic;
		   ---- Writing port.
			 Data_in    	: in  std_logic_vector (DATA_WIDTH-1 downto 0);
			 Full_out   	: out std_logic;
			 WriteEn_in 	: in  std_logic;
			 WClk       	: in  std_logic;
		 
			 nReset			: in  std_logic;
			 ByteCount		: buffer std_logic_vector(ADDR_WIDTH-1 downto 0)
			);
	end component;
	
	type States is(T1, T2, T3);
	signal 	RxState, TxState, TxTestState, IntState : States;--, MCUWrState, MCURdState

	-- signal	ReadState	: std_logic;

	-- signal	Reset		: std_logic;

	signal 	TxStart    	: std_logic;
	signal 	TxTestStart	: std_logic;
	signal 	BaudCount  	: std_logic_vector(15 downto 0);

	signal 	TxCount    	: std_logic_vector(5 downto 0);
	signal 	TxData     	: std_logic_vector(11 downto 0);--5-9bit, Parity, 1-2 stop
	signal 	TxTestCount	: std_logic_vector(3 downto 0);
	signal 	TxTestData 	: std_logic_vector(11 downto 0);--5-9bit, Parity, 1-2 stop

	signal 	RxData     	: std_logic_vector(11 downto 0);
	signal	RxBitCount	: std_logic_vector(3 downto 0);
	signal	RxByteCount	: std_logic_vector(1 downto 0);
	signal 	RxBaudCount : std_logic_vector(15 downto 0);

	signal 	TxRdReq    	: std_logic;
	signal 	TxWrReq    	: std_logic;
	signal 	TxEmpty    	: std_logic;
	signal 	TxFull		: std_logic;
	signal 	TxFifoIn  	: std_logic_vector(35 downto 0);
	signal 	TxFifoOut  	: std_logic_vector(35 downto 0);
	signal 	TxFifoUsed	: std_logic_vector(TxUartFifoSize-1 downto 0);
	signal	TxByte		: std_logic_vector(15 downto 0);

	signal 	RxRdReq    	: std_logic;
	signal 	RxWrReq    	: std_logic;
	signal	RxFifoWr	: std_logic;
	signal 	RxEmpty    	: std_logic;
	signal 	RxFull    	: std_logic;
	signal	RxDataPCheck: std_logic_vector(9 downto 0);
	signal 	RxFifoIn  	: std_logic_vector(31 downto 0);
	signal 	RxFifoOut  	: std_logic_vector(31 downto 0);
	signal 	RxFifoUsed	: std_logic_vector(UartFifoSize-1 downto 0);
	signal 	RxFifoUsedF	: std_logic_vector(UartFifoSize-1 downto 0);
	signal 	RxFifoUsedN	: std_logic_vector(UartFifoSize-1 downto 0);
	signal 	RxFifoUsedL	: std_logic_vector(31 downto 0);
	signal	ClrUseL		: std_logic;

	signal	Debouncer	: std_logic_vector(3 downto 0);
	signal	DebouncerS	: std_logic_vector(2 downto 0);
	
	signal	IrqMask		: std_logic_vector(1 downto 0);
	signal	WaterMark	: std_logic_vector(15 downto 0);
	
	signal	BaudRate	: std_logic_vector(15 downto 0);
	
	signal	Parity		: std_logic_vector(1 downto 0);--"X0" = no parity, "01" = Odd parity, "11" = Even Parity
	signal	StopBit		: std_logic;--'0' = 1 stop bit, '1' - 2 stop bit
	signal	NumberObit	: std_logic_vector(2 downto 0);--"000" = 5bit,..., "100" = 9bit
	
	signal	WaterMkInt	: std_logic;
	signal	SilnceInt	: std_logic;
	signal	IntSourceClr: std_logic;
	signal	InternalInt	: std_logic;
	signal	IntSource	: std_logic_vector(1 downto 0);	
	signal	Silence		: std_logic_vector(15 downto 0);
	
	signal	OneMicroC	: std_logic_vector(7 downto 0);
	signal	SilenceCount: std_logic_vector(15 downto 0);
	signal	EventTime	: std_logic_vector(63 downto 0);
	
	signal	Tx9ThBit	: std_logic_vector(1 downto 0);--inon 28.10.21
	
	signal	TxEn		: std_logic;
	signal	TxEnSig		: std_logic_vector(1 downto 0);
	signal	TxEnState	: std_logic;
	
	signal	FifoULQ		: std_logic_vector(15 downto 0);
	signal	FifoULD		: std_logic_vector(15 downto 0);
	signal	FifoULEmpty	: std_logic;
	signal	FifoULFull	: std_logic;
	signal	FifoULRdReq	: std_logic;
	signal	FifoULWr	: std_logic;

BEGIN

	U1 : UARTFifo--write fifo
		generic map(
					DATA_WIDTH => 36,
					ADDR_WIDTH => TxUartFifoSize
				   )
		port map(
				 Data_out   => TxFifoOut,
				 Empty_out  => TxEmpty,
				 ReadEn_in  => TxRdReq,
				 RClk       => Clk,
				 Data_in    => TxFifoIn,
				 Full_out   => TxFull,
				 WriteEn_in => TxWrReq,
				 WClk       => Clk,
				 nReset		=> nReset--,
				 -- ByteCount  => TxFifoUsed
				);
				
	-- U1 : FWFT_FIFO
		-- generic map(
					-- DATA_WIDTH  => 9,
					-- FIFO_DEPTH	=> 2048--UartSize
				   -- )
		-- port map(
				 -- CLK		=> Clk,
				 -- nRST		=> nReset,
				 -- WriteEn	=> TxWrReq,
				 -- DataIn		=> TxFifoIn,
				 -- ReadEn		=> TxRdReq,
				 -- DataOut	=> TxFifoOut,
				 -- Empty		=> TxEmpty,
				 -- Full		=> TxFull
				-- );

	U2 : UARTFifo--read fifo
		generic map(
					DATA_WIDTH => 32,
					ADDR_WIDTH => TxUartFifoSize
				   )
		port map(
				 Data_out   => RxFifoOut,
				 Empty_out  => RxEmpty,
				 ReadEn_in  => RxRdReq,
				 RClk       => Clk,
				 Data_in    => RxFifoIn,
				 Full_out   => RxFull,
				 WriteEn_in => RxFifoWr,--RxWrReq,
				 WClk       => Clk,
				 nReset		=> nReset--,
				 -- ByteCount  => RxFifoUsed
				);

	-- U2 : FWFT_FIFO
		-- generic map(
					-- DATA_WIDTH  => 10,
					-- FIFO_DEPTH	=> 2048--UartSize
				   -- )
		-- port map(
				 -- CLK		=> Clk,
				 -- nRST		=> nReset,
				 -- WriteEn	=> RxWrReq,
				 -- DataIn		=> RxFifoIn,
				 -- ReadEn		=> RxRdReq,
				 -- DataOut	=> RxFifoOut,
				 -- Empty		=> RxEmpty,
				 -- Full		=> RxFull
				-- );
				
	-- s0_waitrequest <= '0';

	FifoULD(UartFifoSize - 1 downto 0) <= RxFifoUsedF;
	FifoULD(15 downto UartFifoSize) <= (others => '0');
	FifoULWr <= '1' when(InternalInt = '1' and IntSource = "10") else '0';
	-- FifoULRdReq <= '1' when (ClrUseL = '1' and s0_read = '0') else '0';
	FifoULRdReq <= '1' when (ClrUseL = '1') else '0';
							
	U3 : UARTFifo--read fifo
		generic map(
					DATA_WIDTH => 16,
					ADDR_WIDTH => 4
				   )
		port map(
				 Data_out   => FifoULQ,
				 Empty_out  => FifoULEmpty,
				 ReadEn_in  => FifoULRdReq,
				 RClk       => Clk,
				 Data_in    => FifoULD,
				 Full_out   => FifoULFull,
				 WriteEn_in => FifoULWr,--RxWrReq,
				 WClk       => Clk,
				 nReset		=> nReset--,
				 -- ByteCount  => RxFifoUsed
				);

	Debouncer_Proc : process(nReset, Clk)
		begin	
			if (nReset = '0')then
				Debouncer <= x"0";
				DebouncerS <= "111";
			else
				if rising_edge (Clk)then
					DebouncerS(0) <= RxD;
					DebouncerS(1) <= DebouncerS(0);
					if (DebouncerS(0) = DebouncerS(1)) then
						if (Debouncer = x"8") then--9 clocks
							DebouncerS(2) <= DebouncerS(1);
							Debouncer <= x"8";
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
				-- s0_readdatavalid <= '0';
				RxRdReq <= '0';
				s0_readdata	<= (others => '0');
				TxWrReq <= '0';
				TxFifoIn <= (others => '0');
				TxByte <= (others => '0');
				IrqMask <= "00";
				WaterMark <= x"0001";
				Parity <= "00";--no parity
				StopBit <= '0';--1 stop bit
				NumberObit <= "011";--8bit
				BaudRate <= DefaultBaud;
				WaterMkInt <= '0';
				SilnceInt <= '0';
				IntSourceClr <= '0';
				Silence <= x"0000";
				Tx9ThBit <= "00";
				TxEn <= '0';
				ClrUseL <= '0';
			else
				if rising_edge (Clk)then
					if (s0_write = '1' and s0_chipselect = '1') then
						case s0_address is
							when "00100" =>--LSW write data
								TxWrReq <= '0';--not(TxWrReq);--'1';
								TxFifoIn(17 downto 0) <= '0' & s0_writedata(15 downto 8) & Tx9ThBit(0) & s0_writedata(7 downto 0);
								if (Tx9ThBit(0) = '1') then
									Tx9ThBit(1) <= '1';
								else
									Tx9ThBit(1) <= Tx9ThBit(1);
								end if;
							when "00110" =>--LSW write data
								TxWrReq <= not(TxWrReq);
								TxFifoIn(35 downto 18) <= '0' & s0_writedata(15 downto 8) & '0' & s0_writedata(7 downto 0);
							when "01000" =>--divider
								BaudRate <= s0_writedata;
							when "01010" =>--silence time [micro sec.]--divider
								Silence <= s0_writedata;
							when "01100" =>--water mark for irq
								WaterMark <= s0_writedata;
							when "01110" =>--water mark for irq
								Parity <= s0_writedata(1 downto 0);
								StopBit <= s0_writedata(2);
								NumberObit <= s0_writedata(5 downto 3);
								WaterMkInt <= s0_writedata(6);--enable water mark interrupt
								SilnceInt <= s0_writedata(7);--enable Silence time interrupt
								Tx9ThBit <= '0'&s0_writedata(8);--9th bit value
								TxEn <= s0_writedata(9);
							when "11100" =>
								TxByte <= s0_writedata;
							when others =>
								TxWrReq <= '0';
						end case;
					else
						TxWrReq <= '0';
						if (TxRdReq = '1') then
							if (TxByte < 4) then
								TxByte <= (others => '0');
							else
								TxByte <= TxByte - 4;
							end if;
						else
							TxByte <= TxByte;
						end if;
						if (Tx9ThBit = "11") then
							Tx9ThBit <= "00";
						else
							Tx9ThBit <= Tx9ThBit;
						end if;
						if (TxEnSig(1) = '1') then
							TxEn <= '0';
						else
							TxEn <= TxEn;
						end if;
					end if;
					if (s0_read = '1' and s0_chipselect = '1') then
						-- s0_readdatavalid <= '0';
						case s0_address is
							when "00000" =>--LSW read data
								RxRdReq <= '0';--not(RxRdReq);
								s0_readdata <= RxFifoOut(15 downto 0);
							when "00010" =>--LSW read data
								RxRdReq <= not(RxRdReq);
								s0_readdata <= RxFifoOut(31 downto 16);
							when "00100" =>--LSW write data
								-- s0_readdata(TxUartFifoSize-1 downto 0) <= TxFifoUsed;
								-- s0_readdata(15 downto TxUartFifoSize) <= (others => '0');
								s0_readdata <= TxByte;
							when "00110" =>--LSW write data
								s0_readdata(UartFifoSize-1 downto 0) <= RxFifoUsedN;--RxFifoUsed;
								s0_readdata(15 downto UartFifoSize) <= (others => '0');
							when "01000" =>--divider
								s0_readdata <= BaudRate;
							when "01010" =>--divider
								s0_readdata <= Silence;
							when "01100" =>--water mark for irq
								s0_readdata <= WaterMark;
							when "01110" =>--InternalInt status
								s0_readdata <= "000000" & TxEn & Tx9ThBit(0) & SilnceInt & WaterMkInt & NumberObit & StopBit & Parity;
							when "10000" =>
								s0_readdata <= EventTime(15 downto 0);
							when "10010" =>
								s0_readdata <= EventTime(31 downto 16);
							when "10100" =>
								s0_readdata <= EventTime(47 downto 32);
							when "10110" =>
								s0_readdata <= EventTime(63 downto 48);
							when "11000" =>
								IntSourceClr <= '1';
								s0_readdata <= x"00" & "000000" & IntSource;
							when "11100" =>
								ClrUseL <= '0';
								if (FifoULEmpty = '0') then
									s0_readdata <= FifoULQ;
								else
									s0_readdata <= x"0000";
								end if;
							when "11110" =>
								if (FifoULEmpty = '0') then
									ClrUseL <= not(ClrUseL);
									s0_readdata <= x"0000";
								else
									ClrUseL <= '0';
									s0_readdata <= x"0001";
								end if;
								-- ClrUseL <= '1';
								-- s0_readdata <= RxFifoUsedL(31 downto 16);
							when others =>
								RxRdReq <= '0';
								ClrUseL <= '0';
								IntSourceClr <= IntSourceClr;
								s0_readdata <= x"0000";
						end case;
					else
						RxRdReq <= '0';
						IntSourceClr <= '0';
						ClrUseL <= '0';
						s0_readdata <= x"0000";
					end if;
				end if;
			end if;
		end process Avalon_Proc;

	BaudRateGenerator_Proc : process(nReset, Clk)
		begin
			if (nReset = '0') then
				BaudCount <= (others => '0');
				TxStart <= '0';
			else
				if rising_edge(Clk) then
					if (BaudCount = BaudRate) then
						BaudCount <= (others => '0');
						TxStart <= '1';
					else
						BaudCount <= BaudCount + 1;
						TxStart <= '0';
					end if;
				end if;
			end if;
		end process BaudRateGenerator_Proc;

	Tx_Proc : process(nReset, Clk)
		begin
			if (nReset = '0') then
				TxData <= (others => '1');
				TxD <= '1';
				TxCount <= (others => '0');
				TxRdReq <= '0';
				DIR <= '0';
				TxState <= T1;
				TxEnSig <= "00";
				TxEnState <= '0';
				-- TxTestStart <= '0';
				-- TxTestCount <= x"0";
				-- TxTestData <= (others => '1');
				-- TrigOut <= '1';
				-- TxTestState <= T1;
			else
				if rising_edge(Clk) then
					case TxEnState is
						when '0' =>
							if (TxEn = '1' and TxEnSig = "00") then
								TxEnSig <= "01";
								TxEnState <= '1';
							elsif (TxEn = '0') then
								TxEnSig <= "00";
								TxEnState <= '0';
							else
								TxEnSig <= TxEnSig;
								TxEnState <= '0';
							end if;
						when others =>
							if (TxEmpty = '1' or TxByte = x"0000") then
								TxEnSig <= "10";
								TxEnState <= '0';
							else
								TxEnSig <= "01";
								TxEnState <= '1';
							end if;
					end case;
					case TxState is
						when T1 =>
							TxCount(3 downto 0) <= x"0";
							-- if (TxEmpty = '0' and TxEnSig(0) = '1' and TxByte /= x"0000") then
							if (TxEnSig(0) = '1' and TxByte /= x"0000") then
								if (TxStart = '1') then
									TxD <= '0';
									DIR <= '1';
									case TxCount(5 downto 4) is
										when "00" =>
											TxRdReq <= '1';
											TxData <= WriteData_func(Parity, NumberObit, TxFifoOut(35 downto 27));
										when "01" =>
											if (TxByte = x"0003") then
												TxRdReq <= '1';
											else
												TxRdReq <= '0';
											end if;
											TxData <= WriteData_func(Parity, NumberObit, TxFifoOut(26 downto 18));
										when "10" =>
											if (TxByte = x"0002") then
												TxRdReq <= '1';
											else
												TxRdReq <= '0';
											end if;
											TxData <= WriteData_func(Parity, NumberObit, TxFifoOut(17 downto 9));
										when others =>
											if (TxByte = x"0001") then
												TxRdReq <= '1';
											else
												TxRdReq <= '0';
											end if;
											TxData <= WriteData_func(Parity, NumberObit, TxFifoOut(8 downto 0));
									end case;
									TxState <= T2;
								else
									TxD <= '1';
									DIR <= '0';
									TxData <= (others => '1');
									TxRdReq <= '0';
									TxCount(5 downto 4) <= TxCount(5 downto 4);
									TxState <= T1;
								end if;
							else
								TxD <= '1';
								DIR <= '0';
						        TxData <= (others => '1');
						        TxRdReq <= '0';
								TxCount(5 downto 4) <= "11";
						        TxState <= T1;
							end if;
						when others =>
							TxRdReq <= '0';
							DIR <= '1';
							if (TxStart = '1') then
								TxD <= TxData(0);
								TxData <= '1' & TxData(11 downto 1);
								if (TxCount(3 downto 0) = UsedBits_Func(Parity, StopBit, NumberObit)) then
									TxCount(3 downto 0) <= x"0";
									if (TxCount(5 downto 4) = "00") then
										TxCount(5 downto 4) <= "11";
									else
										TxCount(5 downto 4) <= TxCount(5 downto 4) - 1;
									end if;
									TxState <= T1;
								else
									TxCount(3 downto 0) <= TxCount(3 downto 0) + 1;
									TxCount(5 downto 4) <= TxCount(5 downto 4);
									TxState <= T2;
								end if;
							else
								TxCount <= TxCount;
								TxState <= T2;
							end if;
					end case;
					-- case TxTestState is
						-- when T1 =>
							-- TxTestCount <= x"0";
							-- if (TxStart = '1' and TxTestStart = '1') then
								-- TxTestStart <= '0';
								-- TrigOut <= '0';
								-- TxTestData <= TxTestData;
								-- TxTestState <= T2;
							-- elsif (InternalInt = '1') then
								-- TxTestStart <= '1';
								-- TrigOut <= '1';
						        -- TxTestData <= WriteData_func(Parity, NumberObit, '1'&RxFifoUsed(7 downto 0));
						        -- TxTestState <= T1;
							-- else
								-- TxTestStart <= TxTestStart;
								-- TrigOut <= '1';
						        -- TxTestData <= TxTestData;
						        -- TxTestState <= T1;
							-- end if;
						-- when others =>
							-- if (TxStart = '1') then
								-- TrigOut <= TxTestData(0);
								-- TxTestData <= '1' & TxTestData(11 downto 1);
								-- if (TxTestCount = UsedBits_Func(Parity, StopBit, NumberObit)) then
									-- TxTestCount <= x"0";
									-- TxTestState <= T1;
								-- else
									-- TxTestCount <= TxTestCount + 1;
									-- TxTestState <= T2;
								-- end if;
							-- else
								-- TxTestCount <= TxTestCount;
								-- TxTestState <= T2;
							-- end if;
					-- end case;
				end if;
			end if;
		end process Tx_Proc;

	RxDataPCheck <= ParityCheck_Func(Parity, NumberObit, RxData(9 downto 0));

	Rx_Proc : process(nReset, Clk)
		begin
			if (nReset = '0') then
				RxWrReq <= '0';
				RxBaudCount <= (others => '0');
				RxData <= (others => '1');
				RxBitCount <= x"0";
				RxState <= T1;
----------------------------------------------------------
				RxFifoIn <= (others => '0');
				RxByteCount <= "00";
				RxFifoWr <= '0';
				RxFifoUsedN <= (others => '0');
				RxFifoUsedF <= (others => '0');
				RxFifoUsed <= (others => '0');
			else
				if rising_edge(Clk) then
					if (InternalInt = '1') then
						RxByteCount <= "00";
						RxFifoIn <= RxFifoIn;
						if (RxByteCount = "00") then
							RxFifoWr <= '0';
						else
							RxFifoWr <= '1';
						end if;
					elsif (RxWrReq = '1') then
						RxByteCount <= RxByteCount + 1;
						case RxByteCount is
							when "00" =>
								RxFifoWr <= '0';
								RxFifoIn(7 downto 0) <= RxDataPCheck(7 downto 0);
							when "01" =>
								RxFifoWr <= '0';
								RxFifoIn(15 downto 8) <= RxDataPCheck(7 downto 0);
							when "10" =>
								RxFifoWr <= '0';
								RxFifoIn(23 downto 16) <= RxDataPCheck(7 downto 0);
							when others =>
								RxFifoWr <= '1';
								RxFifoIn(31 downto 24) <= RxDataPCheck(7 downto 0);
						end case;
					else
						RxByteCount <= RxByteCount;
						RxFifoWr <= '0';
						RxFifoIn <= RxFifoIn;
					end if;
					if (InternalInt = '1') then
						RxFifoUsedN <= RxFifoUsed;
					elsif (RxRdReq = '1') then
						if (RxFifoUsedN < 4) then
							RxFifoUsedN <= (others => '0');
						else
							RxFifoUsedN <= RxFifoUsedN - 4;
						end if;
					else
						RxFifoUsedN <= RxFifoUsedN;
					end if;
					if (RxWrReq = '1') then
						RxFifoUsedF <= RxFifoUsedF + 1;
					elsif (InternalInt = '1') then
						RxFifoUsedF <= (others => '0');
					else
						RxFifoUsedF <= RxFifoUsedF;
					end if;
					if (RxWrReq = '1' and RxRdReq = '0') then
						if (RxFull = '1') then
							RxFifoUsed <= (others => '1');
						else
							RxFifoUsed <= RxFifoUsed + 1;
						end if;
					elsif (RxWrReq = '0' and RxRdReq = '1') then
						if (RxFifoUsed < 4) then
							RxFifoUsed <= (others => '0');
						else
							RxFifoUsed <= RxFifoUsed - 4;
						end if;
					else
						RxFifoUsed <= RxFifoUsed;
					end if;
					case RxState is
						when T1 =>
							RxWrReq <= '0';
							RxData <= (others => '0');
							RxBitCount <= x"0";
							if (RS485EN = '0' or (RS485EN = '1' and DIR = '0')) then--if OK to recieve
								if (DebouncerS(2) = '0') then--start bit
									if (RxBaudCount = '0' & BaudRate(15 downto 1)) then
										RxBaudCount <= (others => '0');
										RxState <= T2;
									else
										RxBaudCount <= RxBaudCount + 1;
										RxState <= T1;
									end if;
								else
									RxBaudCount <= (others => '0');
									RxState <= T1;
								end if;
							else
								RxBaudCount <= (others => '0');
								RxState <= T1;
							end if;
						when others =>
							if (RxBaudCount = BaudRate) then
								RxData(conv_integer(RxBitCount)) <=  DebouncerS(2);
								RxBaudCount <= (others => '0');
								if (RxBitCount = UsedBits_Func(Parity, StopBit, NumberObit)) then
									RxBitCount <= x"0";
									RxWrReq <= '1';
									RxState <= T1;
								else
									RxBitCount <= RxBitCount + 1;
									RxWrReq <= '0';
									RxState <= T2;
								end if;
							else
								RxBaudCount <= RxBaudCount + 1;
								RxBitCount <= RxBitCount;
								RxWrReq <= '0';
								RxState <= T2;
							end if;
					end case;
				end if;
			end if;
		end process Rx_Proc;
		
	Interrupt_Proc : process(nReset, Clk)
		begin
			if (nReset = '0') then
				Int <= '0';
				InternalInt <= '0';
				OneMicroC <= x"00";
				SilenceCount <= x"0000";
				IntSource <= "00";
				EventTime <= (others => '0');
				TestOut <= '1';
				IntState <= T1;
			else
				if rising_edge(Clk) then--TxEmpty
					-- TestOut <= TxEmpty;
					if (IntSource = "10") then
						TestOut <= '0';
					else
						TestOut <= '1';
					end if;
					if (IntSourceClr = '1' and s0_read = '0') then
						IntSource <= "00";
					else
						IntSource <= IntSource;
					end if;
					case IntState is
						when T1 =>
							OneMicroC <= x"00";
							SilenceCount <= x"0000";
							EventTime <= EventTime;
							if (RxWrReq = '1') then
								if (WaterMkInt = '1' and RxFifoUsed >= (WaterMark(UartFifoSize-1 downto 0) - 1)) then--interrupt on water mark
									Int <= '1';
									InternalInt <= '1';
									IntSource <= "01";
									IntState <= T3;
								elsif (SilnceInt = '1' and WaterMark > 0) then
									Int <= '0';
									InternalInt <= '0';
									IntState <= T2;
								else
									Int <= '0';
									InternalInt <= '0';
									IntState <= T1;
								end if;
							else
								Int <= '0';
								InternalInt <= '0';
								IntState <= T1;
							end if;
						when T2 =>
							if (RxWrReq = '1') then
								OneMicroC <= x"00";
								SilenceCount <= x"0000";
								EventTime <= EventTime;
								if (WaterMkInt = '1' and RxFifoUsed >= (WaterMark(UartFifoSize-1 downto 0) - 1)) then--interrupt on water mark
									Int <= '1';
									InternalInt <= '1';
									IntSource <= "01";
									IntState <= T3;
								else
									Int <= '0';
									InternalInt <= '0';
									IntState <= T2;
								end if;
							else
								if (SilenceCount >= Silence) then
									Int <= '1';
									InternalInt <= '1';
									IntSource <= "10";
									OneMicroC <= x"00";
									SilenceCount <= x"0000";
									EventTime <= SystemTimer;
									IntState <= T3;
								else
									Int <= '0';
									InternalInt <= '0';
									EventTime <= EventTime;
									if (OneMicroC = x"7C") then--1uSec
										OneMicroC <= x"00";
										SilenceCount <= SilenceCount + 1;
									else
										OneMicroC <= OneMicroC + 1;
										SilenceCount <= SilenceCount;
									end if;
									IntState <= T2;
								end if;
							end if;
						when others =>
							EventTime <= EventTime;
							IntSource <= "10";
							InternalInt <= '0';
							if (SilenceCount >= x"0005") then
								Int <= '1';
								OneMicroC <= x"00";
								SilenceCount <= x"0000";
								IntState <= T1;
							else
								Int <= '0';
								if (OneMicroC = x"7C") then--1uSec
									OneMicroC <= x"00";
									SilenceCount <= SilenceCount + 1;
								else
									OneMicroC <= OneMicroC + 1;
									SilenceCount <= SilenceCount;
								end if;
								IntState <= T3;
							end if;
					end case;
				end if;
			end if;
		end process Interrupt_Proc;

END Arc_WinnerUART;

