// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2001 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised
// by a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement
// from Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation    TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                        408-826-6000 (other locations)
// Hillsboro, OR 97124                  web  : http://www.latticesemi.com/
// U.S.A                                email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS
// Project          : pci_exp_x1
// File             : tb_top.v
// Title            :
// Dependencies     : pci_exp_params.v pci_exp_ddefines.v testcase.v
// Description      : Top level for testbench of pci_exp IP with Serdes PCS PIPE
//
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Mod. Date        : Oct 02, 2007
// Changes Made     : Initial Creation
// =============================================================================

`timescale 100 ps/100 ps
module tb_top;

// DUT User defines
`include "pci_exp_params.v"


// =============================================================================
// Regs for BFM & Test case
// =============================================================================
//---- Regs
reg                      clk_200;
reg                      error;
reg                      rst_n;
reg                      no_pcie_train;   // This signal disables the training process

reg                      ecrc_gen_enb ;
reg                      ecrc_chk_enb ;

reg  [1:0]               tx_dllp_val;
reg  [2:0]               tx_pmtype;       // Power Management Type
reg  [23:0]              tx_vsd_data;
reg                      rx_tlp_discard;

wire [23:0]              tbtx_vc;
wire [23:0]              tbrx_vc;
reg                      disable_mlfmd_check;
reg                      DISABLE_SKIP_CHECK;
wire [1:0]               power_down_init;
wire [14:0]              init_15_00;
wire [14:0]              init_15_11;
wire [15:0]              init_16_11;
reg                      enb_log;


//---- Wires

wire  [2:0]              rxdp_pmd_type;
wire  [23:0]             rxdp_vsd_data;
wire                     rxdp_vsd_val;
wire  [1:0]              rxdp_dllp_val;
wire                     dl_up;
wire                     sys_clk_125;
wire                     sys_clk_125_tmp;
wire                     tx_dllp_sent;


wire [63:0]              INIT_PH_FC;      //Initial P HdrFC value
wire [63:0]              INIT_NPH_FC;     // For NPH
wire [95:0]              INIT_PD_FC;      // Initial P DataFC value
wire [95:0]              INIT_NPD_FC;     // For NPD
wire [71:0]              tx_ca_ph;
wire [103:0]             tx_ca_pd;
wire [71:0]              tx_ca_nph;
wire [103:0]             tx_ca_npd;
wire [71:0]              tx_ca_cplh;
wire [103:0]             tx_ca_cpld;

reg  [7:0]               tbrx_cmd_prsnt;
wire [7:0]               tbrx_cmd_prsnt_int;
wire [7:0]               ph_buf_status;   // Indicate the Full/alm.Full status of the PH buffers
wire [7:0]               pd_buf_status;   // Indicate PD Buffer has got space less than Max Pkt size
wire [7:0]               nph_buf_status;  // For NPH
wire [7:0]               npd_buf_status;  // For NPD
wire [7:0]               ph_processed;    // TL has processed one TLP Header - PH Type
wire [7:0]               pd_processed;    // TL has processed one TLP Data - PD TYPE
wire [7:0]               nph_processed;   // For NPH
wire [7:0]               npd_processed;   // For NPD
wire [8*8-1:0]           pd_num;
wire [8*8-1:0]           npd_num;

//---------Outputs From Core------------
wire  [7:0]              tx_rdy;
wire  [511:0]            rx_data;
wire  [7:0]              rx_st;
wire  [7:0]              rx_end;
wire  [7:0]              rx_dwen;
wire  [7:0]              rx_ecrc_err;
wire  [7:0]              rx_us_req;
wire  [7:0]              rx_malf_tlp;
wire  [3:0]              phy_ltssm_state;

wire  [7:0]              tx_req;
wire  [7:0]              tx_dwen;
wire  [2:0]              rx_status;
wire  [1:0]              power_down;
wire                     tx_detect_rx;
wire                     tx_elec_idle;
wire                     tx_compliance;
wire                     rx_polarity;
//wire                     reset_n;
wire  [15:0]             rx_valid;
wire  [15:0]             rx_elec_idle;
wire  [15:0]             phy_status;

wire                     rx_valid0;    //For Debug
wire                     rx_elec_idle0;
wire                     phy_status0;
wire                     phy_realign_req;

