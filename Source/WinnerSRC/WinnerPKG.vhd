library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package WinnerPKG is

	constant DefaultBaud		: std_logic_vector(15 downto 0) := x"043D";--1085 (115200bps)
	constant Version			: std_logic_vector(31 downto 0) := x"FCAB1007";
	
	constant UartFifoSize		: integer range 1 to 16 := 11;--2^8 = 256
	constant TxUartFifoSize		: integer range 1 to 16 := 9;
	
	-- constant UartSize			: integer := 2**UartFifoSize;

	function ChipSelect_func 	(Add	: std_logic_vector(4 downto 0); Cyc		: std_logic) return std_logic_vector;--enable head
	function UsedBits_Func 		(Parity	: std_logic_vector(1 downto 0); StopBit	: std_logic; NumberObit	: std_logic_vector(2 downto 0)) return std_logic_vector;
	function ParityMake_Func 	(Parity	: std_logic_vector(1 downto 0); NumberObit : std_logic_vector(2 downto 0); WriteData : std_logic_vector(8 downto 0)) return std_logic;
	function ParityCheck_Func 	(Parity	: std_logic_vector(1 downto 0); NumberObit : std_logic_vector(2 downto 0); ReadData : std_logic_vector(9 downto 0)) return std_logic_vector;
	function WriteData_func 	(Parity	: std_logic_vector(1 downto 0); NumberObit : std_logic_vector(2 downto 0); WriteData : std_logic_vector(8 downto 0)) return std_logic_vector;
                                            
