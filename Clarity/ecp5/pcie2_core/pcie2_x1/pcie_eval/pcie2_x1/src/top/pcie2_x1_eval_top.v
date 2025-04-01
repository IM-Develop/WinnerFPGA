module pcie2_x1_eval_top (
   // Clock and Reset
   input wire                     pll_refclki,        // 200MHz from EXTREF
   input wire                     rxrefclk,        // 200MHz from EXTREF
   input wire                     rst_n,

// ASIC side pins for PCSA.  These pins must exist for the PCS core.
   input  wire                    hdinp0,
   input  wire                    hdinn0,
   output wire                    hdoutp0,
   output wire                    hdoutn0,

   input wire                     no_pcie_train, // Disable the training process

// For VC Inputs
   input wire                     tx_req_vc0,          // VC0 Request from User
   input wire [63:0]              tx_data_vc0,         // VC0 Input data from user logic
   input wire                     tx_st_vc0,           // VC0 start of pkt from user logic.
   input wire                     tx_end_vc0,          // VC0 End of pkt from user logic.
   input wire                     tx_nlfy_vc0,         // VC0 End of nullified pkt from user logic.
   input wire                     tx_dwen_vc0,         // VC0 Dword enable from user logic.
   input wire                     ph_buf_status_vc0,   // VC0 Indicate the Full/alm.Full status of the PH buffers
   input wire                     pd_buf_status_vc0,   // VC0 Indicate PD Buffer has got space less than Max Pkt size
   input wire                     nph_buf_status_vc0,  // VC0 For NPH
   input wire                     npd_buf_status_vc0,  // VC0 For NPD
   input wire                     ph_processed_vc0,    // VC0 TL has processed one TLP Header - PH Type
   input wire                     pd_processed_vc0,    // VC0 TL has processed one TLP Data - PD TYPE
   input wire                     nph_processed_vc0,   // VC0 For NPH
   input wire                     npd_processed_vc0,   // VC0 For NPD



   output wire                    tx_val,          //
   output wire                    tx_rdy_vc0,      // VC0 TX ready indicating signal
   output wire [8:0]              tx_ca_ph_vc0,    // VC0 Available credit for Posted Type Headers
   output wire [12:0]             tx_ca_pd_vc0,    // VC0 For Posted - Data
   output wire [8:0]              tx_ca_nph_vc0,   // VC0 For Non-posted - Header
   output wire [12:0]             tx_ca_npd_vc0,   // VC0 For Non-posted - Data
   output wire [8:0]              tx_ca_cplh_vc0,  // VC0 For Completion - Header
   output wire [12:0]             tx_ca_cpld_vc0,  // VC0 For Completion - Data
   output wire                    tx_ca_p_recheck_vc0, //
   output wire                    tx_ca_cpl_recheck_vc0, //
   output wire [63:0]             rx_data_vc0,     // VC0 Receive data
   output wire                    rx_st_vc0,       // VC0 Receive data start
   output wire                    rx_end_vc0,      // VC0 Receive data end
   output wire                    rx_dwen_vc0,     // VC0 Receive Dword enable
   output wire                    rx_us_req_vc0 ,  // VC0 unsupported req received
   output wire                    rx_malf_tlp_vc0 ,// VC0 malformed TLP in received data

   output wire                    ffs_plol,
   output wire                    ffs_rlol_ch0,
   // Datal Link Control SM Status
   output wire                    dl_up,           // Data Link Layer is UP
   output wire                    sys_clk_125      // 125MHz output clock from core
  );

// =============================================================================
// Define Wires & Regs
// =============================================================================
wire                    rsl_rx_rdy;
wire [1:0]              power_down;
wire [2:0]              txp_margin;
wire                    txp_detect_rx_lb;
wire                    phy_status;

wire [15:0]             txp_data_ln0;
wire [1:0]              txp_data_k_ln0;
wire                    txp_elec_idle_ln0;
wire [1:0]              txp_compliance_ln0;

wire [15:0]             txp_data_ln1;
wire [1:0]              txp_data_k_ln1;
wire                    txp_elec_idle_ln1;
wire [1:0]              txp_compliance_ln1;

