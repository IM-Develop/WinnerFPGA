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
// Project          : USERNAME
// File             : USERNAME.v
// Title            :
// Dependencies     :
// Description      : User Top level for IP.
// =============================================================================
module pcie2_x1
( //--begin_ports--
//----------------------------
// Inputs
//----------------------------
// Clock and Reset
input                         pll_refclki,        // 200MHz from EXTREF
input                         rxrefclk,        // 200MHz from EXTREF
input                         rst_n,
input                         flip_lanes,

input                         inta_n,
input       [7:0]             msi,

// ASIC side pins for PCSA.  These pins must exist for the PCS core.
input                         hdinp0,
input                         hdinn0,

input                         tx_req_vc0,          // VC0 Request from User
input       [63:0]            tx_data_vc0,         // VC0 Input data from user logic
input                         tx_st_vc0,           // VC0 start of pkt from user logic.
input                         tx_end_vc0,          // VC0 End of pkt from user logic.
input                         tx_nlfy_vc0,         // VC0 End of nullified pkt from user logic.
input                         tx_dwen_vc0,         // VC0 Dword enable from user logic.
input                         ph_buf_status_vc0,   // VC0 Indicate the Full/alm.Full status of the PH buffers
input                         pd_buf_status_vc0,   // VC0 Indicate PD Buffer has got space less than Max Pkt size
input                         nph_buf_status_vc0,  // VC0 For NPH
input                         npd_buf_status_vc0,  // VC0 For NPD
input                         ph_processed_vc0,    // VC0 TL has processed one TLP Header - PH Type
input                         pd_processed_vc0,    // VC0 TL has processed one TLP Data - PD TYPE
input                         nph_processed_vc0,   // VC0 For NPH
input                         npd_processed_vc0,   // VC0 For NPD
input       [7:0]             pd_num_vc0,          // VC0 For PD -- No. of Data processed
input       [7:0]             npd_num_vc0,         // VC0 For PD

input                         force_lsm_active, //  Force LSM Status Active
input                         force_rec_ei,     //  Force Received Electrical Idle
input                         force_phy_status, //  Force PHY Connection Status
input                         force_disable_scr,//  Force Disable Scrambler to PCS
input                         hl_snd_beacon,    // HL req. to Send Beacon
input                         hl_disable_scr,   // HL req. to Disable Scrambling bit in TS1/TS2
input                         hl_gto_dis,       // HL req a jump to Disable
input                         hl_gto_det,       // HL req a jump to detect
input                         hl_gto_hrst,      // HL req a jump to Hot reset
input                         hl_gto_l0stx,     // HL req a jump to TX L0s
input                         hl_gto_l1,        // HL req a jump to L1
input                         hl_gto_l2,        // HL req a jump to L2
input                         hl_gto_l0stxfts,  // HL req a jump to L0s TX FTS
input       [1:0]             hl_gto_lbk,       // HL req a jump to Loopback
input                         hl_gto_rcvry,     // HL req a jump to recovery
input                         hl_gto_cfg,       // HL req a jump to CFG
input                         no_pcie_train,    // Disable the training process
// Power Management Interface
input       [1:0]             tx_dllp_val,      // Req for Sending PM/Vendor type DLLP
input       [2:0]             tx_pmtype,        // Power Management Type
input       [23:0]            tx_vsd_data,      // Vendor Type DLLP contents

input       [15:0]            vendor_id ,
input       [15:0]            device_id ,
input       [7:0]             rev_id ,
input       [23:0]            class_code ,
input       [15:0]            subsys_ven_id ,
input       [15:0]            subsys_id ,
input                         load_id ,
// From User logic
input                         cmpln_tout ,     // Completion time out.
input                         cmpltr_abort_np ,// Completor abort for NP type.
input                         cmpltr_abort_p , // Completor abort for P type.
input                         unexp_cmpln ,    // Unexpexted completion.
input                         ur_np_ext ,      // UR for NP type.
input                         ur_p_ext ,       // UR for P type.
input                         np_req_pend ,    // Non posted request is pending.
input                         pme_status ,     // PME status to reg 044h.
input                         flr_rdy_in ,     // ready for functional level reset

   // User Loop back data
input       [63:0]            tx_lbk_data,   // TX User Master Loopback data
input       [7:0]             tx_lbk_kcntl,  // TX User Master Loopback control

//----------------------------
// Outputs
//----------------------------
output wire                   hdoutp0,
output wire                   hdoutn0,

output wire [63:0]            rx_lbk_data,      // TX loop back is ready to accept data
output wire [7:0]             rx_lbk_kcntl,     // RX User Master Loopback data
output wire                   tx_lbk_rdy,       // RX User Master Loopback control

output wire [1:0]             phy_cfgln,           // Indicates the Configured Lanes
output wire [2:0]             phy_cfgln_sum,       // Number of Configured lanes
output wire                   phy_pol_compliance,  // Polling compliance
output wire [3:0]             phy_ltssm_state,     // Indicates the states of the ltssm

output wire                   tx_val,          //
output wire                   tx_rdy_vc0,      // VC0 TX ready indicating signal
output wire [8:0]             tx_ca_ph_vc0,    // VC0 Available credit for Posted Type Headers
output wire [12:0]            tx_ca_pd_vc0,    // VC0 For Posted - Data
output wire [8:0]             tx_ca_nph_vc0,   // VC0 For Non-posted - Header
output wire [12:0]            tx_ca_npd_vc0,   // VC0 For Non-posted - Data
output wire [8:0]             tx_ca_cplh_vc0,  // VC0 For Completion - Header
output wire [12:0]            tx_ca_cpld_vc0,  // VC0 For Completion - Data
output wire                   tx_ca_p_recheck_vc0, //
output wire                   tx_ca_cpl_recheck_vc0, //
output wire [63:0]            rx_data_vc0,     // VC0 Receive data
output wire                   rx_st_vc0,       // VC0 Receive data start
output wire                   rx_end_vc0,      // VC0 Receive data end
output wire                   rx_dwen_vc0,     // VC0 Receive Dword enable
output wire                   rx_us_req_vc0 ,  // VC0 unsupported req received
output wire                   rx_malf_tlp_vc0 ,// VC0 malformed TLP in received data
output wire [6:0]             rx_bar_hit ,     // Bar hit

output wire [2:0]             mm_enable ,     // Multiple message enable bits of Register
output wire                   msi_enable ,    // MSI enable bit of Register

// Wishbone Signals Output
// Power Management/ Vendor specific DLLP
output wire                   tx_dllp_sent,    // Requested PM DLLP is sent
output wire [2:0]             rxdp_pmd_type,   // PM DLLP type bits.
output wire [23:0]            rxdp_vsd_data ,  // Vendor specific DLLP data.
output wire [1:0]             rxdp_dllp_val,   // PM/Vendor specific DLLP valid.



// From Config Registers
output wire [7:0]             bus_num ,        // Bus number
output wire [4:0]             dev_num ,        // Device number
output wire [2:0]             func_num ,       // Function number
output wire [1:0]             pm_power_state , // Power state bits of Register at 044h
output wire                   pme_en ,         // PME_En at 044h
output wire [5:0]             cmd_reg_out ,    // Bits 10,8,6,2,1,0 From register 004h
output wire [14:0]            dev_cntl_out ,   // Divice control register at 060h
output wire [7:0]             lnk_cntl_out ,   // Link control register at 068h
output wire [4:0]             dev_cntl_2_out , // Divice control 2 register
output wire                   initiate_flr ,   // Initiate Function level rest

// Datal Link Control SM Status
output wire                   dl_inactive,     // Data Link Control SM is in INACTIVE state
output wire                   dl_init,         // INIT state
output wire                   dl_active,       // ACTIVE state
output wire                   dl_up,           // Data Link Layer is UP
output wire                   sys_clk_125      // 125MHz output clock from core
  )/* synthesis syn_preserve=1 */;