//---- Integer
integer                  i;

wire  [(`NUM_VC*64)-1:0] tx_data;
wire  [`NUM_VC-1:0]      tx_st;
wire  [`NUM_VC-1:0]      tx_end;
wire  [`NUM_VC-1:0]      tx_nlfy;

wire  [`NUM_VC-1:0]      tb_sys_clk;

`ifdef WISHBONE
reg                      RST_I ;
reg                      CLK_I ;
reg [12:0]               ADR_I ;
reg [31:0]               DAT_I ;
reg [3:0]                SEL_I ;
reg                      WE_I ;
reg                      STB_I ;
reg                      CYC_I ;

wire [31:0]              CHAIN_RDAT_in = 32'd0 ;
wire                     CHAIN_ACK_in  = 1'd0;
wire [31:0]              DAT_O ;
wire                     ACK_O ;
wire                     IRQ_O ;
`endif

parameter DLY1 = 1 ;
parameter DLY2 = 1 ;

// =============================================================================

// Include Testbench params files

// DUT Design params file
`include "pci_exp_ddefines.v"

// Include the test case
`include "testcase.v"


// =============================================================================
//-------- For Flow Control Tasks
parameter P    = 2'b00;
parameter NP   = 2'b01;
parameter CPLX = 2'b10;  //CPL is already used in some other paramter

parameter PH   = 3'b000;
parameter PD   = 3'b001;
parameter NPH  = 3'b010;
parameter NPD  = 3'b011;
parameter CPLH = 3'b100;
parameter CPLD = 3'b101;

//---- Wires
wire                    hdoutp_0 ;
wire                    hdoutn_0 ;
wire                    hdoutp_1 ;
wire                    hdoutn_1 ;
wire                    refclkp;
wire                    refclkn;

pullup (hdoutp_0);
pullup (hdoutn_0);
pullup (hdoutp_1);
pullup (hdoutn_1);

// =============================================================================
// PIPE_SIGNALS For Debug -- For X1
// =============================================================================
assign rx_valid0      = rx_valid[0];
assign rx_elec_idle0  = rx_elec_idle[0];
assign phy_status0    = phy_status[0];

// =============================================================================
// Generate  tbrx_cmd_prsnt
// =============================================================================
always@(sys_clk_125) begin
    tbrx_cmd_prsnt[7] <= (tbrx_cmd_prsnt_int[7] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[6] <= (tbrx_cmd_prsnt_int[6] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[5] <= (tbrx_cmd_prsnt_int[5] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[4] <= (tbrx_cmd_prsnt_int[4] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[3] <= (tbrx_cmd_prsnt_int[3] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[2] <= (tbrx_cmd_prsnt_int[2] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[1] <= (tbrx_cmd_prsnt_int[1] === 1'b1) ? 1'b1 : 1'b0;
    tbrx_cmd_prsnt[0] <= (tbrx_cmd_prsnt_int[0] === 1'b1) ? 1'b1 : 1'b0;
end


`ifdef VC1
   assign tbrx_vc = 3'd0;
   assign tbtx_vc = 3'd0;
`endif

assign  power_down_init = 2'b10;
assign  init_15_00 = 15'b0000_0000_0000_000;
assign  init_15_11 = 15'b1111_1111_1111_111;
assign  init_16_11 = 16'b1111_1111_1111_1111;

// =============================================================================
// TBTX (User Logic on TX side) Instantiations
// =============================================================================
tbtx u_tbtx [`NUM_VC-1:0]  (
    //----- Inputs
    .sys_clk         (sys_clk_125),
    .rst_n           (rst_n),
    .tx_tc           (tbtx_vc[(`NUM_VC*3)-1:0]),

    .tx_ca_ph        (tx_ca_ph[(9*`NUM_VC)-1:0]),
    .tx_ca_pd        (tx_ca_pd[(13*`NUM_VC)-1:0]),
    .tx_ca_nph       (tx_ca_nph[(9*`NUM_VC)-1:0]),
    .tx_ca_npd       (tx_ca_npd[(13*`NUM_VC)-1:0]),
    .tx_ca_cplh      (tx_ca_cplh[(9*`NUM_VC)-1:0]),
    .tx_ca_cpld      (tx_ca_cpld[(13*`NUM_VC)-1:0]),
    .tx_ca_p_recheck    (tx_ca_p_recheck_vc0),
    .tx_ca_cpl_recheck  (tx_ca_cpl_recheck_vc0),

    .tx_rdy          (tx_rdy[`NUM_VC-1:0]),
    .tx_val          (tx_val),

    //------- Outputs
    .tx_req          (tx_req[`NUM_VC-1:0]),
    .tx_data         (tx_data),
    .tx_st           (tx_st),
    .tx_end          (tx_end),
    .tx_nlfy         (tx_nlfy),
    .tx_dwen         (tx_dwen[`NUM_VC-1:0])
    );

// =============================================================================
// TBRX (User Logic on RX side) Instantiations
// =============================================================================
tbrx u_tbrx [`NUM_VC-1:0]  (
   //----- Inputs
   .sys_clk         (sys_clk_125),
   .rst_n           (rst_n),
   .rx_tc           (tbrx_vc[(`NUM_VC*3)-1:0]),

   .rx_data         ( rx_data[(`NUM_VC*64)-1:0]),
   .rx_st           ( rx_st[`NUM_VC -1:0]),
   .rx_end          ( rx_end[`NUM_VC -1:0]),
   .rx_dwen         ( rx_dwen[`NUM_VC -1:0]),
   `ifdef ECRC
      .rx_ecrc_err  ( rx_ecrc_err[`NUM_VC -1:0] ),
   `endif
   .rx_us_req       ( rx_us_req[`NUM_VC -1:0] ),
   .rx_malf_tlp     ( rx_malf_tlp[`NUM_VC -1:0] ),

    //------- Outputs
   .tbrx_cmd_prsnt   (tbrx_cmd_prsnt_int[`NUM_VC-1:0]),
   .ph_buf_status    (ph_buf_status[`NUM_VC-1:0]),
   .pd_buf_status    (pd_buf_status[`NUM_VC-1:0]),
   .nph_buf_status   (nph_buf_status[`NUM_VC-1:0]),
   .npd_buf_status   (npd_buf_status[`NUM_VC-1:0]),
   .cplh_buf_status  ( ),
   .cpld_buf_status  ( ),
   .ph_processed     (ph_processed[`NUM_VC-1:0]),
   .pd_processed     (pd_processed[`NUM_VC-1:0]),
   .nph_processed    (nph_processed[`NUM_VC-1:0]),
   .npd_processed    (npd_processed[`NUM_VC-1:0]),
   .cplh_processed   ( ),
   .cpld_processed   ( ),
   .pd_num           (pd_num[(8*`NUM_VC) -1:0]),
   .npd_num          (npd_num[(8*`NUM_VC) -1:0]),
   .cpld_num         ( ),
   .INIT_PH_FC       (INIT_PH_FC[(8*`NUM_VC)-1:0]),
   .INIT_NPH_FC      (INIT_NPH_FC[(8*`NUM_VC)-1:0]),
   .INIT_CPLH_FC     ( ),
   .INIT_PD_FC       (INIT_PD_FC[(12*`NUM_VC)-1:0]),
   .INIT_NPD_FC      (INIT_NPD_FC[(12*`NUM_VC)-1:0]),
   .INIT_CPLD_FC     ( )
    );


