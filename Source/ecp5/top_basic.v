// $Id: top_basic.v,v 1.2 2008/07/02 19:10:29 jfreed Exp $


module top_basic  (/*AUTOARG*/
	refclkp, refclkn,
	rstn,
	hdinp, hdinn,
	hdoutp, hdoutn,
	SysClk,//				: out std_logic;//125MHz
	Cycle,//				: out std_logic;
	STB,//					: out std_logic;
	WRIn,//					: out std_logic;
	SelectIn,//				: out std_logic_vector(1 downto 0);
	// CTI,//					: out std_logic_vector(2 downto 0);
	Addrss,//				: out std_logic_vector(31 downto 0);
	DataIn,//				: out std_logic_vector(15 downto 0);
	DataOut,//				: in std_logic_vector(15 downto 0);
	ACK,//					: in std_logic;
	// ERR,//				: in std_logic;
	// RTY,//				: in std_logic;
	CA_PD,//				: out std_logic_vector(12 downto 0);
	CA_NPH,//				: out std_logic_vector(8 downto 0);
	DL_UP,//				: out std_logic;
	MSIIn//					: in std_logic_vector(7 downto 0);
   // Outputs
   // hdoutp, hdoutn, pll_lk, poll, l0, dl_up, usr0, usr1, usr2, usr3,
   // na_pll_lk, na_poll, na_l0, na_dl_up, na_usr0, na_usr1, na_usr2,
   // na_usr3, led_out, dp, TP,
   // Inputs
   // rstn, FLIP_LANES, LED_INV, refclkp, refclkn, hdinp, hdinn,
   // dip_switch
   );

   // PARAMETERS
   parameter c_DATA_WIDTH = 64;

   // INPUTS AND OUTPUTS
   input         rstn;
   
   // These two inputs are set in the .lpf file
   // input 	 FLIP_LANES; // Flip PCIe lanes
   // input 	 LED_INV;  // LED polarity inverted
   
   input 	 refclkp, refclkn;
   input 	 hdinp, hdinn;
   output 	 hdoutp, hdoutn;
   
	output SysClk;//					: out std_logic;//125MHz
	output Cycle;//					: out std_logic;
	output STB;//					: out std_logic;
	output WRIn;//					: out std_logic;
	output [3:0] SelectIn;//				: out std_logic_vector(1 downto 0);
	// output [2:0] CTI;//					: out std_logic_vector(2 downto 0);
	output [31:0] Addrss;//					: out std_logic_vector(31 downto 0);
	output [31:0] DataIn;//					: out std_logic_vector(15 downto 0);
	input [31:0] DataOut;//				: in std_logic_vector(15 downto 0);
	input ACK;//					: in std_logic;
	// input ERR;//					: in std_logic;
	// input RTY;//					: in std_logic;
	output [12:0] CA_PD;//					: out std_logic_vector(12 downto 0);
	output [8:0] CA_NPH;//					: out std_logic_vector(8 downto 0);
	output DL_UP;//					: out std_logic;
	input [7:0] MSIIn;//					: in std_logic_vector(7 downto 0);
	// wire FLIP_LANES; // Flip PCIe lanes
	// assign FLIP_LANES = 1'd0;
//assign of signals for the top level
	assign SysClk = clk_125;
	assign Cycle = gpio_cyc;
	assign STB = gpio_stb;
	assign WRIn = gpio_we;
	assign SelectIn = gpio_sel;
	// assign CTI = gpio_cti;
	assign Addrss = gpio_adr;
	assign DataIn = gpio_dat_i;
	assign gpio_dat_o = DataOut;
	assign gpio_ack = ACK;
	// assign ERR
	// assign RTY
	assign CA_PD = tx_ca_pd;
	assign CA_NPH = tx_ca_nph;
	assign DL_UP = dl_up_int;
	assign MSI = MSIIn;
	
	wire [7:0] MSI;
   // output 	 pll_lk, poll, l0, dl_up, usr0, usr1, usr2, usr3,
		 // na_pll_lk, na_poll, na_l0, na_dl_up, na_usr0, na_usr1, na_usr2, na_usr3;   
   // input [7:0] 	 dip_switch;
   // output [15:0] led_out;
   // output 	 dp;
   // output [15:0] TP;
   // output clk_rstn;
   // output [33:0] la;
   // assign clk_rstn = 1'b1;
   
   // REGs
   
   // WIREs
   // wire 	 lock;
   
   // wire [15:0] 	 led_out_int;
   
   wire [3:0] 	 phy_ltssm_state; 
   wire 	 dl_up_int;
   
   wire [63:0] 	 rx_data, tx_data,  tx_dout_wbm, tx_dout_ur;
   wire [6:0] 	 rx_bar_hit;
   
   wire [7:0] 	 pd_num, pd_num_ur;
   
   wire [63:0] 	 pcie_dat_i, pcie_dat_o;
   wire [31:0] 	 pcie_adr;
   wire [7:0] 	 pcie_sel;
   wire 	 pcie_cyc;
   wire 	 pcie_we;
   wire 	 pcie_stb;
   wire 	 pcie_ack;
   
   wire [31:0] 	 gpio_dat_i, gpio_dat_o;
   wire [63:0] 	 gpio_dat64_i;
   wire [31:0] 	 gpio_adr;
   wire [3:0] 	 gpio_sel;
   wire [7:0] 	 gpio_sel64;
   wire 	 gpio_cyc;
   wire 	 gpio_we;
   wire 	 gpio_stb;
   wire 	 gpio_ack;
   
   wire [63:0] 	 ebr_dat_i, ebr_dat_o;
   wire [31:0] 	 ebr_adr;
   wire [7:0] 	 ebr_sel;
   wire [2:0] 	 ebr_cti;
   wire 	 ebr_cyc;
   wire 	 ebr_we;
   wire 	 ebr_stb;
   wire 	 ebr_ack;
   
   wire [7:0] 	 bus_num ; 
   wire [4:0] 	 dev_num ; 
   wire [2:0] 	 func_num ;
   
   wire [8:0] 	 tx_ca_ph ;
   wire [12:0] 	 tx_ca_pd  ;
   wire [8:0] 	 tx_ca_nph ;
   wire [12:0] 	 tx_ca_npd ;
   
   wire 	 tx_val;
   
   wire 	 clk_125;
   wire 	 refclk;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			cb_rst;			// From gpio of wbs_gpio.v
   wire [4:0]		dma_req_gpio;		// From gpio of wbs_gpio.v
   wire			ebr_err;		// From ebr of wbs_32kebr.v
   wire [31:0]		ebr_filter;		// From gpio of wbs_gpio.v
   wire			ebr_rty;		// From ebr of wbs_32kebr.v
   wire			gpio_err;		// From gpio of wbs_gpio.v
   wire			gpio_rty;		// From gpio of wbs_gpio.v
   wire			int;			// From gpio of wbs_gpio.v
   wire			npd_cr;			// From crarb of ip_crpr_arb.v
   wire			npd_cr_ur;		// From cr of ip_rx_crpr.v
   wire			npd_cr_wb;		// From wb_tlc of wb_tlc.v
   wire			nph_cr;			// From crarb of ip_crpr_arb.v
   wire			nph_cr_ur;		// From cr of ip_rx_crpr.v
   wire			nph_cr_wb;		// From wb_tlc of wb_tlc.v
   wire			pd_cr;			// From crarb of ip_crpr_arb.v
   wire			pd_cr_ur;		// From cr of ip_rx_crpr.v
   wire			pd_cr_wb;		// From wb_tlc of wb_tlc.v
   wire			ph_cr;			// From crarb of ip_crpr_arb.v
   wire			ph_cr_ur;		// From cr of ip_rx_crpr.v
   wire			ph_cr_wb;		// From wb_tlc of wb_tlc.v
   wire			tx_dwen;		// From tx_arb of ip_tx_arbiter.v
   wire			tx_dwen_ur;		// From ur of UR_gen.v
   wire			tx_dwen_wbm;		// From wb_tlc of wb_tlc.v
   wire			tx_end;			// From tx_arb of ip_tx_arbiter.v
   wire			tx_eop_ur;		// From ur of UR_gen.v
   wire			tx_eop_wbm;		// From wb_tlc of wb_tlc.v
   wire			tx_rdy_ur;		// From tx_arb of ip_tx_arbiter.v
   wire			tx_rdy_wbm;		// From tx_arb of ip_tx_arbiter.v
   wire			tx_req;			// From tx_arb of ip_tx_arbiter.v
   wire			tx_req_ur;		// From ur of UR_gen.v
   wire			tx_req_wbm;		// From wb_tlc of wb_tlc.v
   wire			tx_sop_ur;		// From ur of UR_gen.v
   wire			tx_sop_wbm;		// From wb_tlc of wb_tlc.v
   wire			tx_st;			// From tx_arb of ip_tx_arbiter.v
   // End of automatics

   //=============================================================================
   // LED Assignments
   //=============================================================================
   
