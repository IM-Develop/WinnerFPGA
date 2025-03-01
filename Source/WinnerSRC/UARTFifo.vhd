library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
    
entity UARTFifo is
    generic (
        DATA_WIDTH :integer := 8;
        ADDR_WIDTH :integer := 8
    );
    port (
       -- Reading port.
        Data_out    	: out std_logic_vector (DATA_WIDTH-1 downto 0);
        Empty_out   	: out std_logic;
        ReadEn_in   	: in  std_logic;
        RClk        	: in  std_logic;
       -- Writing port.
        Data_in     	: in  std_logic_vector (DATA_WIDTH-1 downto 0);
        Full_out    	: out std_logic;
        WriteEn_in  	: in  std_logic;
        WClk        	: in  std_logic;
	 
        nReset	    	: in  std_logic;
		ByteCount		: buffer std_logic_vector(ADDR_WIDTH-1 downto 0)
    );
end entity;
architecture Arc_UARTFifo of UARTFifo is
   ----/Internal connections & variables------
    constant FIFO_DEPTH :integer := 2**ADDR_WIDTH;

    type RAM is array (integer range <>)of std_logic_vector (DATA_WIDTH-1 downto 0);
    signal Mem : RAM (0 to FIFO_DEPTH-1);
    
    signal pNextWordToWrite     :std_logic_vector (ADDR_WIDTH-1 downto 0);
    signal pNextWordToRead      :std_logic_vector (ADDR_WIDTH-1 downto 0);
    signal EqualAddresses       :std_logic;
    signal NextWriteAddressEn   :std_logic;
    signal NextReadAddressEn    :std_logic;
    signal Set_Status           :std_logic;
    signal Rst_Status           :std_logic;
    signal Status               :std_logic;
    signal PresetFull           :std_logic;
    signal PresetEmpty          :std_logic;
    signal empty,full           :std_logic;
    
    component UARTFifo_GC is
    generic (
        COUNTER_WIDTH :integer := 4
    );
    port (
        GrayCount_out :out std_logic_vector (COUNTER_WIDTH-1 downto 0);
        Enable_in     :in  std_logic; --Count enable.
        nReset        :in  std_logic; --Count reset.
        clk           :in  std_logic
    );
    end component;