//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//--- Combinational Wire/Reg ---
//--------------------------------------------------------------------------
wire                          rsl_rx_rdy ;

wire                          pclk;
wire                          phy_status;
wire        [1:0]             power_down;
wire        [1:0]             rxp_data_k_ln0;
wire        [1:0]             rxp_data_k_ln1;
wire        [15:0]            rxp_data_ln0;
wire        [15:0]            rxp_data_ln1;
wire                          rxp_elec_idle_ln0;
wire                          rxp_elec_idle_ln1;
wire                          rxp_polarity_ln0;
wire                          rxp_polarity_ln1;
wire        [2:0]             rxp_status_ln0;
wire        [2:0]             rxp_status_ln1;
wire                          rxp_valid_ln0;
wire                          rxp_valid_ln1;
wire        [1:0]             txp_compliance_ln0;
wire        [1:0]             txp_compliance_ln1;
wire        [1:0]             txp_data_k_ln0;
wire        [1:0]             txp_data_k_ln1;
wire        [15:0]            txp_data_ln0;
wire        [15:0]            txp_data_ln1;
wire                          txp_deemph;
wire                          txp_detect_rx_lb;
wire                          txp_elec_idle_ln0;
wire                          txp_elec_idle_ln1;
wire        [2:0]             txp_margin;
wire        [1:0]             infer_rx_eidle;
wire        [2:0]             phy_ltssm_substate;