// =============================================================================
// DUT
// =============================================================================
// Intantiate EXTREF
pcie_extref  extref_0 (
   .refclkp    (clk_200) ,
   .refclkn    (~clk_200) ,
   .refclko    (refclk) );

`USERNAME_EVAL_TOP u1_top(
   //------- Clock and Reset
   .pll_refclki                ( refclk),
   .rxrefclk                   ( refclk),
   .rst_n                      ( rst_n ),

   .hdinp0                     ( hdoutp_0 ),
   .hdinn0                     ( hdoutn_0 ),
   .hdoutp0                    ( hdoutp_0 ),
   .hdoutn0                    ( hdoutn_0 ),
`ifdef Channel_1
   .hdinp1                     ( hdoutp_1 ),
   .hdinn1                     ( hdoutn_1 ),
   .hdoutp1                    ( hdoutp_1 ),
   .hdoutn1                    ( hdoutn_1 ),
`endif
   .no_pcie_train           ( no_pcie_train ),

   // To RXFC
   // Following are Advertised during Initialization
   .tx_req_vc0                 (tx_req[0]),
   .tx_data_vc0                (tx_data[64*1-1:0]),
   .tx_st_vc0                  (tx_st[0]),
   .tx_end_vc0                 (tx_end[0]),
   .tx_nlfy_vc0                (tx_nlfy[0]),
   .tx_dwen_vc0                (tx_dwen[0]),
   .ph_buf_status_vc0          (ph_buf_status[0]),
   .pd_buf_status_vc0          (pd_buf_status[0]),
   .nph_buf_status_vc0         (nph_buf_status[0]),
   .npd_buf_status_vc0         (npd_buf_status[0]),
   .ph_processed_vc0           (ph_processed[0]),
   .pd_processed_vc0           (pd_processed[0]),
   .nph_processed_vc0          (nph_processed[0]),
   .npd_processed_vc0          (npd_processed[0]),

   .tx_val                     (tx_val),

   // To  TX User
   .tx_rdy_vc0                 (tx_rdy[0]),
   .tx_ca_ph_vc0               (tx_ca_ph[(9*1)-1:0]),
   .tx_ca_pd_vc0               (tx_ca_pd[(13*1)-1:0]),
   .tx_ca_nph_vc0              (tx_ca_nph[(9*1)-1:0]),
   .tx_ca_npd_vc0              (tx_ca_npd[(13*1)-1:0]),
   .tx_ca_cplh_vc0             (tx_ca_cplh[(9*1)-1:0]),
   .tx_ca_cpld_vc0             (tx_ca_cpld[(13*1)-1:0]),
   .tx_ca_p_recheck_vc0        ( tx_ca_p_recheck_vc0 ),
   .tx_ca_cpl_recheck_vc0      ( tx_ca_cpl_recheck_vc0 ),

   // Inputs/Outputs per VC
   .rx_data_vc0                ( rx_data[(64*1)-1:0]),
   .rx_st_vc0                  ( rx_st[0]),
   .rx_end_vc0                 ( rx_end[0]),
   .rx_dwen_vc0                ( rx_dwen[0]),
   .rx_us_req_vc0              ( rx_us_req[0] ),
   .rx_malf_tlp_vc0            ( rx_malf_tlp[0] ),


   // Datal Link Control SM Status
   .dl_up                      ( dl_up ),
   .sys_clk_125                ( sys_clk_125_temp )
   );


// ====================================================================
// Initilize the design
// ====================================================================
initial begin
    error           = 1'b0;
    rst_n           = 1'b0;
    clk_200         = 1'b0;
    rx_tlp_discard  = 0;
    ecrc_gen_enb    = 1'b0 ;
    ecrc_chk_enb    = 1'b0 ;
    enb_log         = 1'b0 ;
    no_pcie_train   = 1'b0;
end

// =============================================================================
// Timeout generation to finish hung test cases.
// =============================================================================

parameter TIMEOUT_NUM = 150000;
initial begin
   repeat (TIMEOUT_NUM) @(posedge sys_clk_125);
   $display(" ERROR : Simulation Time Out, Test case Terminated at time : %0t", $time) ;
   $finish ;
end

// =============================================================================
// Simulation Time Display for long test cases
initial begin
   forever begin
      #1000000;  //every 10k (add extra zero - timescale)  ns just display Time value - useful for SDF sim
      $display("                                       Displaying Sim. Time : %0t", $time) ;
   end
end

// =============================================================================
// Clocks generation
// =============================================================================

// 200 Mhz clock input to PLL to generate 125MHz for PCS

always   #25         clk_200      <= ~clk_200 ;

   assign tb_sys_clk = tb_top.u1_top.u1_pcs_pipe.PCLK;
    assign sys_clk_125 = sys_clk_125_temp;

// =============================================================================
// WISHBONE TASKS
// =============================================================================
`ifdef WISHBONE
initial begin
   RST_I = 'd0 ;
   CLK_I = 'd0 ;
   ADR_I = 'd0 ;
   DAT_I = 'd0 ;
   SEL_I = 'd0 ;
   WE_I  = 'd0 ;
   STB_I = 'd0 ;
   CYC_I = 'd0 ;
