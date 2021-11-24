--VHDL instantiation template

component pcie_core is
    port (pcie_x1_bus_num: out std_logic_vector(7 downto 0);
        pcie_x1_class_code: in std_logic_vector(23 downto 0);
        pcie_x1_cmd_reg_out: out std_logic_vector(5 downto 0);
        pcie_x1_dev_cntl_out: out std_logic_vector(14 downto 0);
        pcie_x1_dev_num: out std_logic_vector(4 downto 0);
        pcie_x1_device_id: in std_logic_vector(15 downto 0);
        pcie_x1_func_num: out std_logic_vector(2 downto 0);
        pcie_x1_lnk_cntl_out: out std_logic_vector(7 downto 0);
        pcie_x1_mm_enable: out std_logic_vector(2 downto 0);
        pcie_x1_msi: in std_logic_vector(7 downto 0);
        pcie_x1_npd_num_vc0: in std_logic_vector(7 downto 0);
        pcie_x1_pd_num_vc0: in std_logic_vector(7 downto 0);
        pcie_x1_phy_ltssm_state: out std_logic_vector(3 downto 0);
        pcie_x1_pm_power_state: out std_logic_vector(1 downto 0);
        pcie_x1_rev_id: in std_logic_vector(7 downto 0);
        pcie_x1_rx_bar_hit: out std_logic_vector(6 downto 0);
        pcie_x1_rx_data_vc0: out std_logic_vector(15 downto 0);
        pcie_x1_rx_lbk_data: out std_logic_vector(15 downto 0);
        pcie_x1_rx_lbk_kcntl: out std_logic_vector(1 downto 0);
        pcie_x1_rxdp_dllp_val: out std_logic_vector(1 downto 0);
        pcie_x1_rxdp_pmd_type: out std_logic_vector(2 downto 0);
        pcie_x1_rxdp_vsd_data: out std_logic_vector(23 downto 0);
        pcie_x1_sci_addr: in std_logic_vector(5 downto 0);
        pcie_x1_sci_rddata: out std_logic_vector(7 downto 0);
        pcie_x1_sci_wrdata: in std_logic_vector(7 downto 0);
        pcie_x1_subsys_id: in std_logic_vector(15 downto 0);
        pcie_x1_subsys_ven_id: in std_logic_vector(15 downto 0);
        pcie_x1_tx_ca_cpld_vc0: out std_logic_vector(12 downto 0);
        pcie_x1_tx_ca_cplh_vc0: out std_logic_vector(8 downto 0);
        pcie_x1_tx_ca_npd_vc0: out std_logic_vector(12 downto 0);
        pcie_x1_tx_ca_nph_vc0: out std_logic_vector(8 downto 0);
        pcie_x1_tx_ca_pd_vc0: out std_logic_vector(12 downto 0);
        pcie_x1_tx_ca_ph_vc0: out std_logic_vector(8 downto 0);
        pcie_x1_tx_data_vc0: in std_logic_vector(15 downto 0);
        pcie_x1_tx_dllp_val: in std_logic_vector(1 downto 0);
        pcie_x1_tx_lbk_data: in std_logic_vector(15 downto 0);
        pcie_x1_tx_lbk_kcntl: in std_logic_vector(1 downto 0);
        pcie_x1_tx_pmtype: in std_logic_vector(2 downto 0);
        pcie_x1_tx_vsd_data: in std_logic_vector(23 downto 0);
        pcie_x1_vendor_id: in std_logic_vector(15 downto 0);
        pcie_extref_refclkn: in std_logic;
        pcie_extref_refclkp: in std_logic;
        pcie_x1_cmpln_tout: in std_logic;
        pcie_x1_cmpltr_abort_np: in std_logic;
        pcie_x1_cmpltr_abort_p: in std_logic;
        pcie_x1_dl_active: out std_logic;
        pcie_x1_dl_inactive: out std_logic;
        pcie_x1_dl_init: out std_logic;
        pcie_x1_dl_up: out std_logic;
        pcie_x1_flip_lanes: in std_logic;
        pcie_x1_force_disable_scr: in std_logic;
        pcie_x1_force_lsm_active: in std_logic;
        pcie_x1_force_phy_status: in std_logic;
        pcie_x1_force_rec_ei: in std_logic;
        pcie_x1_hdinn0: in std_logic;
        pcie_x1_hdinp0: in std_logic;
        pcie_x1_hdoutn0: out std_logic;
        pcie_x1_hdoutp0: out std_logic;
        pcie_x1_hl_disable_scr: in std_logic;
        pcie_x1_hl_gto_cfg: in std_logic;
        pcie_x1_hl_gto_det: in std_logic;
        pcie_x1_hl_gto_dis: in std_logic;
        pcie_x1_hl_gto_hrst: in std_logic;
        pcie_x1_hl_gto_l0stx: in std_logic;
        pcie_x1_hl_gto_l0stxfts: in std_logic;
        pcie_x1_hl_gto_l1: in std_logic;
        pcie_x1_hl_gto_l2: in std_logic;
        pcie_x1_hl_gto_lbk: in std_logic;
        pcie_x1_hl_gto_rcvry: in std_logic;
        pcie_x1_hl_snd_beacon: in std_logic;
        pcie_x1_inta_n: in std_logic;
        pcie_x1_load_id: in std_logic;
        pcie_x1_msi_enable: out std_logic;
        pcie_x1_no_pcie_train: in std_logic;
        pcie_x1_np_req_pend: in std_logic;
        pcie_x1_npd_buf_status_vc0: in std_logic;
        pcie_x1_npd_processed_vc0: in std_logic;
        pcie_x1_nph_buf_status_vc0: in std_logic;
        pcie_x1_nph_processed_vc0: in std_logic;
        pcie_x1_pd_buf_status_vc0: in std_logic;
        pcie_x1_pd_processed_vc0: in std_logic;
        pcie_x1_ph_buf_status_vc0: in std_logic;
        pcie_x1_ph_processed_vc0: in std_logic;
        pcie_x1_phy_pol_compliance: out std_logic;
        pcie_x1_pme_en: out std_logic;
        pcie_x1_pme_status: in std_logic;
        pcie_x1_rst_n: in std_logic;
        pcie_x1_rx_end_vc0: out std_logic;
        pcie_x1_rx_malf_tlp_vc0: out std_logic;
        pcie_x1_rx_st_vc0: out std_logic;
        pcie_x1_rx_us_req_vc0: out std_logic;
        pcie_x1_sci_en: in std_logic;
        pcie_x1_sci_en_dual: in std_logic;
        pcie_x1_sci_int: out std_logic;
        pcie_x1_sci_rd: in std_logic;
        pcie_x1_sci_sel: in std_logic;
        pcie_x1_sci_sel_dual: in std_logic;
        pcie_x1_sci_wrn: in std_logic;
        pcie_x1_sys_clk_125: out std_logic;
        pcie_x1_tx_ca_cpl_recheck_vc0: out std_logic;
        pcie_x1_tx_ca_p_recheck_vc0: out std_logic;
        pcie_x1_tx_dllp_sent: out std_logic;
        pcie_x1_tx_end_vc0: in std_logic;
        pcie_x1_tx_lbk_rdy: out std_logic;
        pcie_x1_tx_nlfy_vc0: in std_logic;
        pcie_x1_tx_rdy_vc0: out std_logic;
        pcie_x1_tx_req_vc0: in std_logic;
        pcie_x1_tx_st_vc0: in std_logic;
        pcie_x1_unexp_cmpln: in std_logic;
        pcie_x1_ur_np_ext: in std_logic;
        pcie_x1_ur_p_ext: in std_logic
    );
    