wire                          txp_rate;
wire                          ffs_plol    ;
wire                          ffs_rlol_ch0;

`ifdef SIMULATE
wire                          sci_busy;
`endif
wire                          phy_l0;

//--------------------------------------------------------------------------
//--- Registers ---
//--------------------------------------------------------------------------

assign phy_l0 = (phy_ltssm_state == 'd3);
// =============================================================================
//GSR GSR_INST (.GSR(rst_n));
PUR PUR_INST (.PUR(1'b1));

// =============================================================================
// SERDES/PCS instantiation in PIPE mode
// =============================================================================
pcie2_x1_phy u1_pcs_pipe
(
 // Inputs
 .pll_refclki                           (pll_refclki),
 .rxrefclk                              (rxrefclk),
 .RESET_n                               (rst_n),
 .hdinp0                                (hdinp0),
 .hdinn0                                (hdinn0),
 .TxData_0                              (txp_data_ln0[15:0]),
 .TxDataK_0                             (txp_data_k_ln0[1:0]),
 .TxCompliance_0                        (txp_compliance_ln0[1:0]),
 .TxElecIdle_0                          (txp_elec_idle_ln0),
 .RxPolarity_0                          (rxp_polarity_ln0),
 .TxDetectRx_Loopback                   (txp_detect_rx_lb),
 .Rate                                  (txp_rate),
 .TxDeemph                              (txp_deemph),
 .PowerDown                             (power_down[1:0]),
 .TxMargin                              (txp_margin[2:0]),
 .TxSwing                               (1'b0),
 .ctc_disable                           (1'b0),
 .phy_l0                                (phy_l0),
 .flip_lanes                            (flip_lanes),
 .phy_cfgln                             ({phy_cfgln[0],phy_cfgln[1]}),
 .phy_pol_compliance                    (phy_pol_compliance),
 // Outputs
 .PCLK                                  (pclk),
 .PCLK_125                              (sys_clk_125),
 .hdoutp0                               (hdoutp0),
 .hdoutn0                               (hdoutn0),
 .RxData_0                              (rxp_data_ln0[15:0]),
 .RxDataK_0                             (rxp_data_k_ln0[1:0]),
 .RxValid_0                             (rxp_valid_ln0),
 .RxElecIdle_0                          (rxp_elec_idle_ln0),
 .RxStatus_0                            (rxp_status_ln0[2:0]),
`ifdef SIMULATE
 .sci_busy                              (sci_busy), //----------
`endif
 .infer_rx_eidle                        (infer_rx_eidle),
 .ffs_plol                              (ffs_plol),
 .ffs_rlol_ch0                          (ffs_rlol_ch0),
 .ffs_rlol_ch1                          (),
 .pcie_ip_rstn                          (rsl_rx_rdy),
 .PhyStatus                             (phy_status)
 /*AUTOINST*/);

// =============================================================================
// PCI Express Core
// =============================================================================
pcie2_x1_core u1_dut
(
 // Inputs
 .sys_clk_250                           (pclk),
 .sys_clk_125                           (sys_clk_125),
 .rst_n                                 (rst_n),
 .inta_n                                (inta_n),
 .msi                                   (msi[7:0]),
 .force_lsm_active                      (force_lsm_active),
 .force_rec_ei                          (force_rec_ei),
 .force_phy_status                      (force_phy_status),
 .force_disable_scr                     (force_disable_scr),
 .hl_snd_beacon                         (hl_snd_beacon),
 .hl_disable_scr                        (hl_disable_scr),
 .hl_gto_dis                            (hl_gto_dis),
 .hl_gto_det                            (hl_gto_det),
 .hl_gto_hrst                           (hl_gto_hrst),
 .hl_gto_l0stx                          (hl_gto_l0stx),
 .hl_gto_l1                             (hl_gto_l1),
 .hl_gto_l2                             (hl_gto_l2),
 .hl_gto_l0stxfts                       (hl_gto_l0stxfts),
 .hl_gto_lbk                            (hl_gto_lbk[1:0]),
 .hl_gto_rcvry                          (hl_gto_rcvry),
 .hl_gto_cfg                            (hl_gto_cfg),
 .no_pcie_train                         (no_pcie_train),
 .tx_dllp_val                           (tx_dllp_val[1:0]),
 .tx_pmtype                             (tx_pmtype[2:0]),
 .tx_vsd_data                           (tx_vsd_data[23:0]),
 .tx_req_vc0                            (tx_req_vc0),
 .tx_data_vc0                           (tx_data_vc0[63:0]),
 .tx_st_vc0                             (tx_st_vc0),
 .tx_end_vc0                            (tx_end_vc0),
 .tx_nlfy_vc0                           (tx_nlfy_vc0),
 .ph_buf_status_vc0                     (ph_buf_status_vc0),
 .pd_buf_status_vc0                     (pd_buf_status_vc0),
 .nph_buf_status_vc0                    (nph_buf_status_vc0),
 .npd_buf_status_vc0                    (npd_buf_status_vc0),
 .ph_processed_vc0                      (ph_processed_vc0),
 .pd_processed_vc0                      (pd_processed_vc0),
 .nph_processed_vc0                     (nph_processed_vc0),
 .npd_processed_vc0                     (npd_processed_vc0),
 .pd_num_vc0                            (pd_num_vc0[7:0]),
 .npd_num_vc0                           (npd_num_vc0[7:0]),
 .tx_dwen_vc0                           (tx_dwen_vc0),
 .rxp_data_ln0                          (rxp_data_ln0[15:0]),
 .rxp_data_k_ln0                        (rxp_data_k_ln0[1:0]),
 .rxp_valid_ln0                         (rxp_valid_ln0),
 .rxp_elec_idle_ln0                     (rxp_elec_idle_ln0),
 .rxp_status_ln0                        (rxp_status_ln0[2:0]),
 .rxp_data_ln1                          (16'd0),
 .rxp_data_k_ln1                        (2'd0),
 .rxp_valid_ln1                         (1'b0),
 .rxp_elec_idle_ln1                     (1'b1),
 .rxp_status_ln1                        (3'd0),
 .phy_status                            (phy_status),
 .cmpln_tout                            (cmpln_tout),
 .cmpltr_abort_np                       (cmpltr_abort_np),
 .cmpltr_abort_p                        (cmpltr_abort_p),
 .unexp_cmpln                           (unexp_cmpln),
 .ur_np_ext                             (ur_np_ext),
 .ur_p_ext                              (ur_p_ext),
 .np_req_pend                           (np_req_pend),
 .pme_status                            (pme_status),
 .flr_rdy_in                            (flr_rdy_in),
 .tx_lbk_data                           (tx_lbk_data[63:0]),
 .tx_lbk_kcntl                          (tx_lbk_kcntl[(64/8)-1:0]),
 .vendor_id                             (vendor_id[15:0]),
 .device_id                             (device_id[15:0]),
 .rev_id                                (rev_id[7:0]),
 .class_code                            (class_code[23:0]),
 .subsys_ven_id                         (subsys_ven_id[15:0]),
 .subsys_id                             (subsys_id[15:0]),
 .load_id                               (load_id),
`ifdef SIMULATE
 .sci_busy                              (sci_busy),
`endif
 // Outputs
 .tx_lbk_rdy                            (tx_lbk_rdy),
 .rx_lbk_data                           (rx_lbk_data[63:0]),
 .rx_lbk_kcntl                          (rx_lbk_kcntl[(64/8)-1:0]),
 .tx_dllp_sent                          (tx_dllp_sent),
 .rxdp_pmd_type                         (rxdp_pmd_type[2:0]),
 .rxdp_vsd_data                         (rxdp_vsd_data[23:0]),
 .rxdp_dllp_val                         (rxdp_dllp_val[1:0]),
 .txp_data_ln0                          (txp_data_ln0[15:0]),
 .txp_data_k_ln0                        (txp_data_k_ln0[1:0]),
 .txp_elec_idle_ln0                     (txp_elec_idle_ln0),
 .txp_compliance_ln0                    (txp_compliance_ln0[1:0]),
 .rxp_polarity_ln0                      (rxp_polarity_ln0),
 .txp_data_ln1                          (txp_data_ln1[15:0]),
 .txp_data_k_ln1                        (txp_data_k_ln1[1:0]),
 .txp_elec_idle_ln1                     (txp_elec_idle_ln1),
 .txp_compliance_ln1                    (txp_compliance_ln1[1:0]),
 .rxp_polarity_ln1                      (rxp_polarity_ln1),
 .txp_detect_rx_lb                      (txp_detect_rx_lb),
 .txp_rate                              (txp_rate),
 .txp_deemph                            (txp_deemph),
 .txp_margin                            (txp_margin[2:0]),
 .reset_n                               (),
 .power_down                            (power_down[1:0]),
 .phy_pol_compliance                    (phy_pol_compliance),
 .phy_ltssm_state                       (phy_ltssm_state[3:0]),
 .phy_ltssm_substate                    (phy_ltssm_substate[2:0]),
 .phy_cfgln_sum                         (phy_cfgln_sum[2:0]),
 .phy_cfgln                             (phy_cfgln[1:0]),
 .tx_val                                (tx_val),
 .tx_rdy_vc0                            (tx_rdy_vc0),
 .tx_ca_ph_vc0                          (tx_ca_ph_vc0[8:0]),
 .tx_ca_pd_vc0                          (tx_ca_pd_vc0[12:0]),
 .tx_ca_nph_vc0                         (tx_ca_nph_vc0[8:0]),
 .tx_ca_npd_vc0                         (tx_ca_npd_vc0[12:0]),
 .tx_ca_cplh_vc0                        (tx_ca_cplh_vc0[8:0]),
 .tx_ca_cpld_vc0                        (tx_ca_cpld_vc0[12:0]),
 .tx_ca_p_recheck_vc0                   (tx_ca_p_recheck_vc0),
 .tx_ca_cpl_recheck_vc0                 (tx_ca_cpl_recheck_vc0),
 .rx_data_vc0                           (rx_data_vc0[63:0]),
 .rx_st_vc0                             (rx_st_vc0),
 .rx_end_vc0                            (rx_end_vc0),
 .rx_dwen_vc0                           (rx_dwen_vc0),
 .infer_rx_eidle                        (infer_rx_eidle),
 .rx_us_req_vc0                         (rx_us_req_vc0),
 .rx_malf_tlp_vc0                       (rx_malf_tlp_vc0),
 .rx_bar_hit                            (rx_bar_hit[6:0]),
 .mm_enable                             (mm_enable[2:0]),
 .msi_enable                            (msi_enable),
 .bus_num                               (bus_num[7:0]),
 .dev_num                               (dev_num[4:0]),
 .func_num                              (func_num[2:0]),
 .pm_power_state                        (pm_power_state[1:0]),
 .pme_en                                (pme_en),
 .cmd_reg_out                           (cmd_reg_out[5:0]),
 .dev_cntl_out                          (dev_cntl_out[14:0]),
 .lnk_cntl_out                          (lnk_cntl_out[7:0]),
 .dev_cntl_2_out                        (dev_cntl_2_out[4:0]),
 .initiate_flr                          (initiate_flr),
 .tx_rbuf_empty                         (),
 .tx_dllp_pend                          (),
 .rx_tlp_rcvd                           (),
 .dl_inactive                           (dl_inactive),
 .dl_init                               (dl_init),
 .dl_active                             (dl_active),
 .dl_up                                 (dl_up)
 );


endmodule