end

always #40 CLK_I <= ~CLK_I ;

// =============================================================================
// Wishbone write task
// =============================================================================
task wb_write;
input [12:0]     addr;
input [31:0]     wr_data;
integer          j;
begin
   repeat (1) @(posedge  CLK_I) ;
   ADR_I <= addr ;
   DAT_I <= wr_data ;
   STB_I <= 1'b1 ;
   CYC_I <= 1'b1 ;
   WE_I  <= 1'b1 ;
   for (j=0; j<=20; j=j+1) begin
      if (ACK_O) begin
         $display("---INFO : Wishbone Write to Addr:%h, Data:%h at %0t", addr, wr_data, $time ) ;
         STB_I <= 1'b0 ;
         CYC_I <= 1'b0 ;
         WE_I  <= 1'b0 ;
         j     <= 100;
      end
      else if (j==20) begin
         STB_I <= 1'b0 ;
         CYC_I <= 1'b0 ;
         WE_I  <= 1'b0 ;
         $display("---ERROR : Wishbone slave NOT responding at %0t", $time ) ;
      end
      repeat (1) @(posedge  CLK_I) ;
   end
end
endtask
// =============================================================================
// Wishbone read task
// =============================================================================
task wb_read;
input  [12:0]    addr;
output [31:0]    rd_data;
integer          i;
begin
   repeat (1) @(posedge  CLK_I) ;
   ADR_I <= addr ;
   STB_I <= 1'b1 ;
   CYC_I <= 1'b1 ;
   WE_I  <= 1'b0 ;
   for (i=0; i<=20; i=i+1) begin
      if (ACK_O) begin
         rd_data <= DAT_O ;
         $display("---INFO : Wishbone Read to Addr:%h, Data:%h at %0t", addr, DAT_O, $time ) ;
         STB_I   <= 1'b0 ;
         CYC_I   <= 1'b0 ;
         WE_I    <= 1'b0 ;
         i       <= 100;
      end
      else if (i==20) begin
         $display("---ERROR : Wishbone slave NOT responding at %0t", $time ) ;
         STB_I   <= 1'b0 ;
         CYC_I   <= 1'b0 ;
         WE_I    <= 1'b0 ;
      end
      repeat (1) @(posedge  CLK_I) ;
   end
