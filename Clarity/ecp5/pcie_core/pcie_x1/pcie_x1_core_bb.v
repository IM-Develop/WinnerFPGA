module pcie_x1_core (
   input wire             sys_clk_250,      // 250 Mhz Clock     
   input wire             sys_clk_125,      // 125 Mhz Clock     
   input wire             rst_n,            // asynchronous system reset.
                                            
   input wire             inta_n,           
   input wire  [7:0]      msi,              
   input wire [15:0]      vendor_id ,       
   input wire [15:0]      device_id ,       
   input wire [7:0]       rev_id ,          
   input wire [23:0]      class_code ,      
   input wire [15:0]      subsys_ven_id ,   
   input wire [15:0]      subsys_id ,       
   input wire             load_id ,         
   input wire             force_lsm_active, //  Force LSM Status Active
   input wire             force_rec_ei,     //  Force Received Electrical Idle
   input wire             force_phy_status, //  Force PHY Connection Status
   input wire             force_disable_scr,//  Force Disable Scrambler to PCS

   input wire             hl_snd_beacon,    // HL req. to Send Beacon
   input wire             hl_disable_scr,   // HL req. to Disable Scrambling bit in TS1/TS2 
   input wire             hl_gto_dis,       // HL req a jump to Disable
   input wire             hl_gto_det,       // HL req a jump to detect
   input wire             hl_gto_hrst,      // HL req a jump to Hot reset
   input wire             hl_gto_l0stx,     // HL req a jump to TX L0s
   input wire             hl_gto_l1,        // HL req a jump to L1
   input wire             hl_gto_l2,        // HL req a jump to L2 
   input wire             hl_gto_l0stxfts,  // HL req a jump to L0s TX FTS 
   input wire             hl_gto_lbk,       // HL req a jump to Loopback
   input wire             hl_gto_rcvry,     // HL req a jump to recovery 
   input wire             hl_gto_cfg,       // HL req a jump to CFG 
   input wire             no_pcie_train,    // Disable the training process

   // Power Management Interface
   input wire  [1:0]      tx_dllp_val,      // Req for Sending PM/Vendor type DLLP
   input wire  [2:0]      tx_pmtype,        // Power Management Type
   input wire  [23:0]     tx_vsd_data,      // Vendor Type DLLP contents

   // For VC Inputs 
   input wire             tx_req_vc0,          // VC0 Request from User  
   input wire [15:0]      tx_data_vc0,         // VC0 Input data from user logic 
   input wire             tx_st_vc0,           // VC0 start of pkt from user logic.  
   input wire             tx_end_vc0,          // VC0 End of pkt from user logic. 
   input wire             tx_nlfy_vc0,         // VC0 End of nullified pkt from user logic.  
   input wire             ph_buf_status_vc0,   // VC0 Indicate the Full/alm.Full status of the PH buffers
   input wire             pd_buf_status_vc0,   // VC0 Indicate PD Buffer has got space less than Max Pkt size
   input wire             nph_buf_status_vc0,  // VC0 For NPH
   input wire             npd_buf_status_vc0,  // VC0 For NPD
   input wire             ph_processed_vc0,    // VC0 TL has processed one TLP Header - PH Type
   input wire             pd_processed_vc0,    // VC0 TL has processed one TLP Data - PD TYPE
   input wire             nph_processed_vc0,   // VC0 For NPH
   input wire             npd_processed_vc0,   // VC0 For NPD
   input wire [7:0]       pd_num_vc0,          // VC0 For PD -- No. of Data processed
   input wire [7:0]       npd_num_vc0,         // VC0 For PD

   input wire  [7:0]         rxp_data,        // CH0:PCI Express data from External Phy
   input wire                rxp_data_k,      // CH0:PCI Express Control from External Phy 
   input wire                rxp_valid,       // CH0:Indicates a symbol lock and valid data on rx_data /rx_data_k 
   input wire                rxp_elec_idle,   // CH0:Inidicates receiver detection of an electrical signal  
   input wire  [2:0]         rxp_status,      // CH0:Indicates receiver Staus/Error codes 

   input wire                phy_status,      // Indicates PHY status info  

   // From User logic


   // From User logic
   input wire                cmpln_tout ,     // Completion time out.
   input wire                cmpltr_abort_np ,// Completor abort.
   input wire                cmpltr_abort_p , // Completor abort.
   input wire                unexp_cmpln ,    // Unexpexted completion.
   input wire                ur_np_ext ,      // UR for NP type.
   input wire                ur_p_ext ,       // UR for P type.
   input wire                np_req_pend ,    // Non posted request is pending.
   input wire                pme_status ,     // PME status to reg 044h.


   // User Loop back data
   input wire  [15:0]        tx_lbk_data,     // TX User Master Loopback data
   input wire  [1:0]         tx_lbk_kcntl,    // TX User Master Loopback control


   output wire               tx_lbk_rdy,      // TX loop back is ready to accept data
   output wire [15:0]        rx_lbk_data,     // RX User Master Loopback data
   output wire [1:0]         rx_lbk_kcntl,    // RX User Master Loopback control
   // Power Management/ Vendor specific DLLP
   output wire            tx_dllp_sent,       // Requested PM DLLP is sent
   output wire [2:0]      rxdp_pmd_type,      // PM DLLP type bits.
   output wire [23:0]     rxdp_vsd_data ,     // Vendor specific DLLP data.
   output wire [1:0]      rxdp_dllp_val,      // PM/Vendor specific DLLP valid.

   output wire [7:0]         txp_data,        // CH0:PCI Express data to External Phy
   output wire               txp_data_k,      // CH0:PCI Express control to External Phy
   output wire               txp_elec_idle,   // CH0:Tells PHY to output Electrical Idle 
   output wire               txp_compliance,  // CH0:Sets the PHY running disparity to -ve 
   output wire               rxp_polarity,    // CH0:Tells PHY to do polarity inversion on the received data

   output wire               txp_detect_rx_lb,    // Tells PHY to begin receiver detection or begin Loopback 
   output wire               reset_n,             // Async reset to the PHY
   output wire [1:0]         power_down,          // Tell sthe PHY to power Up or Down
                                                  
   output wire               phy_pol_compliance,  // Polling compliance 
   output wire [3:0]         phy_ltssm_state,     // Indicates the states of the ltssm 

   output wire               tx_rdy_vc0,      // VC0 TX ready indicating signal
   output wire [8:0]         tx_ca_ph_vc0,    // VC0 Available credit for Posted Type Headers
   output wire [12:0]        tx_ca_pd_vc0,    // VC0 For Posted - Data
   output wire [8:0]         tx_ca_nph_vc0,   // VC0 For Non-posted - Header
   output wire [12:0]        tx_ca_npd_vc0,   // VC0 For Non-posted - Data
   output wire [8:0]         tx_ca_cplh_vc0,  // VC0 For Completion - Header
   output wire [12:0]        tx_ca_cpld_vc0,  // VC0 For Completion - Data
   output wire               tx_ca_p_recheck_vc0, //
   output wire               tx_ca_cpl_recheck_vc0, //
   output wire [15:0]        rx_data_vc0,     // VC0 Receive data
   output wire               rx_st_vc0,       // VC0 Receive data start
   output wire               rx_end_vc0,      // VC0 Receive data end
   output wire               rx_us_req_vc0 ,  // VC0 unsupported req received  
   output wire               rx_malf_tlp_vc0 ,// VC0 malformed TLP in received data 

   output wire [6:0]         rx_bar_hit ,     // Bar hit
   output wire [2:0]         mm_enable ,     // Multiple message enable bits of Register
   output wire               msi_enable ,    // MSI enable bit of Register

   // From Config Registers
   output wire [7:0]         bus_num ,        // Bus number
   output wire [4:0]         dev_num ,        // Device number
   output wire [2:0]         func_num ,       // Function number
   output wire [1:0]         pm_power_state , // Power state bits of Register at 044h
   output wire               pme_en ,         // PME_En at 044h
   output wire [5:0]         cmd_reg_out ,    // Bits 10,8,6,2,1,0 From register 004h
   output wire [14:0]        dev_cntl_out ,   // Divice control register at 060h 
   output wire [7:0]         lnk_cntl_out ,   // Link control register at 068h 


   // To ASPM implementation outside the IP
   output wire               tx_rbuf_empty,   // Transmit retry buffer is empty
   output wire               tx_dllp_pend,    // DLPP is pending to be transmitted
   output wire               rx_tlp_rcvd,     // Received a TLP

   // Datal Link Control SM Status
   output wire               dl_inactive,     // Data Link Control SM is in INACTIVE state
   output wire               dl_init,         // INIT state
   output wire               dl_active,       // ACTIVE state
   output wire               dl_up            // Data Link Layer is UP 

  );

endmodule