begin

	ByteCounter : process(nReset, WClk)
		begin
			if (nReset = '0')then
				ByteCount <= (others => '0');
			else
				if rising_edge (WClk)then
					if (NextWriteAddressEn = '1') then
						ByteCount <= ByteCount + 1;
					elsif (NextReadAddressEn = '1') then
						ByteCount <= ByteCount - 1;
					end if;
				end if;
			end if;
		end process ByteCounter;

   --------------Code--------------/
   --Data ports logic:
   --(Uses a dual-port RAM).
   --'Data_out' logic:
    process (RClk) begin
        if (rising_edge(RClk)) then
            -- if (ReadEn_in = '1' and empty = '0') then
            if (empty = '0') then
                Data_out <= Mem(conv_integer(pNextWordToRead));
            end if;
        end if;
    end process;
            
   --'Data_in' logic:
    process (WClk) begin
        if (rising_edge(WClk)) then
            if (WriteEn_in = '1' and full = '0') then
                Mem(conv_integer(pNextWordToWrite)) <= Data_in;
            end if;
        end if;
    end process;

   --Fifo addresses support logic: 
   --'Next Addresses' enable logic:
    NextWriteAddressEn <= WriteEn_in and (not full);
    NextReadAddressEn  <= ReadEn_in  and (not empty);
           
   --Addreses (Gray counters) logic:
    GrayCounter_pWr : UARTFifo_GC
	generic map (COUNTER_WIDTH => ADDR_WIDTH)
    port map (
        GrayCount_out => pNextWordToWrite,
        Enable_in     => NextWriteAddressEn,
        nReset        => nReset,
        clk           => WClk
    );
       
    GrayCounter_pRd : UARTFifo_GC
	generic map (COUNTER_WIDTH => ADDR_WIDTH)
    port map (
        GrayCount_out => pNextWordToRead,
        Enable_in     => NextReadAddressEn,
        nReset        => nReset,
        clk           => RClk
    );

   --'EqualAddresses' logic:
    EqualAddresses <= '1' when (pNextWordToWrite = pNextWordToRead) else '0';

   --'Quadrant selectors' logic:
    process (pNextWordToWrite, pNextWordToRead)
        variable set_status_bit0 :std_logic;
        variable set_status_bit1 :std_logic;
        variable rst_status_bit0 :std_logic;
        variable rst_status_bit1 :std_logic;
    begin
        set_status_bit0 := pNextWordToWrite(ADDR_WIDTH-2) xnor pNextWordToRead(ADDR_WIDTH-1);
        set_status_bit1 := pNextWordToWrite(ADDR_WIDTH-1) xor  pNextWordToRead(ADDR_WIDTH-2);
        Set_Status <= set_status_bit0 and set_status_bit1;
        
        rst_status_bit0 := pNextWordToWrite(ADDR_WIDTH-2) xor  pNextWordToRead(ADDR_WIDTH-1);
        rst_status_bit1 := pNextWordToWrite(ADDR_WIDTH-1) xnor pNextWordToRead(ADDR_WIDTH-2);
        Rst_Status      <= rst_status_bit0 and rst_status_bit1;
    end process;
    
   --'Status' latch logic:
    process (Set_Status, Rst_Status, nReset)
	begin
        if (Rst_Status = '1' or nReset = '0') then
            Status <= '0'; --Going 'Empty'.
        elsif (Set_Status = '1') then
            Status <= '1'; --Going 'Full'.
        end if;
    end process;
    
   --'Full_out' logic for the writing port:
    PresetFull <= Status and EqualAddresses; --'Full' Fifo.
    
    process (WClk, PresetFull) begin--D Flip-Flop w/ Asynchronous Preset.
        if (PresetFull = '1') then
            full <= '1';
        elsif (rising_edge(WClk)) then
            full <= '0';
        end if;
    end process;
    Full_out <= full;
    
   --'Empty_out' logic for the reading port:
    PresetEmpty <= not Status and EqualAddresses; --'Empty' Fifo.
    
    process (RClk, PresetEmpty) begin--D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty = '1') then
            empty <= '1';
			Empty_out <= '1';
        elsif (rising_edge(RClk)) then
            empty <= '0';
			Empty_out <= empty;
        end if;
    end process;
    
    -- Empty_out <= empty;
end Arc_UARTFifo;
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
    
entity UARTFifo_GC is
    generic (
        COUNTER_WIDTH :integer := 4
    );
    port (                                 --'Gray' code count output.
        GrayCount_out :out std_logic_vector (COUNTER_WIDTH-1 downto 0);  
        Enable_in     :in  std_logic;      -- Count enable.
        nReset        :in  std_logic;      -- Count reset.
        clk           :in  std_logic       -- Input clock
    );
end entity;

architecture Arc_UARTFifo_GC of UARTFifo_GC is
    signal BinaryCount :std_logic_vector (COUNTER_WIDTH-1 downto 0);
begin
    process (nReset, clk)
		begin
			if (nReset = '0') then
				--Gray count begins @ '1' with
				BinaryCount   <= conv_std_logic_vector(1, COUNTER_WIDTH);  
				GrayCount_out <= (others=>'0');
			else
				if rising_edge(clk) then
					if (Enable_in = '1') then
						BinaryCount   <= BinaryCount + 1;
						GrayCount_out <= (BinaryCount(COUNTER_WIDTH-1) & 
										  BinaryCount(COUNTER_WIDTH-2 downto 0) xor 
										  '0'&BinaryCount(COUNTER_WIDTH-1 downto 1));
					end if;
				end if;
			end if;
		end process;
    
end Arc_UARTFifo_GC;