end
endtask
`endif
// =============================================================================
// Reset Task
// =============================================================================
task  RST_DUT;
begin
   repeat(2) @(negedge  clk_200);
   rst_n         = 1'b1;
   `ifdef ECP5UM
   `ifdef SOFT_LOL_ENABLE
      force u1_top.u1_pcs_pipe.pcs_top_0.sll_inst.LRCLK_TC_w  = 16'd200;
   `endif
   `endif
   repeat(2) @(negedge  clk_200);
   rst_n         = 1'b0;
   #40000;
   rst_n         = 1'b1;

   `ifdef ECP3
   repeat (50) @ (posedge clk_200) ;
   force u1_top.u1_pcs_pipe.pcie_ip_rstn  = 1'b1; // de-assert delayed reset to core
   `endif

   repeat(10) @(negedge  clk_200);
end
endtask
`ifdef SOFT_LOL_ENABLE
defparam u1_top.u1_pcs_pipe.pcs_top_0.sll_inst.PPCLK_TC = 250;
`endif

// =============================================================================
// Reset Task
// =============================================================================
task  DEFAULT_CREDITS;
reg [2:0]  tmp_vcid;
begin
   for(i=0; i<= `NUM_VC-1; i=i+1) begin
      tmp_vcid = i;
      case(tmp_vcid)
        `ifdef EN_VC0
         0 : begin
            u_tbrx[0].FC_INIT(P, 8'd127, 12'd2047);
            u_tbrx[0].FC_INIT(NP, 8'd127, 12'd2047);
            u_tbrx[0].FC_INIT(CPLX, 8'd127, 12'd2047);
        end
        `endif
      endcase
   end
end
endtask

// =============================================================================
// Check on error signal & stop simulation if error = 1
// =============================================================================
always @(posedge sys_clk_125) begin
   if (error) begin
      repeat (200) @(posedge sys_clk_125);
      $finish;
   end
end


