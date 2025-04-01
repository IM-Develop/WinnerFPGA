set CUR_YYYY=%date:~10,4%
set CUR_MM=%date:~4,2%
set CUR_DD=%date:~7,2%
set SUBFILENAME=%CUR_DD%%CUR_MM%%CUR_YYYY%
copy Implementation\ecp5um-85F_PCIeBasic\impl1\top_x1_impl1.bit Output\Rotor_V30_FPGA_%SUBFILENAME%.bit
rem copy impl1\top_x1_impl1.bit Rvl\*.*
del Implementation\ecp5um-85F_PCIeBasic\impl1\*.bit

rem copy  Implementation\ecp5um5G-45F_PCIeBasic\impl1\*.bit *.*
SET THEDIR=Implementation\ecp5um-85F_PCIeBasic\impl1
Echo Deleting all files from %THEDIR%
DEL "%THEDIR%\*" /F /Q /A
Echo Deleting all folders from %THEDIR%
FOR /F "eol=| delims=" %%I in ('dir "%THEDIR%\*" /AD /B 2^>nul') do rd /Q /S "%THEDIR%\%%I"
ECHO Folder deleted.
rem copy *.bit Implementation\ecp5um5G-45F_PCIeBasic\impl1\*.*
rem del *.bit
rmdir Implementation\ecp5um-85F_PCIeBasic\top_x1_tcr.dir /s/q