end WinnerPKG;                        
                                            
                                            
package body WinnerPKG is


	function ChipSelect_func (Add		: std_logic_vector(4 downto 0);--set place
							  Cyc		: std_logic) return std_logic_vector is--enable head
		variable Output : std_logic_vector(31 downto 0);
		variable Count	: std_logic_vector(4 downto 0);
		begin
			Output := (others => '0');
			Count := "00000";
			if (Cyc = '1') then
				for i in 0 to 31 loop
					if (Count = Add) then
						Output(i) := '1';
						exit;
					else
						Count := Count + 1;
					end if;
				end loop;
			else
				Output := (others => '0');
			end if;
		return(Output);
    end ChipSelect_func;
	
	function UsedBits_Func (Parity		: std_logic_vector(1 downto 0);
							 StopBit	: std_logic;
							 NumberObit	: std_logic_vector(2 downto 0)) return std_logic_vector is
		variable Output : std_logic_vector(3 downto 0);
		begin
			case NumberObit is
				when "000" =>--5bit
					Output := x"5";
				when "001" =>--6bit
					Output := x"6";
				when "010" =>--7bit
					Output := x"7";
				when "100" =>--9bit
					Output := x"9";
				when others =>--8bit
					Output := x"8";
			end case;
			if (Parity(0) = '1') then
				Output := Output + 1;
			end if;
			if (StopBit = '1') then
				Output := Output + 2;
			else
				Output := Output + 1;
			end if;
		return(Output - 1);
    end UsedBits_Func;
	
	function ParityMake_Func (Parity		: std_logic_vector(1 downto 0);
						  NumberObit	: std_logic_vector(2 downto 0);
						  WriteData 	: std_logic_vector(8 downto 0)) return std_logic is
		variable Output : std_logic;
		variable Temp	: std_logic_vector(7 downto 0);
		begin
			Temp(0) := WriteData(0) xor WriteData(1);
			Temp(1) := Temp(0) xor WriteData(2);
			Temp(2) := Temp(1) xor WriteData(3);
			Temp(3) := Temp(2) xor WriteData(4);
			Temp(4) := Temp(3) xor WriteData(5);
			Temp(5) := Temp(4) xor WriteData(6);
			Temp(6) := Temp(5) xor WriteData(7);
			Temp(7) := Temp(6) xor WriteData(8);
			case NumberObit is
				when "000" =>--5bit
					if (Parity(1) = '0') then--odd
						Output := not(Temp(3));
					else
						Output := Temp(3);
					end if;
				when "001" =>--6bit
					if (Parity(1) = '0') then--odd
						Output := not(Temp(4));
					else
						Output := Temp(4);
					end if;
				when "010" =>--7bit
					if (Parity(1) = '0') then--odd
						Output := not(Temp(5));
					else
						Output := Temp(5);
					end if;
				when "100" =>--9bit
					if (Parity(1) = '0') then--odd
						Output := not(Temp(7));
					else
						Output := Temp(7);
					end if;
				when others =>--8bit
					if (Parity(1) = '0') then--odd
						Output := not(Temp(6));
					else
						Output := Temp(6);
					end if;
			end case;
		return(Output);
    end ParityMake_Func;
	
	function ParityCheck_Func (Parity		: std_logic_vector(1 downto 0);
							   NumberObit	: std_logic_vector(2 downto 0);
							   ReadData 	: std_logic_vector(9 downto 0)) return std_logic_vector is
		variable PCheck	: std_logic_vector(1 downto 0);
		variable Output : std_logic_vector(9 downto 0);
		variable Temp	: std_logic_vector(7 downto 0);
		begin
			Temp(0) := ReadData(0) xor ReadData(1);
			Temp(1) := Temp(0) xor ReadData(2);
			Temp(2) := Temp(1) xor ReadData(3);
			Temp(3) := Temp(2) xor ReadData(4);
			Temp(4) := Temp(3) xor ReadData(5);
			Temp(5) := Temp(4) xor ReadData(6);
			Temp(6) := Temp(5) xor ReadData(7);
			Temp(7) := Temp(6) xor ReadData(8);
			case NumberObit is
				when "000" =>--5bit
					if (Parity(1) = '0') then--odd
						PCheck(0) := not(Temp(3));
					else
						PCheck(0) := Temp(3);
					end if;
					PCheck(1) := ReadData(5);
					if (PCheck(0) = PCheck(1) or Parity(0) = '0') then
						Output := "00000"&ReadData(4 downto 0);
					else
						Output := "10000"&ReadData(4 downto 0);
					end if;
				when "001" =>--6bit
					if (Parity(1) = '0') then--odd
						PCheck(0) := not(Temp(4));
					else
						PCheck(0) := Temp(4);
					end if;
					PCheck(1) := ReadData(6);
					if (PCheck(0) = PCheck(1) or Parity(0) = '0') then
						Output := "0000"&ReadData(5 downto 0);
					else
						Output := "1000"&ReadData(5 downto 0);
					end if;
				when "010" =>--7bit
					if (Parity(1) = '0') then--odd
						PCheck(0) := not(Temp(5));
					else
						PCheck(0) := Temp(5);
					end if;
					PCheck(1) := ReadData(7);
					if (PCheck(0) = PCheck(1) or Parity(0) = '0') then
						Output := "000"&ReadData(6 downto 0);
					else
						Output := "100"&ReadData(6 downto 0);
					end if;
				when "100" =>--9bit
					if (Parity(1) = '0') then--odd
						PCheck(0) := not(Temp(7));
					else
						PCheck(0) := Temp(7);
					end if;
					PCheck(1) := ReadData(9);
					if (PCheck(0) = PCheck(1) or Parity(0) = '0') then
						Output := '0'&ReadData(8 downto 0);
					else
						Output := '1'&ReadData(8 downto 0);
					end if;
				when others =>--8bit
					if (Parity(1) = '0') then--odd
						PCheck(0) := not(Temp(6));
					else
						PCheck(0) := Temp(6);
					end if;
					PCheck(1) := ReadData(8);
					if (PCheck(0) = PCheck(1) or Parity(0) = '0') then
						Output := "00"&ReadData(7 downto 0);
					else
						Output := "10"&ReadData(7 downto 0);
					end if;
			end case;
		return(Output);
    end ParityCheck_Func;
	
	function WriteData_func (Parity		: std_logic_vector(1 downto 0);
							 NumberObit	: std_logic_vector(2 downto 0);
							 WriteData 	: std_logic_vector(8 downto 0)) return std_logic_vector is
		variable Output : std_logic_vector(11 downto 0);
		begin
			Output := (others => '1');
			case NumberObit is
				when "000" =>--5bit
					Output(4 downto 0) := WriteData(4 downto 0);
					if (Parity(0) = '1') then
						Output(5) := ParityMake_Func(Parity, NumberObit, WriteData);
					end if;
				when "001" =>--6bit
					Output(5 downto 0) := WriteData(5 downto 0);
					if (Parity(0) = '1') then
						Output(6) := ParityMake_Func(Parity, NumberObit, WriteData);
					end if;
				when "010" =>--7bit
					Output(6 downto 0) := WriteData(6 downto 0);
					if (Parity(0) = '1') then
						Output(7) := ParityMake_Func(Parity, NumberObit, WriteData);
					end if;
				when "100" =>--9bit
					Output(8 downto 0) := WriteData(8 downto 0);
					if (Parity(0) = '1') then
						Output(9) := ParityMake_Func(Parity, NumberObit, WriteData);
					end if;
				when others =>--8bit
					Output(7 downto 0) := WriteData(7 downto 0);
					if (Parity(0) = '1') then
						Output(8) := ParityMake_Func(Parity, NumberObit, WriteData);
					end if;
			end case;
		return(Output);
    end WriteData_func;

end WinnerPKG;