// =============================================================================
// TBTX TASKS
// =============================================================================
// HEADER FORMAT FOR MEM READ
// (Fmt & Type decides what kind of Request)
//           ================================================
//           R  Fmt  Type  R TC  R R R R  TD EP ATTR R Length
//           Requester ID -- TAG  -- Last DW BE -- First DW BE
//           ----------   Address [63:32] -------------------
//            ---------   Address [31:2] -----------------  R
//           ================================================
// Fixed values :
//            Fmt[1] = 0
//            First DW BE = 4'b0000
//            Last DW BE  = 4'b0000
//            ATTR is always 2'b00 {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
// Arguments :
//            TC/VC, Address[31:2], Fmt[0]/hdr_Type, Length
// Registers that are used :
//            TBTX_TD, TBTX_EP, First_DW_BE, TBTX_UPPER32_ADDR
// For hdr_type 4 DW TBTX_UPPER32_ADDR is used (and Fmt[0] = 1)
//
// NOTE : Length is not the LENGTH of this MEM_RD Pkt
// =============================================================================
task tbtx_mem_rd;
input  [2:0]   vcid;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //0: 3 DW Header --- 1: 4 DW (with TBTX_UPPER32_ADDR)
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_mem_rd(addr,length,hdr_type);
     `endif
   endcase
end
endtask


// =============================================================================
// HEADER FORMAT FOR MEM WRITE
// (Fmt & Type decides what kind of Request)
//           ================================================
//           R  Fmt  Type  R TC  R R R R  TD EP ATTR R Length
//           Requester ID -- TAG  -- Last DW BE -- First DW BE
//           ----------   Address [63:32] -------------------
//            ---------   Address [31:2] -----------------  R
//           ================================================
// Arguments :
//            TC/VC, Address[31:2], Fmt[0]/hdr_Type
// Registers that are used :
//            TBTX_TD, TBTX_EP, First_DW_BE, Last_DW_BE, TBTX_UPPER32_ADDR
// For hdr_type 4 DW TBTX_UPPER32_ADDR is used (and Fmt[0] = 1)
// =============================================================================
task tbtx_mem_wr;
input  [2:0]   vcid;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW
input  [9:0]   nul_len;
input          nullify;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_mem_wr(addr, length,hdr_type, nul_len, nullify);
     `endif
   endcase
end
endtask

// =============================================================================
task tbtx_msg;
input  [2:0]   vcid;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_msg;
     `endif
   endcase
end
endtask

// =============================================================================
task tbtx_msg_d;
input  [2:0]   vcid;
input [9:0]   length;
input  [9:0]   nul_len;
input          nullify;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_msg_d(length, nul_len, nullify);
     `endif
   endcase
end
endtask

// =============================================================================
task tbtx_cfg_rd;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
begin
   u_tbtx[0].tbtx_cfg_rd(cfg, addr);
end
endtask
// =============================================================================
task tbtx_cfg_wr;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
begin
   u_tbtx[0].tbtx_cfg_wr(cfg, addr);
end
endtask
// =============================================================================
task tbtx_io_rd;
input  [31:0]  addr;
begin
   u_tbtx[0].tbtx_io_rd(addr);
end
endtask

// =============================================================================
task tbtx_io_wr;
input  [31:0]  addr;
begin
   u_tbtx[0].tbtx_io_wr(addr);
end
endtask

// =============================================================================
task tbtx_cpl;
input  [2:0]   vcid;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_cpl(byte_cnt, lower_addr,status);
     `endif
   endcase
end
endtask

// =============================================================================
task tbtx_cpl_d;
input  [2:0]   vcid;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
input [9:0]   length;
input  [9:0]  nul_len;
input         nullify;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbtx[0].tbtx_cpl_d(byte_cnt, lower_addr,status, length, nul_len, nullify);
     `endif
   endcase
end
endtask

