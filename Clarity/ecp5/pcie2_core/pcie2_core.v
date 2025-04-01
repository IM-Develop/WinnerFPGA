/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module pcie2_core
//
module pcie2_core (pcie2_x1_bus_num, pcie2_x1_class_code, pcie2_x1_cmd_reg_out, 
            pcie2_x1_dev_cntl_2_out, pcie2_x1_dev_cntl_out, pcie2_x1_dev_num, 
            pcie2_x1_device_id, pcie2_x1_func_num, pcie2_x1_hl_gto_lbk, 
            pcie2_x1_lnk_cntl_out, pcie2_x1_mm_enable, pcie2_x1_msi, pcie2_x1_npd_num_vc0, 
            pcie2_x1_pd_num_vc0, pcie2_x1_phy_cfgln, pcie2_x1_phy_cfgln_sum, 
            pcie2_x1_phy_ltssm_state, pcie2_x1_pm_power_state, pcie2_x1_rev_id, 
            pcie2_x1_rx_bar_hit, pcie2_x1_rx_data_vc0, pcie2_x1_rx_lbk_data, 
            pcie2_x1_rx_lbk_kcntl, pcie2_x1_rxdp_dllp_val, pcie2_x1_rxdp_pmd_type, 
            pcie2_x1_rxdp_vsd_data, pcie2_x1_subsys_id, pcie2_x1_subsys_ven_id, 
            pcie2_x1_tx_ca_cpld_vc0, pcie2_x1_tx_ca_cplh_vc0, pcie2_x1_tx_ca_npd_vc0, 
            pcie2_x1_tx_ca_nph_vc0, pcie2_x1_tx_ca_pd_vc0, pcie2_x1_tx_ca_ph_vc0, 
            pcie2_x1_tx_data_vc0, pcie2_x1_tx_dllp_val, pcie2_x1_tx_lbk_data, 
            pcie2_x1_tx_lbk_kcntl, pcie2_x1_tx_pmtype, pcie2_x1_tx_vsd_data, 
            pcie2_x1_vendor_id, pcie2_extref_refclkn, pcie2_extref_refclko, 
            pcie2_extref_refclkp, pcie2_x1_cmpln_tout, pcie2_x1_cmpltr_abort_np, 
            pcie2_x1_cmpltr_abort_p, pcie2_x1_dl_active, pcie2_x1_dl_inactive, 
            pcie2_x1_dl_init, pcie2_x1_dl_up, pcie2_x1_flip_lanes, pcie2_x1_flr_rdy_in, 
            pcie2_x1_force_disable_scr, pcie2_x1_force_lsm_active, pcie2_x1_force_phy_status, 
            pcie2_x1_force_rec_ei, pcie2_x1_hdinn0, pcie2_x1_hdinp0, pcie2_x1_hdoutn0, 
            pcie2_x1_hdoutp0, pcie2_x1_hl_disable_scr, pcie2_x1_hl_gto_cfg, 
            pcie2_x1_hl_gto_det, pcie2_x1_hl_gto_dis, pcie2_x1_hl_gto_hrst, 
            pcie2_x1_hl_gto_l0stx, pcie2_x1_hl_gto_l0stxfts, pcie2_x1_hl_gto_l1, 
            pcie2_x1_hl_gto_l2, pcie2_x1_hl_gto_rcvry, pcie2_x1_hl_snd_beacon, 
            pcie2_x1_initiate_flr, pcie2_x1_inta_n, pcie2_x1_load_id, 
            pcie2_x1_msi_enable, pcie2_x1_no_pcie_train, pcie2_x1_np_req_pend, 
            pcie2_x1_npd_buf_status_vc0, pcie2_x1_npd_processed_vc0, pcie2_x1_nph_buf_status_vc0, 
            pcie2_x1_nph_processed_vc0, pcie2_x1_pd_buf_status_vc0, pcie2_x1_pd_processed_vc0, 
            pcie2_x1_ph_buf_status_vc0, pcie2_x1_ph_processed_vc0, pcie2_x1_phy_pol_compliance, 
            pcie2_x1_pll_refclki, pcie2_x1_pme_en, pcie2_x1_pme_status, 
            pcie2_x1_rst_n, pcie2_x1_rx_dwen_vc0, pcie2_x1_rx_end_vc0, 
            pcie2_x1_rx_malf_tlp_vc0, pcie2_x1_rx_st_vc0, pcie2_x1_rx_us_req_vc0, 
            pcie2_x1_rxrefclk, pcie2_x1_sys_clk_125, pcie2_x1_tx_ca_cpl_recheck_vc0, 
            pcie2_x1_tx_ca_p_recheck_vc0, pcie2_x1_tx_dllp_sent, pcie2_x1_tx_dwen_vc0, 
            pcie2_x1_tx_end_vc0, pcie2_x1_tx_lbk_rdy, pcie2_x1_tx_nlfy_vc0, 
            pcie2_x1_tx_rdy_vc0, pcie2_x1_tx_req_vc0, pcie2_x1_tx_st_vc0, 
            pcie2_x1_tx_val, pcie2_x1_unexp_cmpln, pcie2_x1_ur_np_ext, 
            pcie2_x1_ur_p_ext) /* synthesis sbp_module=true */ ;
    output [7:0]pcie2_x1_bus_num;
    input [23:0]pcie2_x1_class_code;
    output [5:0]pcie2_x1_cmd_reg_out;
    output [4:0]pcie2_x1_dev_cntl_2_out;
    output [14:0]pcie2_x1_dev_cntl_out;
    output [4:0]pcie2_x1_dev_num;
    input [15:0]pcie2_x1_device_id;
    output [2:0]pcie2_x1_func_num;
    input [1:0]pcie2_x1_hl_gto_lbk;
    output [7:0]pcie2_x1_lnk_cntl_out;
    output [2:0]pcie2_x1_mm_enable;
    input [7:0]pcie2_x1_msi;
    input [7:0]pcie2_x1_npd_num_vc0;
    input [7:0]pcie2_x1_pd_num_vc0;
    output [1:0]pcie2_x1_phy_cfgln;
    output [2:0]pcie2_x1_phy_cfgln_sum;
    output [3:0]pcie2_x1_phy_ltssm_state;
    output [1:0]pcie2_x1_pm_power_state;
    input [7:0]pcie2_x1_rev_id;
    output [6:0]pcie2_x1_rx_bar_hit;
    output [63:0]pcie2_x1_rx_data_vc0;
    output [63:0]pcie2_x1_rx_lbk_data;
    output [7:0]pcie2_x1_rx_lbk_kcntl;
    output [1:0]pcie2_x1_rxdp_dllp_val;
    output [2:0]pcie2_x1_rxdp_pmd_type;
    output [23:0]pcie2_x1_rxdp_vsd_data;
    input [15:0]pcie2_x1_subsys_id;
    input [15:0]pcie2_x1_subsys_ven_id;
    output [12:0]pcie2_x1_tx_ca_cpld_vc0;
    output [8:0]pcie2_x1_tx_ca_cplh_vc0;
    output [12:0]pcie2_x1_tx_ca_npd_vc0;
    output [8:0]pcie2_x1_tx_ca_nph_vc0;
    output [12:0]pcie2_x1_tx_ca_pd_vc0;
    output [8:0]pcie2_x1_tx_ca_ph_vc0;
    input [63:0]pcie2_x1_tx_data_vc0;
    input [1:0]pcie2_x1_tx_dllp_val;
    input [63:0]pcie2_x1_tx_lbk_data;
    input [7:0]pcie2_x1_tx_lbk_kcntl;
    input [2:0]pcie2_x1_tx_pmtype;
    input [23:0]pcie2_x1_tx_vsd_data;
    input [15:0]pcie2_x1_vendor_id;
    input pcie2_extref_refclkn;
    output pcie2_extref_refclko;
    input pcie2_extref_refclkp;
    input pcie2_x1_cmpln_tout;
    input pcie2_x1_cmpltr_abort_np;
    input pcie2_x1_cmpltr_abort_p;
    output pcie2_x1_dl_active;
    output pcie2_x1_dl_inactive;
    output pcie2_x1_dl_init;
    output pcie2_x1_dl_up;
    input pcie2_x1_flip_lanes;
    input pcie2_x1_flr_rdy_in;
    input pcie2_x1_force_disable_scr;
    input pcie2_x1_force_lsm_active;
    input pcie2_x1_force_phy_status;
    input pcie2_x1_force_rec_ei;
    input pcie2_x1_hdinn0;
    input pcie2_x1_hdinp0;
    output pcie2_x1_hdoutn0;
    output pcie2_x1_hdoutp0;
    input pcie2_x1_hl_disable_scr;
    input pcie2_x1_hl_gto_cfg;
    input pcie2_x1_hl_gto_det;
    input pcie2_x1_hl_gto_dis;
    input pcie2_x1_hl_gto_hrst;
    input pcie2_x1_hl_gto_l0stx;
    input pcie2_x1_hl_gto_l0stxfts;
    input pcie2_x1_hl_gto_l1;
    input pcie2_x1_hl_gto_l2;
    input pcie2_x1_hl_gto_rcvry;
    input pcie2_x1_hl_snd_beacon;
    output pcie2_x1_initiate_flr;
    input pcie2_x1_inta_n;
    input pcie2_x1_load_id;
    output pcie2_x1_msi_enable;
    input pcie2_x1_no_pcie_train;
    input pcie2_x1_np_req_pend;
    input pcie2_x1_npd_buf_status_vc0;
    input pcie2_x1_npd_processed_vc0;
    input pcie2_x1_nph_buf_status_vc0;
    input pcie2_x1_nph_processed_vc0;
    input pcie2_x1_pd_buf_status_vc0;
    input pcie2_x1_pd_processed_vc0;
    input pcie2_x1_ph_buf_status_vc0;
    input pcie2_x1_ph_processed_vc0;
    output pcie2_x1_phy_pol_compliance;
    input pcie2_x1_pll_refclki;
    output pcie2_x1_pme_en;
    input pcie2_x1_pme_status;
    input pcie2_x1_rst_n;
    output pcie2_x1_rx_dwen_vc0;
    output pcie2_x1_rx_end_vc0;
    output pcie2_x1_rx_malf_tlp_vc0;
    output pcie2_x1_rx_st_vc0;
    output pcie2_x1_rx_us_req_vc0;
    input pcie2_x1_rxrefclk;
    output pcie2_x1_sys_clk_125;
    output pcie2_x1_tx_ca_cpl_recheck_vc0;
    output pcie2_x1_tx_ca_p_recheck_vc0;
    output pcie2_x1_tx_dllp_sent;
    input pcie2_x1_tx_dwen_vc0;
    input pcie2_x1_tx_end_vc0;
    output pcie2_x1_tx_lbk_rdy;
    input pcie2_x1_tx_nlfy_vc0;
    output pcie2_x1_tx_rdy_vc0;
    input pcie2_x1_tx_req_vc0;
    input pcie2_x1_tx_st_vc0;
    output pcie2_x1_tx_val;
    input pcie2_x1_unexp_cmpln;
    input pcie2_x1_ur_np_ext;
    input pcie2_x1_ur_p_ext;
    
    
    wire pcs_clkdiv0_CDIV1_sig, pcs_clkdiv0_CDIVX_sig, pcs_clkdiv0_CLKI_sig, 
        n1;
    
    pcie2_extref pcie2_extref_inst (.refclkn(pcie2_extref_refclkn), .refclko(pcie2_extref_refclko), 
            .refclkp(pcie2_extref_refclkp));
    pcie2_x1 pcie2_x1_inst (.bus_num({pcie2_x1_bus_num}), .class_code({pcie2_x1_class_code}), 
            .cmd_reg_out({pcie2_x1_cmd_reg_out}), .dev_cntl_2_out({pcie2_x1_dev_cntl_2_out}), 
            .dev_cntl_out({pcie2_x1_dev_cntl_out}), .dev_num({pcie2_x1_dev_num}), 
            .device_id({pcie2_x1_device_id}), .func_num({pcie2_x1_func_num}), 
            .hl_gto_lbk({pcie2_x1_hl_gto_lbk}), .lnk_cntl_out({pcie2_x1_lnk_cntl_out}), 
            .mm_enable({pcie2_x1_mm_enable}), .msi({pcie2_x1_msi}), .npd_num_vc0({pcie2_x1_npd_num_vc0}), 
            .pd_num_vc0({pcie2_x1_pd_num_vc0}), .phy_cfgln({pcie2_x1_phy_cfgln}), 
            .phy_cfgln_sum({pcie2_x1_phy_cfgln_sum}), .phy_ltssm_state({pcie2_x1_phy_ltssm_state}), 
            .pm_power_state({pcie2_x1_pm_power_state}), .rev_id({pcie2_x1_rev_id}), 
            .rx_bar_hit({pcie2_x1_rx_bar_hit}), .rx_data_vc0({pcie2_x1_rx_data_vc0}), 
            .rx_lbk_data({pcie2_x1_rx_lbk_data}), .rx_lbk_kcntl({pcie2_x1_rx_lbk_kcntl}), 
            .rxdp_dllp_val({pcie2_x1_rxdp_dllp_val}), .rxdp_pmd_type({pcie2_x1_rxdp_pmd_type}), 
            .rxdp_vsd_data({pcie2_x1_rxdp_vsd_data}), .subsys_id({pcie2_x1_subsys_id}), 
            .subsys_ven_id({pcie2_x1_subsys_ven_id}), .tx_ca_cpld_vc0({pcie2_x1_tx_ca_cpld_vc0}), 
            .tx_ca_cplh_vc0({pcie2_x1_tx_ca_cplh_vc0}), .tx_ca_npd_vc0({pcie2_x1_tx_ca_npd_vc0}), 
            .tx_ca_nph_vc0({pcie2_x1_tx_ca_nph_vc0}), .tx_ca_pd_vc0({pcie2_x1_tx_ca_pd_vc0}), 
            .tx_ca_ph_vc0({pcie2_x1_tx_ca_ph_vc0}), .tx_data_vc0({pcie2_x1_tx_data_vc0}), 
            .tx_dllp_val({pcie2_x1_tx_dllp_val}), .tx_lbk_data({pcie2_x1_tx_lbk_data}), 
            .tx_lbk_kcntl({pcie2_x1_tx_lbk_kcntl}), .tx_pmtype({pcie2_x1_tx_pmtype}), 
            .tx_vsd_data({pcie2_x1_tx_vsd_data}), .vendor_id({pcie2_x1_vendor_id}), 
            .cmpln_tout(pcie2_x1_cmpln_tout), .cmpltr_abort_np(pcie2_x1_cmpltr_abort_np), 
            .cmpltr_abort_p(pcie2_x1_cmpltr_abort_p), .dl_active(pcie2_x1_dl_active), 
            .dl_inactive(pcie2_x1_dl_inactive), .dl_init(pcie2_x1_dl_init), 
            .dl_up(pcie2_x1_dl_up), .flip_lanes(pcie2_x1_flip_lanes), .flr_rdy_in(pcie2_x1_flr_rdy_in), 
            .force_disable_scr(pcie2_x1_force_disable_scr), .force_lsm_active(pcie2_x1_force_lsm_active), 
            .force_phy_status(pcie2_x1_force_phy_status), .force_rec_ei(pcie2_x1_force_rec_ei), 
            .hdinn0(pcie2_x1_hdinn0), .hdinp0(pcie2_x1_hdinp0), .hdoutn0(pcie2_x1_hdoutn0), 
            .hdoutp0(pcie2_x1_hdoutp0), .hl_disable_scr(pcie2_x1_hl_disable_scr), 
            .hl_gto_cfg(pcie2_x1_hl_gto_cfg), .hl_gto_det(pcie2_x1_hl_gto_det), 
            .hl_gto_dis(pcie2_x1_hl_gto_dis), .hl_gto_hrst(pcie2_x1_hl_gto_hrst), 
            .hl_gto_l0stx(pcie2_x1_hl_gto_l0stx), .hl_gto_l0stxfts(pcie2_x1_hl_gto_l0stxfts), 
            .hl_gto_l1(pcie2_x1_hl_gto_l1), .hl_gto_l2(pcie2_x1_hl_gto_l2), 
            .hl_gto_rcvry(pcie2_x1_hl_gto_rcvry), .hl_snd_beacon(pcie2_x1_hl_snd_beacon), 
            .initiate_flr(pcie2_x1_initiate_flr), .inta_n(pcie2_x1_inta_n), 
            .load_id(pcie2_x1_load_id), .msi_enable(pcie2_x1_msi_enable), 
            .no_pcie_train(pcie2_x1_no_pcie_train), .np_req_pend(pcie2_x1_np_req_pend), 
            .npd_buf_status_vc0(pcie2_x1_npd_buf_status_vc0), .npd_processed_vc0(pcie2_x1_npd_processed_vc0), 
            .nph_buf_status_vc0(pcie2_x1_nph_buf_status_vc0), .nph_processed_vc0(pcie2_x1_nph_processed_vc0), 
            .pd_buf_status_vc0(pcie2_x1_pd_buf_status_vc0), .pd_processed_vc0(pcie2_x1_pd_processed_vc0), 
            .ph_buf_status_vc0(pcie2_x1_ph_buf_status_vc0), .ph_processed_vc0(pcie2_x1_ph_processed_vc0), 
            .phy_pol_compliance(pcie2_x1_phy_pol_compliance), .pll_refclki(pcie2_x1_pll_refclki), 
            .pme_en(pcie2_x1_pme_en), .pme_status(pcie2_x1_pme_status), 
            .rst_n(pcie2_x1_rst_n), .rx_dwen_vc0(pcie2_x1_rx_dwen_vc0), 
            .rx_end_vc0(pcie2_x1_rx_end_vc0), .rx_malf_tlp_vc0(pcie2_x1_rx_malf_tlp_vc0), 
            .rx_st_vc0(pcie2_x1_rx_st_vc0), .rx_us_req_vc0(pcie2_x1_rx_us_req_vc0), 
            .rxrefclk(pcie2_x1_rxrefclk), .sys_clk_125(pcie2_x1_sys_clk_125), 
            .tx_ca_cpl_recheck_vc0(pcie2_x1_tx_ca_cpl_recheck_vc0), .tx_ca_p_recheck_vc0(pcie2_x1_tx_ca_p_recheck_vc0), 
            .tx_dllp_sent(pcie2_x1_tx_dllp_sent), .tx_dwen_vc0(pcie2_x1_tx_dwen_vc0), 
            .tx_end_vc0(pcie2_x1_tx_end_vc0), .tx_lbk_rdy(pcie2_x1_tx_lbk_rdy), 
            .tx_nlfy_vc0(pcie2_x1_tx_nlfy_vc0), .tx_rdy_vc0(pcie2_x1_tx_rdy_vc0), 
            .tx_req_vc0(pcie2_x1_tx_req_vc0), .tx_st_vc0(pcie2_x1_tx_st_vc0), 
            .tx_val(pcie2_x1_tx_val), .unexp_cmpln(pcie2_x1_unexp_cmpln), 
            .ur_np_ext(pcie2_x1_ur_np_ext), .ur_p_ext(pcie2_x1_ur_p_ext));
    PCSCLKDIV pcs_clkdiv0 (.CLKI(pcs_clkdiv0_CLKI_sig), .RST(n1), .SEL2(1'b0), 
            .SEL1(1'b1), .SEL0(1'b0), .CDIV1(pcs_clkdiv0_CDIV1_sig), .CDIVX(pcs_clkdiv0_CDIVX_sig));
    not (n1, pcie2_x1_rst_n) ;
    
endmodule

