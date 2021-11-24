// $Id: top_basic.v,v 1.2 2008/07/02 19:10:29 jfreed Exp $


module top_basic
	(   
	 refclkp, refclkn,
	 rstn,
	 hdinp, hdinn,                   
	 hdoutp, hdoutn,
	 SysClk,//					: out std_logic;//125MHz
	 Cycle,//					: out std_logic;
	 STB,//					: out std_logic;
	 WRIn,//					: out std_logic;
	 SelectIn,//				: out std_logic_vector(1 downto 0);
	 CTI,//					: out std_logic_vector(2 downto 0);
	 Addrss,//					: out std_logic_vector(31 downto 0);
	 DataIn,//					: out std_logic_vector(15 downto 0);
	 DataOut,//				: in std_logic_vector(15 downto 0);
	 ACK,//					: in std_logic;
	 // ERR,//					: in std_logic;
	 // RTY,//					: in std_logic;
	 CA_PD,//					: out std_logic_vector(12 downto 0);
	 CA_NPH,//					: out std_logic_vector(8 downto 0);
	 DL_UP,//					: out std_logic;
	 MSIIn//					: in std_logic_vector(7 downto 0);
	);

	input rstn;
	input refclkp, refclkn;
	input hdinp, hdinn;
	output hdoutp, hdoutn;
	output SysClk;//					: out std_logic;//125MHz
	output Cycle;//					: out std_logic;
	output STB;//					: out std_logic;
	output WRIn;//					: out std_logic;
	output [1:0] SelectIn;//				: out std_logic_vector(1 downto 0);
	output [2:0] CTI;//					: out std_logic_vector(2 downto 0);
	output [31:0] Addrss;//					: out std_logic_vector(31 downto 0);
	output [15:0] DataIn;//					: out std_logic_vector(15 downto 0);
	input [15:0] DataOut;//				: in std_logic_vector(15 downto 0);
	input ACK;//					: in std_logic;
	// input ERR;//					: in std_logic;
	// input RTY;//					: in std_logic;
	output [12:0] CA_PD;//					: out std_logic_vector(12 downto 0);
	output [8:0] CA_NPH;//					: out std_logic_vector(8 downto 0);
	output DL_UP;//					: out std_logic;
	input [7:0] MSIIn;//					: in std_logic_vector(7 downto 0);

//assign of signals for the top level
	assign SysClk = clk_125;
	assign Cycle = gpio_cyc;
	assign STB = gpio_stb;
	assign WRIn = gpio_we;
	assign SelectIn = gpio_sel;
	assign CTI = gpio_cti;
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

// These two inputs are set in the .lpf file
	wire FLIP_LANES; // Flip PCIe lanes
	assign FLIP_LANES = 1'd0;
	
	wire [7:0] MSI;

	reg  [19:0] rstn_cnt;
	reg  core_rst_n;
	wire [15:0] led_out_int;

	wire [3:0] phy_ltssm_state; 
	wire dl_up_int;

	wire [15:0] rx_data, tx_data,  tx_dout_wbm, tx_dout_ur;
	wire [6:0] rx_bar_hit;

	wire [7:0] pd_num, pd_num_ur, pd_num_wb;

	wire [15:0] pcie_dat_i, pcie_dat_o;
	wire [31:0] pcie_adr;
	wire [1:0] pcie_sel;  
	wire [2:0] pcie_cti;
	wire pcie_cyc;
	wire pcie_we;
	wire pcie_stb;
	wire pcie_ack;

	wire [15:0] gpio_dat_i, gpio_dat_o;
	wire [31:0] gpio_adr;
	wire [1:0] gpio_sel;
	wire [2:0] gpio_cti;
	wire gpio_cyc;
	wire gpio_we;
	wire gpio_stb;
	wire gpio_ack;

	wire [15:0] ebr_dat_i, ebr_dat_o;
	wire [31:0] ebr_adr;
	wire [1:0] ebr_sel;
	wire [2:0] ebr_cti;
	wire ebr_cyc;
	wire ebr_we;
	wire ebr_stb;
	wire ebr_ack;

	wire [7:0] bus_num ; 
	wire [4:0] dev_num ; 
	wire [2:0] func_num ;


	wire [8:0] tx_ca_ph ;
	wire [12:0] tx_ca_pd  ;
	wire [8:0] tx_ca_nph ;
	wire [12:0] tx_ca_npd ;
	wire [8:0] tx_ca_cplh;
	wire [12:0] tx_ca_cpld ;
	wire clk_125;
	wire tx_eop_wbm;