end component pcie_core; -- sbp_module=true 
_inst: pcie_core port map (pcie_extref_refclkn => __,pcie_extref_refclkp => __,
            pcie_x1_bus_num => __,pcie_x1_class_code => __,pcie_x1_cmd_reg_out => __,
            pcie_x1_dev_cntl_out => __,pcie_x1_dev_num => __,pcie_x1_device_id => __,
            pcie_x1_func_num => __,pcie_x1_lnk_cntl_out => __,pcie_x1_mm_enable => __,
            pcie_x1_msi => __,pcie_x1_npd_num_vc0 => __,pcie_x1_pd_num_vc0 => __,
            pcie_x1_phy_ltssm_state => __,pcie_x1_pm_power_state => __,pcie_x1_rev_id => __,
            pcie_x1_rx_bar_hit => __,pcie_x1_rx_data_vc0 => __,pcie_x1_rx_lbk_data => __,
            pcie_x1_rx_lbk_kcntl => __,pcie_x1_rxdp_dllp_val => __,pcie_x1_rxdp_pmd_type => __,
            pcie_x1_rxdp_vsd_data => __,pcie_x1_sci_addr => __,pcie_x1_sci_rddata => __,
            pcie_x1_sci_wrdata => __,pcie_x1_subsys_id => __,pcie_x1_subsys_ven_id => __,
            pcie_x1_tx_ca_cpld_vc0 => __,pcie_x1_tx_ca_cplh_vc0 => __,pcie_x1_tx_ca_npd_vc0 => __,
            pcie_x1_tx_ca_nph_vc0 => __,pcie_x1_tx_ca_pd_vc0 => __,pcie_x1_tx_ca_ph_vc0 => __,
            pcie_x1_tx_data_vc0 => __,pcie_x1_tx_dllp_val => __,pcie_x1_tx_lbk_data => __,
            pcie_x1_tx_lbk_kcntl => __,pcie_x1_tx_pmtype => __,pcie_x1_tx_vsd_data => __,
            pcie_x1_vendor_id => __,pcie_x1_cmpln_tout => __,pcie_x1_cmpltr_abort_np => __,
            pcie_x1_cmpltr_abort_p => __,pcie_x1_dl_active => __,pcie_x1_dl_inactive => __,
            pcie_x1_dl_init => __,pcie_x1_dl_up => __,pcie_x1_flip_lanes => __,
            pcie_x1_force_disable_scr => __,pcie_x1_force_lsm_active => __,
            pcie_x1_force_phy_status => __,pcie_x1_force_rec_ei => __,pcie_x1_hdinn0 => __,
            pcie_x1_hdinp0 => __,pcie_x1_hdoutn0 => __,pcie_x1_hdoutp0 => __,
            pcie_x1_hl_disable_scr => __,pcie_x1_hl_gto_cfg => __,pcie_x1_hl_gto_det => __,
            pcie_x1_hl_gto_dis => __,pcie_x1_hl_gto_hrst => __,pcie_x1_hl_gto_l0stx => __,
            pcie_x1_hl_gto_l0stxfts => __,pcie_x1_hl_gto_l1 => __,pcie_x1_hl_gto_l2 => __,
            pcie_x1_hl_gto_lbk => __,pcie_x1_hl_gto_rcvry => __,pcie_x1_hl_snd_beacon => __,
            pcie_x1_inta_n => __,pcie_x1_load_id => __,pcie_x1_msi_enable => __,
            pcie_x1_no_pcie_train => __,pcie_x1_np_req_pend => __,pcie_x1_npd_buf_status_vc0 => __,
            pcie_x1_npd_processed_vc0 => __,pcie_x1_nph_buf_status_vc0 => __,
            pcie_x1_nph_processed_vc0 => __,pcie_x1_pd_buf_status_vc0 => __,
            pcie_x1_pd_processed_vc0 => __,pcie_x1_ph_buf_status_vc0 => __,
            pcie_x1_ph_processed_vc0 => __,pcie_x1_phy_pol_compliance => __,
            pcie_x1_pme_en => __,pcie_x1_pme_status => __,pcie_x1_rst_n => __,
            pcie_x1_rx_end_vc0 => __,pcie_x1_rx_malf_tlp_vc0 => __,pcie_x1_rx_st_vc0 => __,
            pcie_x1_rx_us_req_vc0 => __,pcie_x1_sci_en => __,pcie_x1_sci_en_dual => __,
            pcie_x1_sci_int => __,pcie_x1_sci_rd => __,pcie_x1_sci_sel => __,
            pcie_x1_sci_sel_dual => __,pcie_x1_sci_wrn => __,pcie_x1_sys_clk_125 => __,
            pcie_x1_tx_ca_cpl_recheck_vc0 => __,pcie_x1_tx_ca_p_recheck_vc0 => __,
            pcie_x1_tx_dllp_sent => __,pcie_x1_tx_end_vc0 => __,pcie_x1_tx_lbk_rdy => __,
            pcie_x1_tx_nlfy_vc0 => __,pcie_x1_tx_rdy_vc0 => __,pcie_x1_tx_req_vc0 => __,
            pcie_x1_tx_st_vc0 => __,pcie_x1_unexp_cmpln => __,pcie_x1_ur_np_ext => __,
            pcie_x1_ur_p_ext => __);
