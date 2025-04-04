`define	ECP5UM
`define X4
`define LW2
`define	ENDPOINT_COMP
`define	SERDES_QUAD RA
`define GEN2
`define POL_COMP
`define SKP_INS_CNT  10'd590

// DLL Layer Defines
//========================================
`define	MAX_TLP_512

// TRANSCATION Layer Defines
//========================================
`define INIT_PH_FC_VC0 8'h00
`define INIT_PD_FC_VC0 12'h000
`define INIT_NPH_FC_VC0 8'd32
`define INIT_NPD_FC_VC0 12'd32
//  Value of the Update Freq count
`define UPDATE_FREQ_PH  7'd8
`define UPDATE_FREQ_PD  11'd255
`define UPDATE_FREQ_NPH 7'd8
`define UPDATE_FREQ_NPD 11'd8
`define UPDATE_TIMER  12'd4095
// For Type0 Registers
`define INIT_REG_000  32'h00000000
`define INIT_REG_008  32'h00000000
`define INIT_REG_00C  32'h00000000
`define	EN_BAR0
`define	EN_BAR1
`define INIT_REG_010  32'hfffc0000
`define INIT_REG_014  32'hfffc0000
`define INIT_REG_018  32'h00000000
`define INIT_REG_01C  32'h00000000
`define INIT_REG_020  32'h00000000
`define INIT_REG_024  32'h00000000
`define INIT_REG_028  32'h00000000
`define INIT_REG_02C  32'h00000000
`define INIT_REG_030  32'h00000000
`define INIT_REG_03C  32'h00000100
`define ID_INTF
`define INIT_REG_050  32'h00030000
`define INIT_REG_054  32'h00000000
// For PM Registers
`define INIT_PM_DS_DATA_0  10'd0
`define INIT_PM_DS_DATA_1  10'd0
`define INIT_PM_DS_DATA_2  10'd0
`define INIT_PM_DS_DATA_3  10'd0
`define INIT_PM_DS_DATA_4  10'd0
`define INIT_PM_DS_DATA_5  10'd0
`define INIT_PM_DS_DATA_6  10'd0
`define INIT_PM_DS_DATA_7  10'd0
`define MSI
// For MSI Registers
`define INIT_REG_070  32'h00800000
// For PCIE Registers
`define INIT_REG_090  32'h00020000
`define INIT_REG_094  32'b00000000000000000000000000000000
`define DSN_CAP_VER   4'h1
// For Device Serial no. Registers
`define INIT_REG_104  32'h00000000
`define INIT_REG_108  32'h00000000
`define INIT_REG_09C  32'b00000000000000111111100000010001
`define INIT_REG_0A0  32'h10000000
`define INIT_REG_0B4  32'h00000011
// For VCC Registers
`define INIT_REG_10C  32'h00000000
`define AER_CAP_VER   4'h1
`define TERM_ALL_CFG 1'b1
`define USR_EXT_CAP_ADDR   12'h000
`define ACKNAK_LAT_TIME  14'd38
`define	LPEVCC 3'b000
`define	VC1
`define	NUM_VC 1
`define TLP_DEBUG 1'd0
//PCS PIPE Parameter Files
`define PX1
`define Channel_0
`define SCI_INTF
`define SOFT_LOL_ENABLE