pcie_core pcie_x1_core_inst (
          .pcie_extref_refclkp          ( refclkp    ),
          .pcie_extref_refclkn          ( refclkn    ),          .pcie_x1_rst_n                ( rstn       ),
          .pcie_x1_flip_lanes           ( FLIP_LANES ),
          .pcie_x1_inta_n               ( 	         ),
          .pcie_x1_msi                  ( MSI        ),
          .pcie_x1_vendor_id            ( 16'h1204   ),
          .pcie_x1_device_id            ( 16'hec30   ),
          .pcie_x1_rev_id               ( 8'h00      ),
          .pcie_x1_class_code           ( 24'h300000 ),
          .pcie_x1_subsys_ven_id        ( 16'h1204   ),
          .pcie_x1_subsys_id            ( 16'h3010   ),
          .pcie_x1_load_id              ( 1'b1       ),
          
          .pcie_x1_hdinp0               ( hdinp      ),
          .pcie_x1_hdinn0               ( hdinn      ),
          .pcie_x1_hdoutp0              ( hdoutp     ),
          .pcie_x1_hdoutn0              ( hdoutn     ),
          
          .pcie_x1_force_lsm_active     ( 1'b0       ), 
          .pcie_x1_force_rec_ei         ( 1'b0       ),     
          .pcie_x1_force_phy_status     ( 1'b0       ), 
          .pcie_x1_force_disable_scr    ( 1'b0       ),
          
          .pcie_x1_hl_snd_beacon        ( 1'b0       ),
          .pcie_x1_hl_disable_scr       ( 1'b0       ),
          .pcie_x1_hl_gto_dis           ( 1'b0       ),
          .pcie_x1_hl_gto_det           ( 1'b0       ),
          .pcie_x1_hl_gto_hrst          ( 1'b0       ),
          .pcie_x1_hl_gto_l0stx         ( 1'b0       ),
          .pcie_x1_hl_gto_l1            ( 1'b0       ),
          .pcie_x1_hl_gto_l2            ( 1'b0       ),
          .pcie_x1_hl_gto_l0stxfts      ( 1'b0       ),
          .pcie_x1_hl_gto_lbk           ( 1'd0       ),
          .pcie_x1_hl_gto_rcvry         ( 1'b0       ),
          .pcie_x1_hl_gto_cfg           ( 1'b0       ),
          .pcie_x1_no_pcie_train        ( 1'b0       ),
          
          .pcie_x1_tx_dllp_val          ( 2'd0       ),
          .pcie_x1_tx_pmtype            ( 3'd0       ),
          .pcie_x1_tx_vsd_data          ( 24'd0      ),
          
          .pcie_x1_phy_pol_compliance   ( ),   
          .pcie_x1_phy_ltssm_state      ( phy_ltssm_state ),
          
          .pcie_x1_tx_req_vc0           ( tx_req     ),    
          .pcie_x1_tx_data_vc0          ( tx_data    ),    
          .pcie_x1_tx_st_vc0            ( tx_st      ), 
          .pcie_x1_tx_end_vc0           ( tx_end     ), 
          .pcie_x1_tx_nlfy_vc0          ( 1'b0       ), 
          .pcie_x1_ph_buf_status_vc0    ( 1'b0       ),
          .pcie_x1_pd_buf_status_vc0    ( 1'b0       ),
          .pcie_x1_nph_buf_status_vc0   ( 1'b0       ),
          .pcie_x1_npd_buf_status_vc0   ( 1'b0       ),
          .pcie_x1_ph_processed_vc0     ( ph_cr      ),
          .pcie_x1_pd_processed_vc0     ( pd_cr      ),
          .pcie_x1_nph_processed_vc0    ( nph_cr     ),
          .pcie_x1_npd_processed_vc0    ( npd_cr     ),
          .pcie_x1_pd_num_vc0           ( pd_num     ),
          .pcie_x1_npd_num_vc0          ( 8'd1       ),   
          
          .pcie_x1_cmpln_tout           ( 1'b0       ),       
          .pcie_x1_cmpltr_abort_np      ( 1'b0       ),
          .pcie_x1_cmpltr_abort_p       ( 1'b0       ),
          .pcie_x1_unexp_cmpln          ( 1'b0       ),
          .pcie_x1_ur_np_ext            ( 1'b0       ),       
          .pcie_x1_ur_p_ext             ( 1'b0       ),
          .pcie_x1_np_req_pend          ( 1'b0       ),     
          .pcie_x1_pme_status           ( 1'b0       ),
          
          .pcie_x1_tx_dllp_sent         (  ),
          .pcie_x1_rxdp_pmd_type        (  ),
          .pcie_x1_rxdp_vsd_data        (  ),
          .pcie_x1_rxdp_dllp_val        (  ),
          
          .pcie_x1_tx_rdy_vc0           ( tx_rdy     ),  
          .pcie_x1_tx_ca_ph_vc0         ( tx_ca_ph   ),
          .pcie_x1_tx_ca_pd_vc0         ( tx_ca_pd   ),
          .pcie_x1_tx_ca_nph_vc0        ( tx_ca_nph  ),
          .pcie_x1_tx_ca_npd_vc0        ( tx_ca_npd  ), 
          .pcie_x1_tx_ca_cplh_vc0       ( tx_ca_cplh ),
          .pcie_x1_tx_ca_cpld_vc0       ( tx_ca_cpld ),
          .pcie_x1_tx_ca_p_recheck_vc0  ( tx_ca_p_recheck ),
          .pcie_x1_tx_ca_cpl_recheck_vc0( tx_ca_cpl_recheck ),
          .pcie_x1_rx_data_vc0          ( rx_data    ),    
          .pcie_x1_rx_st_vc0            ( rx_st      ),     
          .pcie_x1_rx_end_vc0           ( rx_end     ),   
          .pcie_x1_rx_us_req_vc0        ( rx_us_req  ), 
          .pcie_x1_rx_malf_tlp_vc0      ( rx_malf_tlp), 
          .pcie_x1_rx_bar_hit           ( rx_bar_hit ), 
          .pcie_x1_mm_enable            (  ),
          .pcie_x1_msi_enable           (  ),
          
          .pcie_x1_bus_num              ( bus_num    ),           
          .pcie_x1_dev_num              ( dev_num    ),           
          .pcie_x1_func_num             ( func_num   ),  
          .pcie_x1_pm_power_state       (  ) , 
          .pcie_x1_pme_en               (  ) , 
          .pcie_x1_cmd_reg_out          (  ),
          .pcie_x1_dev_cntl_out         (  ),  
          .pcie_x1_lnk_cntl_out         (  ),  
          
          .pcie_x1_dl_inactive          (  ),
          .pcie_x1_dl_init              (  ),
          .pcie_x1_dl_active            (  ),
          .pcie_x1_dl_up                ( dl_up_int  ),
          .pcie_x1_sys_clk_125          ( clk_125    ),
          
          // SCI interface
          .pcie_x1_sci_addr             ( 6'b0       ),
          .pcie_x1_sci_rddata           ( ), 
          .pcie_x1_sci_wrdata           ( 8'b0       ),
          .pcie_x1_sci_en               ( 1'b0       ),
          .pcie_x1_sci_en_dual          ( 1'b0       ), 
          .pcie_x1_sci_int              ( ),
          .pcie_x1_sci_rd               ( 1'b0       ),
          .pcie_x1_sci_sel              ( 1'b0       ),
          .pcie_x1_sci_sel_dual         ( 1'b0       ), 
          .pcie_x1_sci_wrn              ( 1'b0       ),

// User loop back, no connections
          .pcie_x1_rx_lbk_data          (), 
          .pcie_x1_rx_lbk_kcntl         (), 
          .pcie_x1_tx_lbk_data          ( 16'b0      ), 
          .pcie_x1_tx_lbk_kcntl         ( 2'b0       ),  
          .pcie_x1_tx_lbk_rdy           ()
          );



//=================================================================================
reg rx_st_d;
reg tx_st_d;
reg [15:0] tx_tlp_cnt;
reg [15:0] rx_tlp_cnt;
always @(posedge clk_125 or negedge rstn)
   if (!rstn) begin
      tx_st_d <= 0;
      rx_st_d <= 0;
      tx_tlp_cnt <= 0;
      rx_tlp_cnt <= 0;
   end
   else begin
      tx_st_d <= tx_st;
      rx_st_d <= rx_st;
      if (tx_st_d) tx_tlp_cnt <= tx_tlp_cnt + 1;
      if (rx_st_d) rx_tlp_cnt <= rx_tlp_cnt + 1;
         
   end

ip_rx_crpr cr (.clk(clk_125), .rstn(rstn), .rx_bar_hit(rx_bar_hit),
               .rx_st(rx_st), .rx_end(rx_end), .rx_din(rx_data),
               .pd_cr(pd_cr_ur), .pd_num(pd_num_ur), .ph_cr(ph_cr_ur), .npd_cr(npd_cr_ur), .nph_cr(nph_cr_ur)               
);

ip_crpr_arb crarb(.clk(clk_125), .rstn(rstn), 
            .pd_cr_0(pd_cr_ur), .pd_num_0(pd_num_ur), .ph_cr_0(ph_cr_ur), .npd_cr_0(npd_cr_ur), .nph_cr_0(nph_cr_ur),
            .pd_cr_1(pd_cr_wb), .pd_num_1(pd_num_wb), .ph_cr_1(ph_cr_wb), .npd_cr_1(1'b0), .nph_cr_1(nph_cr_wb),               
            .pd_cr(pd_cr), .pd_num(pd_num), .ph_cr(ph_cr), .npd_cr(npd_cr), .nph_cr(nph_cr)               
);

UR_gen ur (.clk(clk_125), .rstn(rstn),  
            .rx_din(rx_data), .rx_sop(rx_st), .rx_eop(rx_end), .rx_us(rx_us_req), .rx_bar_hit(rx_bar_hit),
             .tx_rdy(tx_rdy_ur), .tx_ca_cpl_recheck(1'b0), .tx_ca_cplh(tx_ca_cplh),
             .tx_req(tx_req_ur), .tx_dout(tx_dout_ur), .tx_sop(tx_sop_ur), .tx_eop(tx_eop_ur),
             .comp_id({bus_num, dev_num, func_num})
);
         
ip_tx_arbiter #(.c_DATA_WIDTH (16))
           tx_arb(.clk(clk_125), .rstn(rstn), .tx_val(1'b1),
                  .tx_req_0(tx_req_wbm), .tx_din_0(tx_dout_wbm), .tx_sop_0(tx_sop_wbm), .tx_eop_0(tx_eop_wbm), .tx_dwen_0(1'b0), //  wb_tlc              
                  .tx_req_1(1'b0), .tx_din_1(16'd0), .tx_sop_1(1'b0), .tx_eop_1(1'b0), .tx_dwen_1(1'b0),//empty
                  .tx_req_2(1'b0), .tx_din_2(16'd0), .tx_sop_2(1'b0), .tx_eop_2(1'b0), .tx_dwen_2(1'b0),//empty
                  .tx_req_3(tx_req_ur), .tx_din_3(tx_dout_ur), .tx_sop_3(tx_sop_ur), .tx_eop_3(tx_eop_ur), .tx_dwen_3(1'b0),//UR_gen
                  .tx_rdy_0(tx_rdy_wbm), .tx_rdy_1(), .tx_rdy_2( ), .tx_rdy_3(tx_rdy_ur),
                  .tx_req(tx_req), .tx_dout(tx_data), .tx_sop(tx_st), .tx_eop(tx_end), .tx_dwen(),
                  .tx_rdy(tx_rdy)
                  
);                           

wb_tlc wb_tlc(.clk_125(clk_125), .wb_clk(clk_125), .rstn(rstn),
              .rx_data(rx_data), .rx_st(rx_st), .rx_end(rx_end), .rx_bar_hit(rx_bar_hit),
              .wb_adr_o(pcie_adr), .wb_dat_o(pcie_dat_o), .wb_cti_o(pcie_cti), .wb_we_o(pcie_we), .wb_sel_o(pcie_sel), .wb_stb_o(pcie_stb), .wb_cyc_o(pcie_cyc), .wb_lock_o(), 
              .wb_dat_i(pcie_dat_i), .wb_ack_i(pcie_ack),
              .pd_cr(pd_cr_wb), .pd_num(pd_num_wb), .ph_cr(ph_cr_wb), .npd_cr(npd_cr_wb), .nph_cr(nph_cr_wb),
              .tx_rdy(tx_rdy_wbm),
              .tx_req(tx_req_wbm), .tx_data(tx_dout_wbm), .tx_st(tx_sop_wbm), .tx_end(tx_eop_wbm), .tx_ca_cpl_recheck(1'b0), .tx_ca_cplh(tx_ca_cplh), .tx_ca_cpld(tx_ca_cpld),
              .comp_id({bus_num, dev_num, func_num}),
              .debug()
);


wb_arb #(.c_DATA_WIDTH(16),
         .S0_BASE     (32'h0000),
         .S1_BASE     (32'h8000),
         .S2_BASE     (32'h9000),
         .S3_BASE     (32'hA000)
         // .S0_BASE     (32'h0000),
         // .S1_BASE     (32'h4000),
         // .S2_BASE     (32'h2000),
         // .S3_BASE     (32'h5000)
) wb_arb (
    .clk(clk_125),
    .rstn(rstn),
	
    //PCIe Master 
    .m0_dat_i(pcie_dat_o), 
    .m0_dat_o(pcie_dat_i), 
    .m0_adr_i(pcie_adr),
    .m0_sel_i(pcie_sel), 
    .m0_we_i(pcie_we), 
    .m0_cyc_i(pcie_cyc),
    .m0_cti_i(pcie_cti),
    .m0_stb_i(pcie_stb), 
    .m0_ack_o(pcie_ack), 
    .m0_err_o(), 
    .m0_rty_o(), 
    
    // DMA Master
    .m1_dat_i(16'd0), 
    .m1_dat_o(), 
    .m1_adr_i(32'd0),
    .m1_sel_i(2'd0), 
    .m1_we_i(1'b0), 
    .m1_cyc_i(1'b0),
    .m1_cti_i(3'd0),
    .m1_stb_i(1'b0), 
    .m1_ack_o(), 
    .m1_err_o(), 
    .m1_rty_o(),         

    // GPIO 32-bit
    .s0_dat_i(gpio_dat_o), 
    .s0_dat_o(gpio_dat_i), 
    .s0_adr_o(gpio_adr), 
    .s0_sel_o(gpio_sel), 
    .s0_we_o (gpio_we), 
    .s0_cyc_o(gpio_cyc),
    .s0_cti_o (gpio_cti),
    .s0_stb_o(gpio_stb), 
    .s0_ack_i(gpio_ack), 
    .s0_err_i(gpio_err),
    .s0_rty_i(gpio_rty), 
    
    // DMA Slave
    .s1_dat_i(16'd0), 
    .s1_dat_o(), 
    .s1_adr_o(), 
    .s1_sel_o(), 
    .s1_we_o (), 
    .s1_cyc_o(),
    .s1_cti_o(),
    .s1_stb_o(), 
    .s1_ack_i(1'b0), 
    .s1_rty_i(1'b0),
    .s1_err_i(1'b0),
    
    // EBR
    // .s2_dat_i(ebr_dat_o), 
    // .s2_dat_o(ebr_dat_i), 
    // .s2_adr_o(ebr_adr), 
    // .s2_sel_o(ebr_sel), 
    // .s2_we_o (ebr_we), 
    // .s2_cyc_o(ebr_cyc),
    // .s2_cti_o(ebr_cti),
    // .s2_stb_o(ebr_stb), 
    // .s2_ack_i(ebr_ack), 
    // .s2_err_i(ebr_err),
    // .s2_rty_i(ebr_rty),
    .s2_dat_i(16'd0), 
    .s2_dat_o(), 
    .s2_adr_o(), 
    .s2_sel_o(), 
    .s2_we_o (), 
    .s2_cyc_o(),
    .s2_cti_o(),
    .s2_stb_o(), 
    .s2_ack_i(1'b0), 
    .s2_err_i(1'b0),
    .s2_rty_i(1'b0),
    
    // Not used
    .s3_dat_i(16'd0), 
    .s3_dat_o(), 
    .s3_adr_o(), 
    .s3_sel_o(), 
    .s3_we_o (), 
    .s3_cyc_o(),
    .s3_cti_o(),
    .s3_stb_o(), 
    .s3_ack_i(1'b0),
    .s3_rty_i(1'b0), 
    .s3_err_i(1'b0)
);

	// WinnerSRCTop 		#(.Version (32'hFCAB0001))
				// Winner	(.nReset(rstn),
						 // .Clk(clk_125),
						 // .Cycle(gpio_cyc),
						 // .STB(gpio_stb),
						 // .WRIn(gpio_we),
						 // .SelectIn(gpio_sel),
						 // .CTI(gpio_cti),
						 // .Addrss(gpio_adr),
						 // .DataIn(gpio_dat_i),
						 // .DataOut(gpio_dat_o),
						 // .ACK(gpio_ack),
						 // .ERR(),
						 // .RTY(),
						 // .CA_PD(tx_ca_pd),
						 // .CA_NPH(tx_ca_nph),
						 // .DL_UP(dl_up_int),
						 // .MSI(MSI),
						 // .VIDEO_SYNC_DE(VIDEO_SYNC_DE),
						 // .VIDEO_SYNC(VIDEO_SYNC),
						 // .TEL_COM_RS485_1_DE(TEL_COM_RS485_1_DE),
						 // .TEL_COM_RS485_1(TEL_COM_RS485_1),
						 // .TEL_COM_RS485_2_DE(TEL_COM_RS485_2_DE),
						 // .TEL_COM_RS485_2(TEL_COM_RS485_2),
						 // .TEL_COM_RS485_3_DE(TEL_COM_RS485_3_DE),
						 // .TEL_COM_RS485_3(TEL_COM_RS485_3),
						 // .TEL_COM_RS485_4_DE(TEL_COM_RS485_4_DE),
						 // .TEL_COM_RS485_4(TEL_COM_RS485_4),
						 // .TEL_COM_RS485_5_DE(TEL_COM_RS485_5_DE),
						 // .TEL_COM_RS485_5(TEL_COM_RS485_5),
						 // .ZABAD_2_SN(ZABAD_2_SN),
						 // .SN_2_ZABAD(SN_2_ZABAD),
						 // .COM_SAFE_ARM_IN(COM_SAFE_ARM_IN),
						 // .COM_SAFE_ARM_OUT(COM_SAFE_ARM_OUT)
						// );
             
// wbs_gpio gpio(.wb_clk_i(clk_125), .wb_rst_i(~rstn),
          // .wb_dat_i(gpio_dat_i), .wb_adr_i(gpio_adr[8:0]), .wb_cti_i(gpio_cti), .wb_cyc_i(gpio_cyc), .wb_lock_i(1'b0), .wb_sel_i(gpio_sel), .wb_stb_i(gpio_stb), .wb_we_i(gpio_we),          
          // .wb_dat_o(gpio_dat_o), .wb_ack_o(gpio_ack), .wb_err_o(gpio_err), .wb_rty_o(gpio_rty), 
          // .switch_in(dip_switch), .led_out(led_out_int), 
          // .dma_req(dma_req_gpio), .dma_ack(5'd0), 
          // .ca_pd(tx_ca_pd), .ca_nph(tx_ca_nph), .dl_up(dl_up_int),
          // .int_out()
// );
                    
// wbs_32kebr ebr(.wb_clk_i(clk_125), .wb_rst_i(~rstn),
          // .wb_dat_i(ebr_dat_i), .wb_adr_i(ebr_adr), .wb_cyc_i(ebr_cyc), .wb_sel_i(ebr_sel), .wb_stb_i(ebr_stb), .wb_we_i(ebr_we), .wb_cti_i(ebr_cti),
          // .wb_dat_o(ebr_dat_o), .wb_ack_o(ebr_ack), .wb_err_o(ebr_err), .wb_rty_o(ebr_rty)          
// );                          

endmodule