wire [15:0]             rxp_data_ln0;
wire [1:0]              rxp_data_k_ln0;
wire                    rxp_valid_ln0;
wire                    rxp_polarity_ln0;
wire                    rxp_elec_idle_ln0;
wire [2:0]              rxp_status_ln0;

wire [15:0]             rxp_data_ln1;
wire [1:0]              rxp_data_k_ln1;
wire                    rxp_valid_ln1;
wire                    rxp_polarity_ln1;
wire                    rxp_elec_idle_ln1;
wire [2:0]              rxp_status_ln1;

wire                     pclk;           //250MHz clk from PCS PIPE for 8 bit data
wire [1:0]               phy_cfgln;
wire [3:0]               phy_ltssm_state;
wire [2:0]               phy_ltssm_substate;
wire                     phy_l0;
wire                     phy_pol_compliance;
`ifdef SIMULATE
   wire                  sci_busy;
`endif
wire        [1:0]        infer_rx_eidle;

wire [15:0] txdata;
wire [1:0]  txdatak;

assign phy_l0         = (phy_ltssm_state == 'd3) ;
// =============================================================================
GSR GSR_INST (.GSR(rst_n));
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
 .flip_lanes                            (1'b0),
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
 .inta_n                                (1'b1),
 .msi                                   (8'd0),
 .force_lsm_active                      (1'b0),
 .force_rec_ei                          (1'b0),
 .force_phy_status                      (1'b0),
 .force_disable_scr                     (1'b0),
 .hl_snd_beacon                         (1'b0),
 .hl_disable_scr                        (1'b0),
 .hl_gto_dis                            (1'b0),
 .hl_gto_det                            (1'b0),
 .hl_gto_hrst                           (1'b0),
 .hl_gto_l0stx                          (1'b0),
 .hl_gto_l1                             (1'b0),
 .hl_gto_l2                             (1'b0),
 .hl_gto_l0stxfts                       (1'b0),
 .hl_gto_lbk                            (2'd0),
 .hl_gto_rcvry                          (1'b0),
 .hl_gto_cfg                            (1'b0),
 .no_pcie_train                         (no_pcie_train),
 .tx_dllp_val                           (2'd0),
 .tx_pmtype                             (3'd0),
 .tx_vsd_data                           (24'd0),
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
 .pd_num_vc0                            (8'd1),
 .npd_num_vc0                           (8'd1),
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
 .cmpln_tout                            (1'b0),
 .cmpltr_abort_np                       (1'b0),
 .cmpltr_abort_p                        (1'b0),
 .unexp_cmpln                           (1'b0),
 .ur_np_ext                             (1'b0),
 .ur_p_ext                              (1'b0),
 .np_req_pend                           (1'b0),
 .pme_status                            (1'b0),
 .flr_rdy_in                            (1'b0),
 .tx_lbk_data                           (64'd0),
 .tx_lbk_kcntl                          (8'd0),
 .vendor_id                             (16'd0),
 .device_id                             (16'd0),
 .rev_id                                (8'd0),
 .class_code                            (24'd0),
 .subsys_ven_id                         (16'd0),
 .subsys_id                             (16'd0),
 .load_id                               (1'b1),
`ifdef SIMULATE
 .sci_busy                              (sci_busy),
`endif
 // Outputs
 .tx_lbk_rdy                            (),
 .rx_lbk_data                           (),
 .rx_lbk_kcntl                          (),
 .tx_dllp_sent                          (),
 .rxdp_pmd_type                         (),
 .rxdp_vsd_data                         (),
 .rxdp_dllp_val                         (),
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
 .phy_cfgln_sum                         (),
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
 .rx_bar_hit                            (),
 .mm_enable                             (),
 .msi_enable                            (),
 .bus_num                               (),
 .dev_num                               (),
 .func_num                              (),
 .pm_power_state                        (),
 .pme_en                                (),
 .cmd_reg_out                           (),
 .dev_cntl_out                          (),
 .lnk_cntl_out                          (),
 .dev_cntl_2_out                        (),
 .initiate_flr                          (),
 .tx_rbuf_empty                         (),
 .tx_dllp_pend                          (),
 .rx_tlp_rcvd                           (),
 .dl_inactive                           (),
 .dl_init                               (),
 .dl_active                             (),
 .dl_up                                 (dl_up)
 );

endmodule