// =============================================================================
// TBRX TASKS
// =============================================================================
//         Error Types
//  NO_TLP_ERR     = 4'b0000;
//  ECRC_ERR       = 4'b0001;
//  UNSUP_ERR      = 4'b0010;
//  MALF_ERR       = 4'b0011;
//  FMT_TYPE_ERR   = 4'b1111;
// =============================================================================
// tbrx_tlp:
// This task is used when User wants create TLP manually
// For fmt_type error this should be used, no other tasks supports this error.
// =============================================================================
task tbrx_tlp;  //When Giving Malformed TLP (Only fmt & Type error)
input  [2:0]  vcid;
input  [3:0]  Error_Type;
input         hdr_type;  //3 DW or 4 DW
input [31:0]  h1_msb;
input [31:0]  h1_lsb;
input [31:0]  h2_msb;
input [31:0]  h2_lsb;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_tlp(Error_Type, hdr_type, h1_msb, h1_lsb, h2_msb, h2_lsb);
     `endif

   endcase

end
endtask

// =============================================================================
task tbrx_mem_rd;
input  [2:0]   vcid;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_mem_rd(addr,length,hdr_type,Error_Type);
     `endif
   endcase
end
endtask
// =============================================================================
task tbrx_mem_wr;
input  [2:0]   vcid;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_mem_wr(addr,length,hdr_type,Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
task tbrx_msg;
input  [2:0]   vcid;
input [9:0]    length;
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_msg(length,Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
task tbrx_msg_d;
input  [2:0]   vcid;
input [9:0]    length;
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_msg_d(length, Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
task tbrx_cfg_rd;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
input  [9:0]   length;
input  [3:0]   Error_Type;
begin
   u_tbrx[0].tbrx_cfg_rd(cfg, addr,length, Error_Type);
end
endtask
// =============================================================================
task tbrx_cfg_wr;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
input  [9:0]   length;
input  [3:0]   Error_Type;
begin
   u_tbrx[0].tbrx_cfg_wr(cfg, addr,length, Error_Type);
end
endtask
// =============================================================================
task tbrx_io_rd;
input  [31:0]  addr;
input  [9:0]   length;
input  [3:0]   Error_Type;
begin
   u_tbrx[0].tbrx_io_rd(addr,length, Error_Type);
end
endtask

// =============================================================================
task tbrx_io_wr;
input  [31:0]  addr;
input  [9:0]   length;
input  [3:0]   Error_Type;
begin
   u_tbrx[0].tbrx_io_wr(addr,length, Error_Type);
end
endtask

// =============================================================================
task tbrx_cpl;
input  [2:0]  vcid;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
input  [9:0]   length;
input  [3:0]  Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_cpl(byte_cnt, lower_addr,status,length, Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
task tbrx_cpl_d;
input  [2:0]  vcid;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
input [9:0]   length;
input  [3:0]  Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_cpl_d(byte_cnt, lower_addr,status, length,Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
// TASKS WITH TC INPUT
// =============================================================================
task tbrx_mem_rd_tc;
input  [2:0]   vcid;
input  [2:0]   tc;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_mem_rd_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
   endcase
end
endtask
// =============================================================================
task tbrx_mem_wr_tc;
input  [2:0]   vcid;
input  [2:0]   tc;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW
input  [3:0]   Error_Type;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].tbrx_mem_wr_tc(tc, addr,length,hdr_type,Error_Type);
     `endif
   endcase
end
endtask

// =============================================================================
// FLOW CONTROL TASKS
// =============================================================================
// Setting INIT values
// =============================================================================
task FC_INIT;
input  [2:0]  vcid;
input  [1:0]  ftyp;  // p/np/cpl
input  [7:0]  hdr;
input  [11:0] data;
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].FC_INIT(ftyp, hdr, data);
     `endif
   endcase
end
endtask

// =============================================================================
// Asserion/Deassertion of buf_status signals
// =============================================================================
task FC_BUF_STATUS;
input  [2:0]  vcid;
input  [2:0]  ftyp;  // ph/pd/nph/npd/cpl/cpld
input         set;   // Set=1: Assert the signal  , Set=0, De-assert the signal
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].FC_BUF_STATUS(ftyp, set);
     `endif
   endcase
end
endtask

// =============================================================================
// Asserion/Deassertion of Processed signals
// Onle pulse
// =============================================================================
task FC_PROCESSED;
input  [2:0]  vcid;
input  [2:0]  ftyp;  // ph/pd/nph/npd/cpl/cpld
input         set;   // Set=1: Assert the signal  , Set=0, De-assert the signal
begin
   case(vcid)
     `ifdef EN_VC0
      0 : u_tbrx[0].FC_PROCESSED(ftyp);
     `endif
   endcase
end
endtask
GSR GSR_INST (.GSR(rst_n));
PUR PUR_INST (.PUR(rst_n));

endmodule