/* -----\/----- EXCLUDED -----\/-----
   led_status led(.clk(clk_125), .rstn(rstn), .invert(LED_INV),
		  .lock(1'b1), .ltssm_state(phy_ltssm_state), .dl_up_in(dl_up_int), .bar1_hit(rx_bar_hit[1] | rx_bar_hit[0]),
		  .pll_lk(pll_lk), .poll(poll), .l0(l0), .dl_up_out(dl_up), 
		  .usr0(usr0), .usr1(usr1), .usr2(usr2), .usr3(usr3),
		  .na_pll_lk(na_pll_lk), .na_poll(na_poll), .na_l0(na_l0), .na_dl_up_out(na_dl_up), 
		  .na_usr0(na_usr0), .na_usr1(na_usr1), .na_usr2(na_usr2), .na_usr3(na_usr3), .dpn(dp)
		  );
 -----/\----- EXCLUDED -----/\----- */
   
   /*led_status AUTO_TEMPLATE (
    .dl_up_out           (dl_up),
    .na_dl_up_out        (na_dl_up),
    .dpn                 (dp),
    
    .clk                 (clk_125),
    .invert              (LED_INV),
    .lock                (1'b1),
    .ltssm_state         (phy_ltssm_state[3:0]),
    .dl_up_in            (dl_up_int),
    .bar1_hit            (rx_bar_hit[1] | rx_bar_hit[0]),
    ); */
   // led_status led (/*AUTOINST*/
		   // Outputs
		   // .pll_lk		(pll_lk),
		   // .poll		(poll),
		   // .l0			(l0),
		   // .dl_up_out		(dl_up),		 // Templated
		   // .usr0		(usr0),
		   // .usr1		(usr1),
		   // .usr2		(usr2),
		   // .usr3		(usr3),
		   // .na_pll_lk		(na_pll_lk),
		   // .na_poll		(na_poll),
		   // .na_l0		(na_l0),
		   // .na_dl_up_out	(na_dl_up),		 // Templated
		   // .na_usr0		(na_usr0),
		   // .na_usr1		(na_usr1),
		   // .na_usr2		(na_usr2),
		   // .na_usr3		(na_usr3),
		   // .dpn			(dp),			 // Templated
		   // Inputs
		   // .clk			(clk_125),		 // Templated
		   // .rstn		(rstn),
		   // .invert		(LED_INV),		 // Templated
		   // .lock		(1'b1),			 // Templated
		   // .ltssm_state		(phy_ltssm_state[3:0]),	 // Templated
		   // .dl_up_in		(dl_up_int),		 // Templated
		   // .bar1_hit		(rx_bar_hit[1] | rx_bar_hit[0])); // Templated
   
   pcie2_core pcie (
		    // PCIe EXTREF interface
		    .pcie2_extref_refclkp                ( refclkp ),
		    .pcie2_extref_refclkn                ( refclkn ),
		    .pcie2_extref_refclko                ( refclk ),
		    // PCIe x1 core interface
		    .pcie2_x1_pll_refclki                ( refclk ),    
		    .pcie2_x1_rxrefclk                   ( refclk ),
		    .pcie2_x1_sys_clk_125                ( clk_125 ),
		    .pcie2_x1_rst_n                      ( rstn ),    
		    .pcie2_x1_flip_lanes                 ( 1'b0 ),
		    .pcie2_x1_inta_n                     ( 1'b1 ),
		    .pcie2_x1_msi                        ( MSI ),
		    
		    // This PCIe interface uses dynamic IDs. 
		    .pcie2_x1_vendor_id                  ( 16'h1204 ),
		    .pcie2_x1_device_id                  ( 16'hec30 ),       
		    .pcie2_x1_rev_id                     ( 8'h00 ),
		    .pcie2_x1_class_code                 ( 24'h300000 ),
		    .pcie2_x1_subsys_ven_id              ( 16'h1204 ),
		    .pcie2_x1_subsys_id                  ( 16'h3010 ),
		    .pcie2_x1_load_id                    ( 1'b1 ),
		    
		    .pcie2_x1_hdinp0                     ( hdinp ), 
		    .pcie2_x1_hdinn0                     ( hdinn ), 
		    .pcie2_x1_hdoutp0                    ( hdoutp ), 
		    .pcie2_x1_hdoutn0                    ( hdoutn ), 
		    
		    // Inputs
		    .pcie2_x1_force_lsm_active           ( 1'b0 ), 
		    .pcie2_x1_force_rec_ei               ( 1'b0 ),     
		    .pcie2_x1_force_phy_status           ( 1'b0 ), 
		    .pcie2_x1_force_disable_scr          ( 1'b0 ),
                    
		    .pcie2_x1_hl_snd_beacon              ( 1'b0 ),
		    .pcie2_x1_hl_disable_scr             ( 1'b0 ),
		    .pcie2_x1_hl_gto_dis                 ( 1'b0 ),
		    .pcie2_x1_hl_gto_det                 ( 1'b0 ),
		    .pcie2_x1_hl_gto_hrst                ( 1'b0 ),
		    .pcie2_x1_hl_gto_l0stx               ( 1'b0 ),
		    .pcie2_x1_hl_gto_l1                  ( 1'b0 ),
		    .pcie2_x1_hl_gto_l2                  ( 1'b0 ),
		    .pcie2_x1_hl_gto_l0stxfts            ( 1'b0 ),
		    .pcie2_x1_hl_gto_lbk                 ( 2'd0 ),
		    .pcie2_x1_hl_gto_rcvry               ( 1'b0 ),
		    .pcie2_x1_hl_gto_cfg                 ( 1'b0 ),
		    .pcie2_x1_no_pcie_train              ( 1'b0 ),    
		    
		    // Power Management Interface
		    .pcie2_x1_tx_dllp_val                ( 2'd0 ),
		    .pcie2_x1_tx_pmtype                  ( 3'd0 ),
		    .pcie2_x1_tx_vsd_data                ( 24'd0 ),
		    
		    .pcie2_x1_phy_cfgln                  ( ),           
		    .pcie2_x1_phy_cfgln_sum              ( ),   
		    .pcie2_x1_phy_pol_compliance         ( ),
		    .pcie2_x1_phy_ltssm_state            ( phy_ltssm_state ),
		    
		    // For VC Inputs
		    .pcie2_x1_tx_req_vc0                 ( tx_req ),    
		    .pcie2_x1_tx_data_vc0                ( tx_data ),    
		    .pcie2_x1_tx_st_vc0                  ( tx_st ), 
		    .pcie2_x1_tx_end_vc0                 ( tx_end ), 
		    .pcie2_x1_tx_nlfy_vc0                ( 1'b0 ), 
		    .pcie2_x1_tx_dwen_vc0                ( tx_dwen ), 
		    .pcie2_x1_ph_buf_status_vc0          ( 1'b0 ),
		    .pcie2_x1_pd_buf_status_vc0          ( 1'b0 ),
		    .pcie2_x1_nph_buf_status_vc0         ( 1'b0 ),
		    .pcie2_x1_npd_buf_status_vc0         ( 1'b0 ),
		    .pcie2_x1_ph_processed_vc0           ( ph_cr ),
		    .pcie2_x1_pd_processed_vc0           ( pd_cr ),
		    .pcie2_x1_nph_processed_vc0          ( nph_cr ),
		    .pcie2_x1_npd_processed_vc0          ( npd_cr ),
		    .pcie2_x1_pd_num_vc0                 ( pd_num ),
		    .pcie2_x1_npd_num_vc0                ( 8'd1 ),   
		    
		    // From User logic
		    .pcie2_x1_cmpln_tout                 ( 1'b0 ),
		    .pcie2_x1_cmpltr_abort_np            ( 1'b0 ),
		    .pcie2_x1_cmpltr_abort_p             ( 1'b0 ),
		    .pcie2_x1_unexp_cmpln                ( 1'b0 ),
		    .pcie2_x1_ur_np_ext                  ( 1'b0 ),
		    .pcie2_x1_ur_p_ext                   ( 1'b0 ),
		    .pcie2_x1_np_req_pend                ( 1'b0 ),
		    .pcie2_x1_pme_status                 ( 1'b0 ),
		    
		    .pcie2_x1_flr_rdy_in                 (1'b0),
		    
		    .pcie2_x1_tx_lbk_data                (64'b0),
		    .pcie2_x1_tx_lbk_kcntl               (8'b0),
		    .pcie2_x1_tx_lbk_rdy                 ( ),
		    .pcie2_x1_rx_lbk_data                ( ),
		    .pcie2_x1_rx_lbk_kcntl               ( ),
		    
		    .pcie2_x1_tx_dllp_sent               ( ),
		    .pcie2_x1_rxdp_pmd_type              ( ),
		    .pcie2_x1_rxdp_vsd_data              ( ),
		    .pcie2_x1_rxdp_dllp_val              ( ),
		    .pcie2_x1_tx_val                     ( tx_val ),   
		    .pcie2_x1_tx_rdy_vc0                 ( tx_rdy),  
		    .pcie2_x1_tx_ca_ph_vc0               ( tx_ca_ph),
		    .pcie2_x1_tx_ca_pd_vc0               ( tx_ca_pd),
		    .pcie2_x1_tx_ca_nph_vc0              ( tx_ca_nph),
		    .pcie2_x1_tx_ca_npd_vc0              ( ), 
		    .pcie2_x1_tx_ca_cplh_vc0             ( ),
		    .pcie2_x1_tx_ca_cpld_vc0             ( ),
		    .pcie2_x1_tx_ca_p_recheck_vc0        ( ),
		    .pcie2_x1_tx_ca_cpl_recheck_vc0      ( ),
		    .pcie2_x1_rx_data_vc0                ( rx_data),    
		    .pcie2_x1_rx_st_vc0                  ( rx_st),     
		    .pcie2_x1_rx_end_vc0                 ( rx_end),   
		    .pcie2_x1_rx_dwen_vc0                ( rx_dwen),   
		    .pcie2_x1_rx_us_req_vc0              ( rx_us_req ), 
		    .pcie2_x1_rx_malf_tlp_vc0            ( rx_malf_tlp ), 
		    .pcie2_x1_rx_bar_hit                 ( rx_bar_hit ), 
		    .pcie2_x1_mm_enable                  ( ),
		    .pcie2_x1_msi_enable                 ( ),
		    
		    // From Config Registers
		    .pcie2_x1_bus_num                    ( bus_num  ),           
		    .pcie2_x1_dev_num                    ( dev_num  ),           
		    .pcie2_x1_func_num                   ( func_num  ),  
		    .pcie2_x1_pm_power_state             ( ) , 
		    .pcie2_x1_pme_en                     ( ) , 
		    .pcie2_x1_cmd_reg_out                ( ),
		    .pcie2_x1_dev_cntl_out               ( ),  
		    .pcie2_x1_lnk_cntl_out               ( ),
		    
		    .pcie2_x1_dev_cntl_2_out             ( ),
		    .pcie2_x1_initiate_flr               ( ), 
		    
		    // .pcie2_x1_tx_pwrup_c                 ( ),
		    
		    // Debug ports
		    // .pcie2_x1_ffs_plol                   ( ),
		    // .pcie2_x1_ffs_rlol_ch0               ( ),
		    // .pcie2_x1_rsl_rx_ready               ( ),
		    // .pcie2_x1_ctc_data_valid_in          ( ),
		    // .pcie2_x1_ctc_data_valid_out         ( ),
		    
		    // Datal Link Control SM Status
		    .pcie2_x1_dl_inactive                (  ),
		    .pcie2_x1_dl_init                    (  ),
		    .pcie2_x1_dl_active                  (  ),
		    .pcie2_x1_dl_up                      ( dl_up_int )
		    //   .pcie2_x1_plol                       ( plol_i ),
		    //   .pcie2_x1_rlol                       ( rlol_i ),
		    );


   reg clk125_half;
   reg refclk_half;
   /*always @(posedge clk_125 or negedge rstn)
    if (!rstn) begin
    clk125_half <= 0;
   end
    else begin
    clk125_half <= ~clk125_half;
   end
    */
   always @(posedge clk_125) clk125_half <= ~clk125_half;
   
   always @(posedge refclk)  refclk_half <= ~refclk_half;
   
   
/* -----\/----- EXCLUDED -----\/-----
   ip_rx_crpr cr (.clk(clk_125), .rstn(rstn), .rx_bar_hit(rx_bar_hit),
		  .rx_st(rx_st), .rx_end(rx_end), .rx_din(rx_data), .rx_dwen(rx_dwen),
		  .pd_cr(pd_cr_ur), .pd_num(pd_num_ur), .ph_cr(ph_cr_ur), .npd_cr(npd_cr_ur), .nph_cr(nph_cr_ur)               
		  );
 -----/\----- EXCLUDED -----/\----- */
   
   /*ip_rx_crpr AUTO_TEMPLATE (
    .pd_cr               (pd_cr_ur),
    .pd_num              (pd_num_ur[7:0]),
    .ph_cr               (ph_cr_ur),
    .npd_cr              (npd_cr_ur),
    .nph_cr              (nph_cr_ur),
    
    .clk                 (clk_125),
    .rx_din              (rx_data[c_DATA_WIDTH-1:0]),
    ); */
   ip_rx_crpr #(.c_DATA_WIDTH (c_DATA_WIDTH)) cr (/*AUTOINST*/
						  // Outputs
						  .pd_cr		(pd_cr_ur),	 // Templated
						  .pd_num		(pd_num_ur[7:0]), // Templated
						  .ph_cr		(ph_cr_ur),	 // Templated
						  .npd_cr		(npd_cr_ur),	 // Templated
						  .nph_cr		(nph_cr_ur),	 // Templated
						  // Inputs
						  .clk			(clk_125),	 // Templated
						  .rstn			(rstn),
						  .rx_st		(rx_st),
						  .rx_end		(rx_end),
						  .rx_dwen		(rx_dwen),
						  .rx_din		(rx_data[c_DATA_WIDTH-1:0]), // Templated
						  .rx_bar_hit		(rx_bar_hit[6:0]));
   
   
/* -----\/----- EXCLUDED -----\/-----
   ip_crpr_arb crarb(.clk(clk_125), .rstn(rstn), 
		     .pd_cr_0(pd_cr_ur), .pd_num_0(pd_num_ur), .ph_cr_0(ph_cr_ur), .npd_cr_0(npd_cr_ur), .nph_cr_0(nph_cr_ur),
		     .pd_cr_1(pd_cr_wb), .pd_num_1(8'd1), .ph_cr_1(ph_cr_wb), .npd_cr_1(1'b0), .nph_cr_1(nph_cr_wb),               
		     .pd_cr(pd_cr), .pd_num(pd_num), .ph_cr(ph_cr), .npd_cr(npd_cr), .nph_cr(nph_cr)               
		     );
 -----/\----- EXCLUDED -----/\----- */
   
   /*ip_crpr_arb AUTO_TEMPLATE (
    .clk                 (clk_125),
    .pd_cr_0             (pd_cr_ur),
    .pd_num_0            (pd_num_ur[7:0]),
    .ph_cr_0             (ph_cr_ur),
    .npd_cr_0            (npd_cr_ur),
    .nph_cr_0            (nph_cr_ur),
    .pd_cr_1             (pd_cr_wb),
    .pd_num_1            (8'd1),
    .ph_cr_1             (ph_cr_wb),
    .npd_cr_1            (1'b0),
    .nph_cr_1            (nph_cr_wb),
    ); */
   ip_crpr_arb crarb (/*AUTOINST*/
		      // Outputs
		      .pd_cr		(pd_cr),
		      .pd_num		(pd_num[7:0]),
		      .ph_cr		(ph_cr),
		      .npd_cr		(npd_cr),
		      .nph_cr		(nph_cr),
		      // Inputs
		      .clk		(clk_125),		 // Templated
		      .rstn		(rstn),
		      .pd_cr_0		(pd_cr_ur),		 // Templated
		      .pd_num_0		(pd_num_ur[7:0]),	 // Templated
		      .ph_cr_0		(ph_cr_ur),		 // Templated
		      .npd_cr_0		(npd_cr_ur),		 // Templated
		      .nph_cr_0		(nph_cr_ur),		 // Templated
		      .pd_cr_1		(pd_cr_wb),		 // Templated
		      .pd_num_1		(8'd1),			 // Templated
		      .ph_cr_1		(ph_cr_wb),		 // Templated
		      .npd_cr_1		(1'b0),			 // Templated
		      .nph_cr_1		(nph_cr_wb));		 // Templated
   
   
/* -----\/----- EXCLUDED -----\/-----
   UR_gen ur (.clk(clk_125), .rstn(rstn),  
              .rx_din(rx_data), .rx_sop(rx_st), .rx_eop(rx_end), .rx_dwen(rx_dwen), .rx_us(rx_us_req), .rx_bar_hit(rx_bar_hit),
              .tx_rdy(tx_rdy_ur), .tx_val(tx_val),
              .tx_req(tx_req_ur), .tx_dout(tx_dout_ur), .tx_sop(tx_sop_ur), .tx_eop(tx_eop_ur), .tx_dwen(tx_dwen_ur), 
              .comp_id({bus_num, dev_num, func_num})
	      );
 -----/\----- EXCLUDED -----/\----- */
   
   /*UR_gen AUTO_TEMPLATE (
    .tx_req              (tx_req_ur),
    .tx_dout             (tx_dout_ur[c_DATA_WIDTH-1:0]),
    .tx_sop              (tx_sop_ur),
    .tx_eop              (tx_eop_ur),
    .tx_dwen		 (tx_dwen_ur),
    
    .clk                 (clk_125),
    .rx_din              (rx_data[c_DATA_WIDTH-1:0]),
    .rx_sop              (rx_st),
    .rx_eop              (rx_end),
    .rx_dwen		 (rx_dwen),
    .rx_us               (rx_us_req),
    .tx_rdy              (tx_rdy_ur),
    .comp_id             ({bus_num, dev_num, func_num}),
    ); */
   UR_gen #(.c_DATA_WIDTH (c_DATA_WIDTH)) ur (/*AUTOINST*/
					      // Outputs
					      .tx_req		(tx_req_ur),	 // Templated
					      .tx_dout		(tx_dout_ur[c_DATA_WIDTH-1:0]), // Templated
					      .tx_sop		(tx_sop_ur),	 // Templated
					      .tx_eop		(tx_eop_ur),	 // Templated
					      .tx_dwen		(tx_dwen_ur),	 // Templated
					      // Inputs
					      .rstn		(rstn),
					      .clk		(clk_125),	 // Templated
					      .rx_din		(rx_data[c_DATA_WIDTH-1:0]), // Templated
					      .rx_sop		(rx_st),	 // Templated
					      .rx_eop		(rx_end),	 // Templated
					      .rx_dwen		(rx_dwen),	 // Templated
					      .rx_us		(rx_us_req),	 // Templated
					      .rx_bar_hit	(rx_bar_hit[6:0]),
					      .tx_rdy		(tx_rdy_ur),	 // Templated
					      .tx_val		(tx_val),
					      .comp_id		({bus_num, dev_num, func_num})); // Templated
   
   
/* -----\/----- EXCLUDED -----\/-----
   ip_tx_arbiter tx_arb(.clk(clk_125), .rstn(rstn), .tx_val(tx_val),
			.tx_req_0(tx_req_wbm), .tx_din_0(tx_dout_wbm), .tx_sop_0(tx_sop_wbm), .tx_eop_0(tx_eop_wbm), .tx_dwen_0(tx_dwen_wbm),
			.tx_req_1(1'b0), .tx_din_1(64'd0), .tx_sop_1(1'b0), .tx_eop_1(1'b0), .tx_dwen_1(1'b0),
			.tx_req_2(1'b0), .tx_din_2(64'd0), .tx_sop_2(1'b0), .tx_eop_2(1'b0), .tx_dwen_2(1'b0),
			.tx_req_3(tx_req_ur), .tx_din_3(tx_dout_ur), .tx_sop_3(tx_sop_ur), .tx_eop_3(tx_eop_ur), .tx_dwen_3(tx_dwen_ur),
			.tx_rdy_0(tx_rdy_wbm), .tx_rdy_1(tx_rdy_sfif), .tx_rdy_2( ), .tx_rdy_3(tx_rdy_ur),
			.tx_req(tx_req), .tx_dout(tx_data), .tx_sop(tx_st), .tx_eop(tx_end), .tx_dwen(tx_dwen),
			.tx_rdy(tx_rdy)
			);
 -----/\----- EXCLUDED -----/\----- */
   
   /*ip_tx_arbiter AUTO_TEMPLATE (
    .tx_rdy_0            (tx_rdy_wbm),
    .tx_rdy_1            (),
    .tx_rdy_2            (),
    .tx_rdy_3            (tx_rdy_ur),
    .tx_dout             (tx_data[c_DATA_WIDTH-1:0]),
    .tx_sop              (tx_st),
    .tx_eop              (tx_end),
    .tx_dwen             (tx_dwen),
    
    .clk                 (clk_125),
    .tx_req_0            (tx_req_wbm),
    .tx_din_0            (tx_dout_wbm[c_DATA_WIDTH-1:0]),
    .tx_sop_0            (tx_sop_wbm),
    .tx_eop_0            (tx_eop_wbm),
    .tx_dwen_0           (tx_dwen_wbm),
    .tx_req_1            (1'b0),
    .tx_din_1            ({c_DATA_WIDTH{1'b0}}),
    .tx_sop_1            (1'b0),
    .tx_eop_1            (1'b0),
    .tx_dwen_1           (1'b0),
    .tx_req_2            (1'b0),
    .tx_din_2            ({c_DATA_WIDTH{1'b0}}),
    .tx_sop_2            (1'b0),
    .tx_eop_2            (1'b0),
    .tx_dwen_2           (1'b0),
    .tx_req_3            (tx_req_ur),
    .tx_din_3            (tx_dout_ur[c_DATA_WIDTH-1:0]),
    .tx_sop_3            (tx_sop_ur),
    .tx_eop_3            (tx_eop_ur),
    .tx_dwen_3           (tx_dwen_ur),
    ); */
   ip_tx_arbiter #(.c_DATA_WIDTH (c_DATA_WIDTH)) tx_arb (/*AUTOINST*/
							 // Outputs
							 .tx_rdy_0		(tx_rdy_wbm),	 // Templated
							 .tx_rdy_1		(),		 // Templated
							 .tx_rdy_2		(),		 // Templated
							 .tx_rdy_3		(tx_rdy_ur),	 // Templated
							 .tx_req		(tx_req),
							 .tx_dout		(tx_data[c_DATA_WIDTH-1:0]), // Templated
							 .tx_sop		(tx_st),	 // Templated
							 .tx_eop		(tx_end),	 // Templated
							 .tx_dwen		(tx_dwen),	 // Templated
							 // Inputs
							 .clk			(clk_125),	 // Templated
							 .rstn			(rstn),
							 .tx_val		(tx_val),
							 .tx_req_0		(tx_req_wbm),	 // Templated
							 .tx_din_0		(tx_dout_wbm[c_DATA_WIDTH-1:0]), // Templated
							 .tx_sop_0		(tx_sop_wbm),	 // Templated
							 .tx_eop_0		(tx_eop_wbm),	 // Templated
							 .tx_dwen_0		(tx_dwen_wbm),	 // Templated
							 .tx_req_1		(1'b0),		 // Templated
							 .tx_din_1		({c_DATA_WIDTH{1'b0}}), // Templated
							 .tx_sop_1		(1'b0),		 // Templated
							 .tx_eop_1		(1'b0),		 // Templated
							 .tx_dwen_1		(1'b0),		 // Templated
							 .tx_req_2		(1'b0),		 // Templated
							 .tx_din_2		({c_DATA_WIDTH{1'b0}}), // Templated
							 .tx_sop_2		(1'b0),		 // Templated
							 .tx_eop_2		(1'b0),		 // Templated
							 .tx_dwen_2		(1'b0),		 // Templated
							 .tx_req_3		(tx_req_ur),	 // Templated
							 .tx_din_3		(tx_dout_ur[c_DATA_WIDTH-1:0]), // Templated
							 .tx_sop_3		(tx_sop_ur),	 // Templated
							 .tx_eop_3		(tx_eop_ur),	 // Templated
							 .tx_dwen_3		(tx_dwen_ur),	 // Templated
							 .tx_rdy		(tx_rdy));
   
   
/* -----\/----- EXCLUDED -----\/-----
   wb_tlc wb_tlc(.clk_125(clk_125), .wb_clk(clk_125), .rstn(rstn),
		 .rx_data(rx_data), .rx_st(rx_st), .rx_end(rx_end), .rx_dwen(rx_dwen), .rx_bar_hit(rx_bar_hit),
		 .wb_adr_o(pcie_adr), .wb_dat_o(pcie_dat_o), .wb_we_o(pcie_we), .wb_sel_o(pcie_sel), .wb_stb_o(pcie_stb), .wb_cyc_o(pcie_cyc), .wb_lock_o(), 
		 .wb_dat_i(pcie_dat_i), .wb_ack_i(pcie_ack),
		 .pd_cr(pd_cr_wb), .ph_cr(ph_cr_wb), .npd_cr(npd_cr_wb), .nph_cr(nph_cr_wb),
		 .tx_rdy(tx_rdy_wbm), .tx_val(tx_val), 
		 .tx_req(tx_req_wbm), .tx_data(tx_dout_wbm), .tx_st(tx_sop_wbm), .tx_end(tx_eop_wbm), .tx_dwen(tx_dwen_wbm), 
		 .comp_id({bus_num, dev_num, func_num}),
		 .debug()
		 );
 -----/\----- EXCLUDED -----/\----- */
   
   /*wb_tlc AUTO_TEMPLATE (
    .wb_adr_o            (pcie_adr[31:0]),
    .wb_dat_o            (pcie_dat_o[c_DATA_WIDTH-1:0]),
    .wb_cti_o            (pcie_cti[2:0]),
    .wb_we_o             (pcie_we),
    .wb_sel_o            (pcie_sel[7:0]),
    .wb_stb_o            (pcie_stb),
    .wb_cyc_o            (pcie_cyc),
    .wb_lock_o           (),
    .pd_cr               (pd_cr_wb),
    .ph_cr               (ph_cr_wb),
    .npd_cr              (npd_cr_wb),
    .nph_cr              (nph_cr_wb),
    .pd_num              (pd_num_wb[7:0]),
    .tx_req              (tx_req_wbm),
    .tx_data             (tx_dout_wbm[c_DATA_WIDTH-1:0]),
    .tx_st               (tx_sop_wbm),
    .tx_end              (tx_eop_wbm),
    .tx_dwen             (tx_dwen_wbm),
    .debug               (),
    
    .wb_clk              (clk_125),
    .wb_ack_i            (pcie_ack),
    .wb_dat_i            (pcie_dat_i[c_DATA_WIDTH-1:0]),
    .tx_rdy              (tx_rdy_wbm),
    .tx_ca_cpl_recheck   (1'b0),
    .comp_id             ({bus_num, dev_num, func_num}),
    ); */
   wb_tlc  #(.c_DATA_WIDTH(c_DATA_WIDTH)) wb_tlc (/*AUTOINST*/
						  // Outputs
						  .wb_adr_o		(pcie_adr[31:0]), // Templated
						  .wb_dat_o		(pcie_dat_o[c_DATA_WIDTH-1:0]), // Templated
						  .wb_we_o		(pcie_we),	 // Templated
						  .wb_sel_o		(pcie_sel[7:0]), // Templated
						  .wb_stb_o		(pcie_stb),	 // Templated
						  .wb_cyc_o		(pcie_cyc),	 // Templated
						  .wb_lock_o		(),		 // Templated
						  .pd_cr		(pd_cr_wb),	 // Templated
						  .ph_cr		(ph_cr_wb),	 // Templated
						  .npd_cr		(npd_cr_wb),	 // Templated
						  .nph_cr		(nph_cr_wb),	 // Templated
						  .tx_req		(tx_req_wbm),	 // Templated
						  .tx_data		(tx_dout_wbm[c_DATA_WIDTH-1:0]), // Templated
						  .tx_st		(tx_sop_wbm),	 // Templated
						  .tx_end		(tx_eop_wbm),	 // Templated
						  .tx_dwen		(tx_dwen_wbm),	 // Templated
						  .debug		(),		 // Templated
						  // Inputs
						  .clk_125		(clk_125),
						  .wb_clk		(clk_125),	 // Templated
						  .rstn			(rstn),
						  .rx_data		(rx_data[c_DATA_WIDTH-1:0]),
						  .rx_st		(rx_st),
						  .rx_end		(rx_end),
						  .rx_dwen		(rx_dwen),
						  .rx_bar_hit		(rx_bar_hit[6:0]),
						  .wb_ack_i		(pcie_ack),	 // Templated
						  .wb_dat_i		(pcie_dat_i[c_DATA_WIDTH-1:0]), // Templated
						  .tx_rdy		(tx_rdy_wbm),	 // Templated
						  .tx_val		(tx_val),
						  .comp_id		({bus_num, dev_num, func_num})); // Templated
   
   
   // defparam wb_arb.S0_BASE = 32'h0000;
   // defparam wb_arb.S1_BASE = 32'h4000; // not used
   // defparam wb_arb.S2_BASE = 32'h1000;
   // defparam wb_arb.S3_BASE = 32'h5000; // not used
   wb_arb #(.c_DATA_WIDTH(c_DATA_WIDTH),
	    .S0_BASE     (32'h0000),
            .S1_BASE     (32'h4000),
            .S2_BASE     (32'h1000),
            .S3_BASE     (32'h5000)) 
   wb_arb (
	   .clk(clk_125),
	   .rstn(rstn),
	   
	   // PCIe Master 
	   .m0_dat_i(pcie_dat_o), 
	   .m0_dat_o(pcie_dat_i), 
	   .m0_adr_i(pcie_adr),
	   .m0_sel_i(pcie_sel), 
	   .m0_we_i(pcie_we), 
	   .m0_cyc_i(pcie_cyc),
	   .m0_cti_i(3'b000),
	   .m0_stb_i(pcie_stb), 
	   .m0_ack_o(pcie_ack), 
	   .m0_err_o(), 
	   .m0_rty_o(), 
	   
	   // DMA Master
	   .m1_dat_i(64'd0), 
	   .m1_dat_o(), 
	   .m1_adr_i(32'd0),
	   .m1_sel_i(8'd0), 
	   .m1_we_i( 1'b0), 
	   .m1_cyc_i(1'b0),
	   .m1_cti_i(3'd0),
	   .m1_stb_i(1'b0), 
	   .m1_ack_o(), 
	   .m1_err_o(), 
	   .m1_rty_o(),
	   
	   // GPIO 32-bit
	   .s0_dat_i({gpio_dat_o, gpio_dat_o}), 
	   .s0_dat_o(gpio_dat64_i), 
	   .s0_adr_o(gpio_adr), 
	   .s0_sel_o(gpio_sel64), 
	   .s0_we_o (gpio_we), 
	   .s0_cyc_o(gpio_cyc),
	   .s0_cti_o(),
	   .s0_stb_o(gpio_stb), 
	   .s0_ack_i(gpio_ack), 
	   .s0_err_i(1'b0),
	   .s0_rty_i(1'b0),
	   
	   // DMA Slave
	   .s1_dat_i(64'd0), 
	   .s1_dat_o(), 
	   .s1_adr_o(), 
	   .s1_sel_o(), 
	   .s1_we_o (), 
	   .s1_cyc_o(),
	   .s1_cti_o(),
	   .s1_stb_o(), 
	   .s1_ack_i(1'b0), 
	   .s1_err_i(1'b0),
	   .s1_rty_i(1'b0),
	   
	   // EBR
	   .s2_dat_i(ebr_dat_o), 
	   .s2_dat_o(ebr_dat_i), 
	   .s2_adr_o(ebr_adr), 
	   .s2_sel_o(ebr_sel), 
	   .s2_we_o (ebr_we), 
	   .s2_cyc_o(ebr_cyc),
	   .s2_cti_o(ebr_cti),
	   .s2_stb_o(ebr_stb), 
	   .s2_ack_i(ebr_ack), 
	   .s2_err_i(1'b0),
	   .s2_rty_i(1'b0),
	   
	   // Not used
	   .s3_dat_i(64'd0), 
	   .s3_dat_o(), 
	   .s3_adr_o(), 
	   .s3_sel_o(), 
	   .s3_we_o (), 
	   .s3_cyc_o(),
	   .s3_cti_o(),
	   .s3_stb_o(), 
	   .s3_ack_i(1'b0), 
	   .s3_err_i(1'b0),
	   .s3_rty_i(1'b0)
	   );
   
/* -----\/----- EXCLUDED -----\/-----
   wbs_gpio gpio(.wb_clk_i(clk_125), .wb_rst_i(~rstn),
		 .wb_dat_i(gpio_dat_i), .wb_adr_i(gpio_adr[8:0]), .wb_cyc_i(gpio_cyc), .wb_lock_i(1'b0),
                 .wb_sel_i(gpio_sel), .wb_stb_i(gpio_stb), .wb_we_i(gpio_we),
		 .wb_dat_o(gpio_dat_o), .wb_ack_o(gpio_ack), .wb_err_o(), .wb_rty_o(), 
		 .switch_in(dip_switch), .led_out(led_out_int), 
		 .dma_req(dma_req_gpio), .dma_ack(5'd0), 
		 .ca_pd(tx_ca_pd), .ca_nph(tx_ca_nph), .dl_up(dl_up_int),
		 .int_out()
		 );
 -----/\----- EXCLUDED -----/\----- */
   
   // assign led_out = ~led_out_int;          

   assign gpio_dat_i = gpio_adr[2] ? gpio_dat64_i[63:32] : gpio_dat64_i[31:0];
   assign gpio_sel   = gpio_adr[2] ? gpio_sel64[7:4] : gpio_sel64[3:0];
   
   /*wbs_gpio AUTO_TEMPLATE (
    .wb_dat_o            (gpio_dat_o[31:0]),
    .wb_ack_o            (gpio_ack),
    .wb_err_o            (gpio_err),
    .wb_rty_o            (gpio_rty),
    .dma_req             (dma_req_gpio[4:0]),
    .led_out             (led_out_int[15:0]),
    .int_out             (int),
    
    .wb_clk_i            (clk_125),
    .wb_rst_i            (~rstn),
    .wb_dat_i            (gpio_dat_i[31:0]),
    .wb_adr_i            (gpio_adr[8:0]),
    // .wb_cti_i            (gpio_cti),
    .wb_cyc_i            (gpio_cyc),
    .wb_lock_i           (1'b0),
    .wb_sel_i            (gpio_sel[3:0]),
    .wb_stb_i            (gpio_stb),
    .wb_we_i             (gpio_we),
    .switch_in           (dip_switch[7:0]),
    .dma_ack             ({5{1'b0}}),
    .ca_pd               (tx_ca_pd[12:0]),
    .ca_nph              (tx_ca_nph[8:0]),
    .dl_up               (dl_up_int),
    ); */
   // wbs_gpio gpio (/*AUTOINST*/
		  // Outputs
		  // .wb_dat_o		(gpio_dat_o[31:0]),	 // Templated
		  // .wb_ack_o		(gpio_ack),		 // Templated
		  // .wb_err_o		(gpio_err),		 // Templated
		  // .wb_rty_o		(gpio_rty),		 // Templated
		  // .led_out		(led_out_int[15:0]),	 // Templated
		  // .dma_req		(dma_req_gpio[4:0]),	 // Templated
		  // .int_out		(int),			 // Templated
		  // .ebr_filter		(ebr_filter[31:0]),
		  // .cb_rst		(cb_rst),
		  // Inputs
		  // .wb_clk_i		(clk_125),		 // Templated
		  // .wb_rst_i		(~rstn),		 // Templated
		  // .wb_dat_i		(gpio_dat_i[31:0]),	 // Templated
		  // .wb_adr_i		(gpio_adr[8:0]),	 // Templated
		  // .wb_cyc_i		(gpio_cyc),		 // Templated
		  // .wb_lock_i		(1'b0),			 // Templated
		  // .wb_sel_i		(gpio_sel[3:0]),	 // Templated
		  // .wb_stb_i		(gpio_stb),		 // Templated
		  // .wb_we_i		(gpio_we),		 // Templated
		  // .switch_in		(dip_switch[7:0]),	 // Templated
		  // .dma_ack		({5{1'b0}}),		 // Templated
		  // .ca_pd		(tx_ca_pd[12:0]),	 // Templated
		  // .ca_nph		(tx_ca_nph[8:0]),	 // Templated
		  // .dl_up		(dl_up_int));		 // Templated
   
   
/* -----\/----- EXCLUDED -----\/-----
   wbs_32kebr ebr(.wb_clk_i(clk_125), .wb_rst_i(~rstn),
		  .wb_dat_i(ebr_dat_i), .wb_adr_i(ebr_adr), .wb_cyc_i(ebr_cyc), .wb_sel_i(ebr_sel),
                  .wb_stb_i(ebr_stb), .wb_we_i(ebr_we), .wb_cti_i(ebr_cti),
		  .wb_dat_o(ebr_dat_o), .wb_ack_o(ebr_ack), .wb_err_o(), .wb_rty_o()          
		  );
 -----/\----- EXCLUDED -----/\----- */
   
    /*wbs_32kebr AUTO_TEMPLATE (
    .wb_dat_o            (ebr_dat_o[c_DATA_WIDTH-1:0]),
    .wb_ack_o            (ebr_ack),
    .wb_err_o            (ebr_err),
    .wb_rty_o            (ebr_rty),
    
    .wb_clk_i            (clk_125),
    .wb_rst_i            (~rstn),
    .wb_dat_i            (ebr_dat_i[c_DATA_WIDTH-1:0]),
    .wb_adr_i            (ebr_adr[31:0]),
    .wb_cyc_i            (ebr_cyc),
    .wb_cti_i            (ebr_cti[2:0]),
    .wb_sel_i            (ebr_sel[7:0]),
    .wb_stb_i            (ebr_stb),
    .wb_we_i             (ebr_we),
    ); */
   // wbs_32kebr #(.c_DATA_WIDTH(c_DATA_WIDTH),
		// .init_file("none"))
   // ebr (/*AUTOINST*/
	// Outputs
	// .wb_dat_o			(ebr_dat_o[c_DATA_WIDTH-1:0]), // Templated
	// .wb_ack_o			(ebr_ack),		 // Templated
	// .wb_err_o			(ebr_err),		 // Templated
	// .wb_rty_o			(ebr_rty),		 // Templated
	// Inputs
	// .wb_clk_i			(clk_125),		 // Templated
	// .wb_rst_i			(~rstn),		 // Templated
	// .wb_dat_i			(ebr_dat_i[c_DATA_WIDTH-1:0]), // Templated
	// .wb_adr_i			(ebr_adr[31:0]),	 // Templated
	// .wb_cyc_i			(ebr_cyc),		 // Templated
	// .wb_cti_i			(ebr_cti[2:0]),		 // Templated
	// .wb_sel_i			(ebr_sel[7:0]),		 // Templated
	// .wb_stb_i			(ebr_stb),		 // Templated
	// .wb_we_i			(ebr_we));		 // Templated
   
   // LED Display mapping
   // 2/13/2015 -- D.W. Convert 16-segment to 14-segment
   // assign led_out[0] = ~led_out_int[0]; //~dl_up_int;
   // assign led_out[1] = ~led_out_int[2]; //~l0;
   // assign led_out[2] = ~led_out_int[3];
   // assign led_out[3] = ~led_out_int[4];
   // assign led_out[4] = ~led_out_int[6];
   // assign led_out[5] = ~led_out_int[7];
   // assign led_out[6] = ~led_out_int[8];
   // assign led_out[7] = ~led_out_int[9];
   // assign led_out[13:8] = ~led_out_int[15:10];
   // assign led_out[15:14] = 2'b0;
   
   
   // DEBUG OUPUT OPTIONS
   // assign la = 34'd0;
   // assign TP = 16'd0;
   
   //assign TP[0] = clk125_half;
   //assign TP[1] = refclk_half;
   //assign TP[2] = rstn;
   //assign TP[3] = dl_up_int;
   //assign TP[4] = l0;
   //assign TP[8:5] = phy_ltssm_state;
   //assign TP[0] = refclk;
   
   //assign TP[0] = tp_plol;
   //assign TP[1] = tp_rlol;
   //assign TP[2] = rstn;
   //assign TP[9] = clk125_half;  //refclk;
   //assign TP[8:3] = 6'b0;
   //assign TP[15:10] = 6'b0;

   // assign TP[0] = clk125_half;
   // assign TP[1] = refclk_half;
   // assign TP[2] = rstn;
   // assign TP[3] = dl_up_int;
   // assign TP[4] = l0;
   // assign TP[8:5] = phy_ltssm_state;
   // assign TP[15:9] = 7'b0;
   
// The following is used by emacs verilog mode to find the sub_files.
// Local Variables:
// verilog-library-directories:("." "../" "../ur_gen" "../wb_tlc" "../gpio" "../32kebr")
// verilog-library-extensions:(".v")
// End:

endmodule

