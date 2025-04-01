`timescale 1ns / 1 ps

module pcie2_x1_phy

( //--begin_ports--
//----------------------------
// Inputs
//----------------------------
input                         pll_refclki,
input                         rxrefclk,
input                         RESET_n,

input                         hdinp0,
input                         hdinn0,

input       [15:0]            TxData_0,
input       [1:0]             TxDataK_0,
input       [1:0]             TxCompliance_0,
input                         TxElecIdle_0,
input                         RxPolarity_0,


input                         TxDetectRx_Loopback,
input                         Rate,
input                         TxDeemph,
input       [1:0]             PowerDown,
input       [2:0]             TxMargin,
input                         TxSwing,

input       [1:0]             infer_rx_eidle,
input       [1:0]             phy_cfgln,
input                         phy_l0,
input                         ctc_disable,
input                         flip_lanes,
input                         phy_pol_compliance,

//----------------------------
// Outputs
//----------------------------
output wire                   PCLK,
output wire                   PCLK_125,

output wire                   hdoutp0,
output wire                   hdoutn0,

output reg  [15:0]            RxData_0,
output reg  [1:0]             RxDataK_0,
output reg                    RxValid_0,
output reg                    RxElecIdle_0,
output reg  [2:0]             RxStatus_0,



`ifdef SIMULATE
output wire                   sci_busy,
`endif

output wire                   ffs_plol,
output wire                   ffs_rlol_ch0,
output wire                   ffs_rlol_ch1,
output wire                   pcie_ip_rstn,
output reg                    PhyStatus

); //--end_ports--



// =============================================================================
// Parameters
// =============================================================================
localparam                    ONE_US         = 8'b11111111;   // 1 Micro sec = 256 clks
localparam                    ONE_US_4BYTE   = 8'b00000101;   // 1 us + 6 clks

localparam                    PCIE_DET_IDLE   = 2'b00;
localparam                    PCIE_DET_EN     = 2'b01;
localparam                    PCIE_CT         = 2'b10;
localparam                    PCIE_DONE       = 2'b11;
localparam                    SCI_WAIT_TIME   = 63;

parameter                     CH1_ENABLED     = 1'b0;

parameter                     RATE_IDLE         = 7'b0000001;
parameter                     RATE_INIT_WAIT    = 7'b0000010;
parameter                     RATE_INIT_GEN1    = 7'b0000100;
parameter                     RATE_WAIT_WIP     = 7'b0001000;
parameter                     RATE_SER_PCS_RST  = 7'b0010000;
parameter                     RATE_CMD_WAIT     = 7'b0100000;
parameter                     RATE_SCI_WR       = 7'b1000000;

parameter                     GEN2_6DB        = 2'd0;
parameter                     GEN1_35DB       = 2'd3;

// =============================================================================
// Wires & Regs
// =============================================================================
wire                          clk_250;
wire                          clk_125;

wire                          ffs_rlol;
wire                          ffs_rlol_ch0_int;
wire                          ffs_rlol_ch1_int;

wire                          fpsc_vlo;
wire                          fpsc_vhi;

wire                          ff_tx_f_clk;
wire                          rsl_rx_rdy;

wire                          ffc_fb_loopback_0;
wire                          ffs_pcie_done_0;
wire                          ffs_pcie_con_0;
wire                          RxValid_0_in;
reg                           RxElecIdle_0_in;
wire        [15:0]            RxData_0_int;
wire        [15:0]            RxData_0_in;
wire        [1:0]             RxDataK_0_in;
wire        [1:0]             RxDataK_0_int;
wire        [2:0]             RxStatus_0_in0;
wire        [2:0]             RxStatus_0_in1;
wire        [5:0]             RxStatus_0_in;
wire        [15:0]            TxData_0_out;
wire        [15:0]            TxData_0_outt;
wire        [1:0]             TxDataK_0_out;
wire        [1:0]             TxDataK_0_outt;

wire                          rx_los_low_ch0_s;
reg                           rsl_rx_eidle_0;


reg                           RxValid_0i;

wire                          flip_RxValid_0;
wire        [15:0]            flip_RxData_0;
wire        [1:0]             flip_RxDataK_0;
wire                          flip_RxElecIdle_0;
wire        [2:0]             flip_RxStatus_0;
reg         [15:0]            flip_TxData_0;
reg         [1:0]             flip_TxDataK_0;
reg                           flip_TxElecIdle_0;
reg         [1:0]             flip_TxCompliance_0;
reg                           flip_RxPolarity_0;

wire                          RxPolarity_0_out;
wire        [1:0]             TxElecIdle_0_out;
//wire                          Rate_0_out;
//wire                          TxDeemph_0_out;
//wire        [2:0]             TxMargin_0_out;
//wire                          TxSwing_0_out;


// =============================================================================
// =============================================================================
//For PowerDown
wire                          pwdn;
wire                          ffc_pwdnb_0;
wire                          ffc_pwdnb_1;

reg  [1:0]                    cs_reqdet_sm;
reg                           detsm_done;
reg  [1:0]                    det_result;   // Only for RTL sim
reg                           pcie_con_0;
reg                           pcie_con_1;
reg                           ffc_pcie_ct;
reg                           ffc_pcie_det_en_0;
reg                           ffc_pcie_det_en_1;

reg                           cnt_enable;
reg                           cntdone_en;
reg                           cntdone_ct;
   reg  [7:0]                 detsm_cnt;   // 1 us (256 clks)

wire                          done_all_re;
wire                          done_0_re;
wire                          done_1_re;

reg                           done_0_reg;
reg                           done_0_d0 /* synthesis syn_srlstyle="registers" */;
reg                           done_0_d1 /* synthesis syn_srlstyle="registers" */;
reg                           done_1_reg;
reg                           done_1_d0 /* synthesis syn_srlstyle="registers" */;
reg                           done_1_d1 /* synthesis syn_srlstyle="registers" */;
reg                           done_all;
reg                           done_all_reg /* synthesis syn_srlstyle="registers" */;

reg                           detect_req;
reg                           detect_req_del /* synthesis syn_srlstyle="registers" */;

reg                           enable_det_ch0 ;
reg                           enable_det_ch1 ;
wire                          enable_det_int ;
wire                          enable_det_all ;

reg                           PLOL_sync;
reg                           PLOL_pclk /* synthesis syn_srlstyle="registers" */;
reg  [1:0]                    PowerDown_reg /* synthesis syn_srlstyle="registers" */;
reg                           PLOL_hsync;
reg                           PLOL_hclk;

// Signals for Masking RxValid for 4 MS
reg [16:0]                    count_ms;
reg                           count_ms_enable;
reg [2:0]                     num_ms;
reg                           pcs_wait_done;
reg                           detection_done;
reg                           start_count;
reg                           start_count_del;
reg [1:0]                     RxEI_sync;
reg [1:0]                     RxEI;
reg [1:0]                     RxEI_masked_sync;
reg [1:0]                     RxEI_masked;
wire                          EI_Det_0;
wire                          EI_Det_1;
reg [1:0]                     EI_low;
reg [1:0]                     EI_low_pulse;
reg                           reset_counter;
reg                           allEI_high;
reg [1:0]                     RxLOL_sync;
reg [1:0]                     RxLOL;
reg [1:0]                     RxLOL_del;
reg [1:0]                     RxLOL_posedge;

// Signals for Masking EI for 1 us   (false glitch)
reg                           check;
reg                           start_mask;
reg [6:0]                     ei_counter;


// For Default Values / RTL Simulation
reg                           Int_RxElecIdle_ch0;
reg                           Int_RxElecIdle_ch1;
reg                           Int_ffs_rlol_ch0;
reg                           Int_ffs_rlol_ch1;

wire                          RxElecIdle_ch0_8;  //Required for 4 MS mask from PIPE TOP
wire                          RxElecIdle_ch1_8;

wire                          ff_rx_fclk_0 /* synthesis syn_keep=1 */;
wire                          ff_rx_fclk_1 /* synthesis syn_keep=1 */;


wire                          scic_wip;

wire                          sci_rd;          // SCI Read Strobe
wire                          sci_wrn;          // SCI Write Strobe
wire        [7:0]             sci_wrdata;
wire        [5:0]             sci_addr;
wire                          sci_sel_dual0;
wire                          sci_sel_chnl0;
wire                          sci_en_chnl0;
wire                          sci_en_dual0;
wire                          sci_sel_chnl1;
wire                          sci_en_chnl1;
wire        [7:0]             sci_rddata;
wire                          sci_int;
wire                          cyawstn;

reg                           sci_rate_busy;
reg         [5:0]             rate_sm_cnt;
reg         [6:0]             rate_sm;
reg                           rate_change_pend;
reg                           pcie_mode_alt;    // PCIe Mode Alternate
reg         [1:0]             pcie_mode;        // PCIe Mode
reg         [2:0]             pcie_chnl_sel;    // PCIe Channel Select
reg                           rx_serdes_rst_c;
reg                           rx_pcs_rst_c;
reg                           cur_rate;

reg         [1:0]             rate_sync_125;
reg                           current_pcie_rate;
reg                           rate_phy_sts;
reg                           rate_phy_sts_ext;
reg         [2:0]             rate_phy_sts_rcvd;
reg                           rate_phy_sts_ack;
reg         [1:0]             current_pcie_rate_sync;

reg                           rate_phy_sts_ext_q;
reg                           rate_phy_sts_ext_qq;
reg                           rate_phy_sts_pclk;
reg                           rate_phy_sts_pclk_q;

wire                          rate_p;
wire                          deemph_p;
reg         [1:0]             pcie_mode_i;
reg                           Rate_d;
reg                           TxDeemph_d;
reg                           TxDeemph_q;
reg                           TxDeemph_qq;
reg                           snd_sci_cmd;

reg                           PLOL_rfclk;
reg                           PLOL_rfclk_d;
reg                           rate_rfclk;
reg                           rate_rfclk_d;
reg                           rate_rfclk_q;

reg                           ctc_pause;
reg                           ctc_pause_nxt;


wire                          tx_pclk;
wire        [2:0]             pcsclk_div;

wire                          serdes_rst_dual_c ;

assign serdes_rst_dual_c = ~RESET_n ;

wire                          sli_rst           ;
assign sli_rst           = serdes_rst_dual_c | (~ffc_pwdnb_0);

// =============================================================================
VLO fpsc_vlo_inst (.Z(fpsc_vlo));
VHI fpsc_vhi_inst (.Z(fpsc_vhi));

`ifdef SIMULATE
assign sci_busy = scic_wip;
`endif

assign clk_250           = ff_tx_f_clk;
assign clk_125           = PCLK_125;

assign PCLK              = ff_tx_f_clk;                        // Gen1 = 125Mhz, Gen2=250 Mhz clock
assign pcsclk_div       = (cur_rate == 1'b1) ? 3'b010 : 3'b001;  // Gen2:div=2,  Gen1: div=1
// =============================================================================
// Power down (P2) unused channels when in downgrade mode and when in L0
// =============================================================================
assign pwdn   = ~(PowerDown[1] & PowerDown[0]);

// Power down non configured lane
assign ffc_pwdnb_0 = pwdn;  //Active LOW only for P2
assign ffc_pwdnb_1 = pwdn;


//--------------------------------------------
//-- Combinatorial block --
// Lane reversal
//--------------------------------------------
always @* begin
  RxValid_0i          = flip_RxValid_0   ;
  RxData_0            = flip_RxData_0    ;
  RxDataK_0           = flip_RxDataK_0   ;
  RxElecIdle_0        = flip_RxElecIdle_0;
  RxStatus_0          = flip_RxStatus_0  ;
  flip_TxData_0       = TxData_0         ;
  flip_TxDataK_0      = TxDataK_0        ;
  flip_TxElecIdle_0   = TxElecIdle_0     ;
  flip_TxCompliance_0 = TxCompliance_0   ;
  flip_RxPolarity_0   = RxPolarity_0     ;
end //--always @*--

// ======================= RK MODIFICATIONS START ==============================
// New signals :
// pcs_wait_done_ch0, 1,2,3  -- for Rx_valid
// rlol_ch0, 1,2,3           -- for sync_rst
// =============================================================================
// 1 MS Timer -- 18-bit : 250,000 clks (250Mhz)
// count_ms can go upto 262,144 clks (1 ms + 48 us)
// DETECT to POLLING (P1 to P0): the timer starts & after 4 MS,  RxValids
// are passed.
// =============================================================================


///// inputs : pcs_wait_done

///// inputs   : pcs_wait_done, start_mask, Int_RxElecIdle_ch0/1/2/3
///// outputs  : RxElecIdle_ch0_8 (masked EI)

///// inputs : detsm_done

// =============================================================================
// Make Default values in case of X1
// =============================================================================
always@* begin
   // If defined, take from PCS otherwise assign default values

   Int_ffs_rlol_ch0    = 1'b1;
   Int_ffs_rlol_ch1    = 1'b1;
   Int_RxElecIdle_ch0  = 1'b1;
   Int_RxElecIdle_ch1  = 1'b1;
   pcie_con_0          = 1'b0;
   pcie_con_1          = 1'b0;

   pcie_con_0          = ffs_pcie_con_0;
   Int_RxElecIdle_ch0  = RxElecIdle_0_in;
   Int_ffs_rlol_ch0    = ffs_rlol_ch0_int;
`ifdef SIMULATE
   // translate_off
   // PCS Sim. Model is not giving Result
   pcie_con_0          = det_result[0];
   pcie_con_1          = det_result[1];
   // translate_on
`endif
end

// EIDet = 4'b1111 --> when ALL LANES are DETECTED & All lanes are NOT in Elec Idle
// ffs_pcie_con_0/1/2/3 are already stabilized & qualified with "detection_done"
assign EI_Det_0  = ~(RxEI_masked[0]) & pcie_con_0;
assign EI_Det_1  = ~(RxEI_masked[1]) & pcie_con_1;

always @(posedge clk_125 or negedge RESET_n) begin
   if(!RESET_n) begin
      count_ms        <= 17'b00000000000000000; // 17-bits for 1 MS
      count_ms_enable <= 1'b0;
      num_ms          <= 3'b000;
      pcs_wait_done   <= 1'b0;

      detection_done  <= 1'b0;
      start_count     <= 1'b0;
      start_count_del <= 1'b0;
      RxEI_sync       <= 2'b11;
      RxEI            <= 2'b11;
      RxEI_masked_sync <= 2'b11;
      RxEI_masked     <= 2'b11;

      EI_low          <= 2'd0;
      EI_low_pulse    <= 2'b00;

      reset_counter   <= 1'b0;
      allEI_high      <= 1'b0;
      RxLOL_sync      <= 2'b11;
      RxLOL           <= 2'b11;
      RxLOL_del       <= 2'b11;
      RxLOL_posedge   <= 2'b00;
      rate_sync_125   <= 2'b11;
   end
   else begin
      rate_sync_125 <= {rate_sync_125[0],current_pcie_rate};
      RxLOL_sync <= {1'b1, Int_ffs_rlol_ch0};
      //For "1us Masked RxElecIdle -> RxElecIdle_ch0_8"  Take PCS EI
      RxEI_sync  <= {1'b1, Int_RxElecIdle_ch0};
      //Use "Masked RxElecIdle -> RxElecIdle_ch0_8"  for 4MS Mask
      RxEI_masked_sync <= {1'b1, RxElecIdle_ch0_8};
      //Sync.
      RxLOL        <= RxLOL_sync;
      RxEI         <= RxEI_sync;
      RxEI_masked  <= RxEI_masked_sync;


  // After COUNTER enabled, Reset conditions :
  // 1) Any EI going LOW
  // 2) ALL EI going HIGH
  //      keep reset ON until at least one EI goes LOW
  // 3) Any RLOL going HIGH (qualified with corresponding EI LOW)

  // 1) Any EI going LOW
      // ffs_pcie_con_0/1/2/3 stable & qualified with "count_ms_enable"
      EI_low[0]     <= count_ms_enable & EI_Det_0;
      EI_low[1]     <= count_ms_enable & EI_Det_1;

      // Generate "reset counter pulse" whenever EI goes on ANY channel
      EI_low_pulse[0] <= ~(EI_low[0]) & count_ms_enable & EI_Det_0;
      EI_low_pulse[1] <= ~(EI_low[1]) & count_ms_enable & EI_Det_1;

  // 2) ALL EI going HIGH
  //      keep reset ON until at least one EI goes LOW
  //Timer already started & then ALL EIs are HIGH
      if (count_ms_enable == 1'b1 && EI_low == 2'b00)
         allEI_high   <= 1'b1;   // Means EI LOW gone
      else
         allEI_high   <= 1'b0;


  // 3) Any RLOL going HIGH (qualified with corresponding EI LOW)
      RxLOL_del     <= RxLOL;
      RxLOL_posedge[0] <= EI_low[0] & RxLOL[0] & ~(RxLOL_del[0]);
      RxLOL_posedge[1] <= EI_low[1] & RxLOL[1] & ~(RxLOL_del[1]);

      // Reset Counter = 1 + 2 + 3
      // ANY EI low pulse -OR- all EI high -OR- ANY RLOL Posedge
      if ((EI_low_pulse != 2'b00) || (allEI_high == 1'b1) || (RxLOL_posedge != 2'b00))
         reset_counter  <= 1'b1;
      else
         reset_counter  <= 1'b0;

      if(detection_done == 1'b1) begin
         if (start_count == 1'b1)
            detection_done  <= 1'b0; // change the signal name
      end
      else if (RxEI_masked == 2'b11 && count_ms_enable == 1'b0)
         detection_done  <= 1'b1;

      //Start Timer after DETECT & AT LEAST ONE Lane is not in EI
      // Reset the count with any EI LOW after that
      // ie counts from Last EI low
      //Any lane DETECTED & NOT in EI
      start_count     <= detection_done & (EI_Det_0 | EI_Det_1);
      start_count_del <= start_count;

      // 1 MS Timer
      if (count_ms_enable == 1'b1 && reset_counter == 1'b0)
         count_ms <= count_ms + 1'b1;
      else // EI gone LOW, start again
         count_ms <= 17'b00000000000000000;

      // 1 MS Timer Enable -- From DETECT to POLLING
      // After detect pulse & then ANY EI gone ZERO
      if ((start_count == 1'b1) && (start_count_del == 1'b0)) //Pulse
         count_ms_enable <= 1'b1;
      else if (num_ms == 3'b100) //4 MS
         count_ms_enable <= 1'b0;

      // No. of MS
      if (count_ms == 17'b11111111111111111)
         num_ms  <= num_ms + 1'b1;
      else if (num_ms == 3'b100) //4 MS
         num_ms  <= 3'b000;

      // pcs_wait_done  for bit lock & symbol lock
      // Waiting for PCS to give stabilized RxValid
      if (num_ms == 3'b100) //4 MS
         pcs_wait_done <= 1'b1;   // Enable passing the RX Valid
      else if (RxEI_masked == 2'b11)
         //pcs_wait_done <= 1'b0;   // Disable when in DETECT
         pcs_wait_done <= rate_sync_125[1];

`ifdef SIMULATE
             // translate_off
             // 1 MS Timer  ==> 8 clks Timer
             if (count_ms_enable == 1'b1 && reset_counter == 1'b0)
                count_ms[2:0] <= count_ms[2:0] + 1'b1;
             else // EI gone LOW, start again
                count_ms <= "00000000000000000";

             // No. of MS
             if (count_ms[2:0] == 3'b111)
                num_ms  <= num_ms + 1'b1;
             else if (num_ms == 3'b100) //4 MS  ==> 4x8=32 clks
                num_ms  <= 3'b000;
             // translate_on
`endif
   end
end

//assign ffs_plol = pcs_top_0.DCU0_inst.D_FFS_PLOL;
// =============================================================================
// Masking the RxEIDLE Glitch  (otherside Rcvr Detction)
// =============================================================================
always @(posedge clk_125 or negedge RESET_n) begin
   if(!RESET_n) begin
      check       <= 1'b0;
      start_mask  <= 1'b0;
      ei_counter  <= 7'b0000000;
      PLOL_hsync  <= 1'b1;
      PLOL_hclk   <= 1'b1;
   end
   else begin
      // Sync.
      PLOL_hsync <= ffs_plol;
      PLOL_hclk  <= PLOL_hsync;

      if (PLOL_hclk == 1'b0)  begin
            if (RxEI == 2'b11)
               check <= 1'b1;

            if (ei_counter == 7'b1111111) begin // 128 clks (1us)
               start_mask   <= 1'b0;
               check        <= 1'b0;
            end
            else if (check == 1'b1 && RxEI != 2'b11) // Any lane goes low
               start_mask  <= 1'b1;

`ifdef SIMULATE
             // translate_off
            if (ei_counter[2:0] == 3'b111) begin // 7 clks (1us)
               start_mask   <= 1'b0;
               check        <= 1'b0;
            end
            else if (check == 1'b1 && RxEI != 2'b11) // Any lane goes low
               start_mask  <= 1'b1;
             // translate_on
`endif
      end
      else begin
         check       <= 1'b0;
         start_mask  <= 1'b0;
      end

      if(start_mask == 1'b1)
         ei_counter  <= ei_counter + 1'b1;
      else
         ei_counter  <= 7'b0000000;

   end
end



// ======================= RK MODIFICATIONS END ===============================
assign RxStatus_0_in = {RxStatus_0_in1, RxStatus_0_in0};
assign RxData_0_in   = {RxData_0_int[7:0],RxData_0_int[15:8]};
assign RxDataK_0_in  = {RxDataK_0_int[0],RxDataK_0_int[1]};
assign TxData_0_out  = {TxData_0_outt[7:0],TxData_0_outt[15:8]};
assign TxDataK_0_out = {TxDataK_0_outt[0],TxDataK_0_outt[1]};

// =============================================================================
// State machine to write into SCI port
// =============================================================================

assign rate_p   = rate_rfclk_d ^ rate_rfclk_q;
assign deemph_p = TxDeemph_q ^ TxDeemph_qq;

always @(posedge pll_refclki or negedge RESET_n) begin
   if(!RESET_n) begin
     PLOL_rfclk          <= 1'b1;
     PLOL_rfclk_d        <= 1'b1;
     rate_rfclk          <= 1'b0;
     rate_rfclk_d        <= 1'b0;
     rate_rfclk_q        <= 1'b0;
     rate_phy_sts_ext    <= 1'b0;
     rate_phy_sts_rcvd   <= 3'd0;
     current_pcie_rate   <= 1'b1;
     snd_sci_cmd         <= 1'b0;
     pcie_mode_i         <= 2'b11;
     TxDeemph_d          <= 1'b1;
     TxDeemph_q          <= 1'b1;
     TxDeemph_qq         <= 1'b1;
   end
   else begin
     PLOL_rfclk          <= PLOL_pclk;
     PLOL_rfclk_d        <= PLOL_rfclk;
     rate_rfclk          <= Rate;
     rate_rfclk_d        <= rate_rfclk;
     rate_rfclk_q        <= rate_rfclk_d;
     TxDeemph_d          <= TxDeemph;
     TxDeemph_q          <= TxDeemph_d;
     TxDeemph_qq         <= TxDeemph_q;
     // extend rate_phy_sts pulse then synchronize to PCLK until received by
     // other clock domain
     rate_phy_sts_rcvd   <= {rate_phy_sts_rcvd[1:0],rate_phy_sts_pclk};
     rate_phy_sts_ext    <= (rate_phy_sts_ext & ~rate_phy_sts_ack) | rate_phy_sts;
     current_pcie_rate   <= rate_phy_sts ^ current_pcie_rate;

     snd_sci_cmd         <= (rate_p | deemph_p);
     if(rate_p | deemph_p) begin
       pcie_mode_i[1] <= ~rate_rfclk_d;
       // TxDeemph = -3.5dB for 2.5G, -6dB for 5G
       pcie_mode_i[0] <= ~rate_rfclk_d | TxDeemph_q;
     end
   end
end

always @* begin
  rate_phy_sts_ack = rate_phy_sts_rcvd[1] & ~rate_phy_sts_rcvd[2];
end //--always @*--

always @(posedge pll_refclki or negedge RESET_n) begin  //125 or 250 Mhz
   if (!RESET_n) begin
      rate_sm         <= RATE_IDLE;
      rate_sm_cnt     <= 'd0;
      pcie_chnl_sel   <= 3'd0;
      pcie_mode       <= GEN2_6DB;
      pcie_mode_alt   <= 1'b0;
      rate_change_pend <= 1'b0;
      rate_phy_sts    <= 1'b0;
      rx_serdes_rst_c <= 1'b1;
      rx_pcs_rst_c    <= 1'b1;
      cur_rate        <= 1'b0;
      sci_rate_busy   <= 1'b0;
   end
   else begin
      case (rate_sm)
      RATE_IDLE : begin  // 01
                    rx_pcs_rst_c    <= 1'b0;
                    //if (!PLOL_rfclk_d )
                      rate_sm <= RATE_INIT_WAIT;
                    //else
                      //rate_sm <= RATE_IDLE;
                  end

      RATE_INIT_WAIT : begin //02
                       if (rate_sm_cnt == SCI_WAIT_TIME) begin
                          rate_sm  <= RATE_INIT_GEN1;
                          rate_sm_cnt <= 'd0;
                       end
                       else begin
                          rate_sm  <= RATE_INIT_WAIT;
                          rate_sm_cnt <= rate_sm_cnt + 1;
                       end
                       end

      RATE_INIT_GEN1 : begin  //04
                       pcie_mode     <= GEN1_35DB;
                       pcie_mode_alt <= 1'b1;
                       rate_change_pend <= CH1_ENABLED;
                       rate_sm       <= RATE_WAIT_WIP;
                       end
      RATE_WAIT_WIP : begin  //08
                       pcie_mode_alt <= 1'b0;
                       sci_rate_busy <= 1'b1;
                       if (scic_wip) begin
                          cur_rate   <= rate_rfclk_d;
                          rate_sm    <= RATE_SER_PCS_RST;
                       end
                       else
                          rate_sm  <= RATE_WAIT_WIP;
                       end
      RATE_SER_PCS_RST : begin //10
                          if (!scic_wip) begin
                             rx_serdes_rst_c <= 1'b1;
                             rx_pcs_rst_c    <= 1'b1;
                             rate_sm    <= RATE_CMD_WAIT;
                          end
                          else
                             rate_sm  <= RATE_SER_PCS_RST;
                       end
      RATE_CMD_WAIT :  begin  //20
                       rx_serdes_rst_c <= 1'b0;
                       rx_pcs_rst_c    <= 1'b0;
                       sci_rate_busy <= rate_change_pend;
                       //if (!PLOL_rfclk_d && !scic_wip ) begin
                       if (!scic_wip ) begin
                         //----------------Added for Channel 1 Begin-----
                            pcie_chnl_sel <= 3'd0;
                         if(rate_change_pend) begin
                          rate_sm  <= RATE_WAIT_WIP;
                          pcie_mode_alt <= 1'b1;
                          rate_change_pend <= 1'b0;
                          pcie_chnl_sel <= 3'd0;
                         end
                            //----------------Added for Channel 1 End-----
                         else begin
                           if (rate_sm_cnt == 6'd10)
                              rate_phy_sts  <= ~rate_change_pend; // wait until channel 1 is finished
                           if (rate_sm_cnt == 6'd11)
                              rate_phy_sts  <= 1'b0;
                           if (rate_sm_cnt == 6'd15) begin
                              rate_sm_cnt <= 'd0;
                              rate_sm  <= RATE_SCI_WR;
                           end
                           else begin
                              rate_sm  <= RATE_CMD_WAIT;
                              rate_sm_cnt <= rate_sm_cnt + 6'd1;
                           end
                         end
                       end
                       else begin
                          rate_sm    <= RATE_CMD_WAIT;
                          rate_sm_cnt   <= 'd0;
                       end
                       end
      RATE_SCI_WR :    begin  //40
                       if (snd_sci_cmd) begin
                         pcie_mode     <= pcie_mode_i;
                         pcie_mode_alt <= 1'b1;
                         rate_change_pend <= CH1_ENABLED;
                         rate_sm       <= RATE_WAIT_WIP;
                       end
                       else
                         rate_sm  <= RATE_SCI_WR;
                       end
      default :        begin
                       rate_sm         <= RATE_IDLE;
                       rate_sm_cnt     <= 'd0;
                       pcie_mode       <= GEN2_6DB;
                       pcie_mode_alt   <= 1'b0;
                       rate_phy_sts    <= 1'b0;
                       rx_serdes_rst_c <= 1'b0;
                       rx_pcs_rst_c    <= 1'b0;
                       cur_rate        <= 1'b0;
                       end
                endcase
      end
end

// =============================================================================
// Enable detect signal for detect statemachine
// =============================================================================

assign enable_det_int = (PowerDown == 2'b10) & TxDetectRx_Loopback & ~PLOL_pclk;
// =============================================================================
//Assert enable det as long as TxDetectRx_Loopback is asserted by FPGA side
//when Serdes is in normal mode and TxElecIdle_ch0/1/2/3 is active.
// =============================================================================
always @(posedge PCLK or negedge RESET_n) begin //PIPE signals : Use hclk  -- RK
  if(!RESET_n) begin
    enable_det_ch0 <= 1'b0;
    enable_det_ch1 <= 1'b0;
    detect_req     <= 1'b0;
    detect_req_del <= 1'b0;
  end
  else begin
    enable_det_ch0 <= (enable_det_int & flip_TxElecIdle_0) ? 1'b1 : 1'b0;
    detect_req     <= enable_det_ch0 | enable_det_ch1;
    detect_req_del <= detect_req; // For Rising Edge
  end
end

// Use Flopped signals to see raising edge to remove any setup issues for data comming from PCS
assign done_0_re  = (done_0_d0 & !done_0_d1);
assign done_1_re  = (done_1_d0 & !done_1_d1);
assign done_all_re = done_all & !done_all_reg;
// =============================================================================
// The Following state machine generates the "ffc_pcie_det_done" and
// "ffc_pcie_ct" as per T-Spec page 81.
// =============================================================================
always @(posedge PCLK or negedge RESET_n) begin  //125 or 250 Mhz
   if (!RESET_n) begin
      detsm_done         <= 0;
      ffc_pcie_ct        <= 0;
      ffc_pcie_det_en_0  <= 0;
      ffc_pcie_det_en_1  <= 0;
      cs_reqdet_sm       <= PCIE_DET_IDLE;
      cnt_enable         <= 1'b0;
      done_0_reg         <= 1'b0;
      done_0_d0          <= 1'b0;
      done_0_d1          <= 1'b0;
      done_1_reg         <= 1'b0;
      done_1_d0          <= 1'b0;
      done_1_d1          <= 1'b0;
      done_all           <= 1'b0;
      done_all_reg       <= 1'b0;
      det_result         <= 2'd0;  // Only for RTL sim
   end
   else begin
     // Sync the async signal from PCS (dont use _reg signals)
     done_0_reg   <= (done_0_reg & detect_req) | ffs_pcie_done_0;
     done_0_d0    <= done_0_reg;
     done_0_d1    <= done_0_d0;
     done_all     <=  done_0_d1;
     done_all_reg <= done_all;

      case(cs_reqdet_sm) //----- Wait for Det Request
      PCIE_DET_IDLE: begin
         ffc_pcie_det_en_0 <= 1'b0;
         ffc_pcie_det_en_1 <= 1'b0;
         ffc_pcie_ct       <= 1'b0;
         cnt_enable        <= 1'b0;
         detsm_done        <= 1'b0;

         // Rising Edge of Det Request
         if (detect_req == 1'b1 && detect_req_del == 1'b0) begin
            cs_reqdet_sm      <= PCIE_DET_EN;
            ffc_pcie_det_en_0 <= 1'b1;
            ffc_pcie_det_en_1 <= 1'b1;
            cnt_enable        <= 1'b1;
         end
         if(PLOL_pclk) begin
           cs_reqdet_sm <= PCIE_DET_IDLE;
         end
      end
      // Wait for 120 Ns
      PCIE_DET_EN: begin
         if (cntdone_en) begin
            cs_reqdet_sm <= PCIE_CT;
            ffc_pcie_ct  <= 1'b1;
         end
         if(PLOL_pclk) begin
           cs_reqdet_sm <= PCIE_DET_IDLE;
         end
      end
      // Wait for 4 Byte Clocks
      PCIE_CT: begin
         if (cntdone_ct) begin
            cs_reqdet_sm <= PCIE_DONE;
            ffc_pcie_ct  <= 1'b0;
         end
`ifdef SIMULATE
         // translate_off
           det_result <= 2'd0;
         // translate_on
`endif
         if(PLOL_pclk) begin
           cs_reqdet_sm <= PCIE_DET_IDLE;
         end
      end
      // Wait for done to go high for all channels
      PCIE_DONE: begin
         cnt_enable  <= 1'b0;

         // ALL DONEs are asserted   (Rising Edge)
         if (done_all_re) begin //pulse
            cs_reqdet_sm   <= PCIE_DET_IDLE;
            detsm_done     <= 1'b1;
            done_0_reg     <= 1'b0;
            done_1_reg     <= 1'b0;
         end

         // DONE makes det_en ZERO individually (DONE Rising Edge)
         if (done_0_re) begin //pulse
            ffc_pcie_det_en_0   <= 1'b0;
`ifdef SIMULATE
                  // translate_off
                  det_result[0] <= 1'b1;
                  // translate_on
`endif
         end
         if(PLOL_pclk) begin
           cs_reqdet_sm <= PCIE_DET_IDLE;
         end
      end
      endcase

   end
end

always @(posedge PCLK or negedge RESET_n) begin  //125 or 250 Mhz
   if(!RESET_n) begin
      detsm_cnt  <= 'd0;
      cntdone_en <= 1'b0;
      cntdone_ct <= 1'b0;
   end
   else begin
      // Detect State machine Counter
      if (cnt_enable)
          detsm_cnt <= detsm_cnt + 1'b1;
      else
          detsm_cnt <= 0;

      // pcie_det_en time
      if (detsm_cnt == ONE_US) // 1 us
          cntdone_en <= 1'b1;
      else
          cntdone_en <= 1'b0;

      // pcie_ct time
      if (detsm_cnt == ONE_US_4BYTE) // 2 clks = 16 ns -> 4 byte clks
          cntdone_ct <= 1'b1;
      else
          cntdone_ct <= 1'b0;

`ifdef SIMULATE
      // translate_off
            // pcie_det_en time -- after 16 clks
            if (detsm_cnt[4:0] == 5'b10000) // 1 us --> 16 clks
                cntdone_en <= 1'b1;
            else
                cntdone_en <= 1'b0;

            // pcie_ct time -- after 19 clks
            if (detsm_cnt[4:0] == 5'b10011) // 2 clks = 16 ns -> 4 byte clks
                cntdone_ct <= 1'b1;
            else
                cntdone_ct <= 1'b0;
      // translate_on
`endif

   end
end

reg [1:0] pol_compliance_pclk;
reg [1:0] wait_PLOL;
reg [1:0] rsl_rx_rdy_sync;
//--------------------------------------------
//-- Sequential block --
//--------------------------------------------
always @(posedge PCLK or negedge RESET_n) begin
  if(~RESET_n) begin
    /*AUTORESET*/
    // Beginning of autoreset for uninitialized flops
    pol_compliance_pclk <= {2{1'b0}};
    rate_phy_sts_pclk <= {1{1'b0}};
    rsl_rx_rdy_sync <= {2{1'b0}};
    wait_PLOL <= {2{1'b0}};
    // End of automatics
  end
  else begin
    pol_compliance_pclk <= {pol_compliance_pclk[0],phy_pol_compliance};
    rsl_rx_rdy_sync <= {rsl_rx_rdy_sync[0],rsl_rx_rdy};
    case(wait_PLOL)
      2'b01   : begin
        if(PLOL_pclk)
          wait_PLOL <= 2'b11;
        else
          wait_PLOL <= 2'b01;
      end
      2'b11   : begin
        if(PLOL_pclk | (~rsl_rx_rdy_sync[1] & ~pol_compliance_pclk[1]))
          wait_PLOL <= 2'b11;
        else
          wait_PLOL <= 2'b10;
      end
      2'b10   : begin
        rate_phy_sts_pclk <= rate_phy_sts_ext_qq;
        if(rate_phy_sts_ext_qq)
          wait_PLOL <= 2'b10;
        else
          wait_PLOL <= 2'b00;
      end
      default : begin
        if(rate_phy_sts_ext_qq)
          wait_PLOL <= 2'b01;
        else
          wait_PLOL <= 2'b00;
      end
    endcase
  end
end //--always @(posedge PCLK or negedge RESET_n)--

//--------------------------------------------
//-- Combinatorial block --
//--------------------------------------------
always @* begin
  if(ctc_pause) begin
    ctc_pause_nxt = rate_phy_sts_pclk ? 1'b0 : ctc_pause;
  end
  else begin
    ctc_pause_nxt = scic_wip;
  end
end //--always @*--

// =============================================================================
// PhyStatus Generation - Det Result and State Changes
// =============================================================================
always @(posedge PCLK or negedge RESET_n) begin  //125 or 250 Mhz
   if(!RESET_n) begin
      PhyStatus         <= 1'b0;
      PowerDown_reg     <= 2'b00;
      PLOL_sync         <= 1'b1;
      PLOL_pclk         <= 1'b1;
      rate_phy_sts_ext_q  <= 1'b0;
      rate_phy_sts_ext_qq <= 1'b0;
      rate_phy_sts_pclk_q <= 1'b0;
      ctc_pause <= 1'b1;
   end
   else begin
      // Sync.
      PLOL_sync <= ffs_plol;
      PLOL_pclk <= PLOL_sync;
      PowerDown_reg <= PowerDown;
      rate_phy_sts_ext_q <= rate_phy_sts_ext;
      rate_phy_sts_ext_qq <= rate_phy_sts_ext_q;
      rate_phy_sts_pclk_q <= rate_phy_sts_pclk;
      ctc_pause <= ctc_pause_nxt;

      if (PLOL_pclk == 1'b0) begin // wait for PLL LOCK
          if ((PowerDown_reg == 2'b00 && PowerDown == 2'b11) ||      //P0  ->P2
              (PowerDown_reg == 2'b00 && PowerDown == 2'b10) ||      //P0  ->P1
              (PowerDown_reg == 2'b00 && PowerDown == 2'b01) ||      //P0  ->P0s
              (PowerDown_reg == 2'b01 && PowerDown == 2'b00) ||      //P0s ->P0
              (PowerDown_reg == 2'b10 && PowerDown == 2'b00) ||      //P1  ->P0
              (PowerDown_reg == 2'b11 && PowerDown == 2'b10) ||      //P2  ->P1
              (detsm_done == 1'b1) ||                                // rx detection done
              (rate_phy_sts_pclk & ~rate_phy_sts_pclk_q))         // rate change done
              //(rate_phy_sts))         // rate change done
              PhyStatus     <= 1'b1;
          else
              PhyStatus     <= 1'b0;
      end
   end
end

assign ffs_rlol     = ffs_rlol_ch0_int;
/*****************************************************
 *  Reset sequencing logic
*****************************************************/
reg core_rstn_1, core_rstn_2;
reg [1:0] rlol_r1, rlol_r2;
reg [9:0] rsl_rdy_cnt;
reg [1:0] RxValid_125;
`ifdef SIMULATE
   localparam RSL_RDY_CNT = 10'd100;
`else
   localparam RSL_RDY_CNT = 10'd1000;
`endif

always @ (posedge PCLK_125 or negedge RESET_n) begin
   if (!RESET_n) begin
      core_rstn_1 <=  1'b0 ;
      core_rstn_2 <=  1'b0;
      rlol_r1 <=  2'b11;
      rlol_r2 <=  2'b11;
      RxValid_125 <= 2'd0;
   end else begin
      core_rstn_1 <= rsl_rx_rdy;
      core_rstn_2 <= core_rstn_1;
      rlol_r1 <=  {ffs_rlol_ch1_int,ffs_rlol_ch0_int};
      rlol_r2 <=  rlol_r1;
      RxValid_125 <= {RxValid_125[0],RxValid_0_in};
   end
end

assign pcie_ip_rstn = core_rstn_2;

assign ffs_rlol_ch0 = rlol_r2[0];
assign ffs_rlol_ch1 = rlol_r2[1];

// masking of RxValid using RxElecIdle causes some of the data to be discarded
// add delay qualifier to RxElecIdle to align with valid data
localparam  RXEI_DLY_CNT = 4'd12;
reg [3:0]   RxElecIdle_0_dly;
reg [3:0]   RxElecIdle_1_dly;
reg         incEn_rsl_rdy_cnt;
always @ (posedge PCLK or negedge RESET_n) begin
   if (!RESET_n) begin
     rsl_rdy_cnt <= 0;
     RxValid_0 <= 1'b0;
     RxElecIdle_0_dly <= 4'd0;
     incEn_rsl_rdy_cnt <= 1'b0;
   end
   else begin
      incEn_rsl_rdy_cnt <= (pcie_ip_rstn &
                             (RxValid_0i & !(RxElecIdle_0 & ~current_pcie_rate) & !ffs_rlol_ch0_int & (RxStatus_0 == 3'b000))
                           );
      if (incEn_rsl_rdy_cnt)
         rsl_rdy_cnt <= rsl_rdy_cnt + {9'd0,(rsl_rdy_cnt != RSL_RDY_CNT)};
      else rsl_rdy_cnt <= 10'd0;

      if(RxElecIdle_0)
        RxElecIdle_0_dly <= RxElecIdle_0_dly + {3'd0,(RxElecIdle_0_dly != RXEI_DLY_CNT)};
      else
        RxElecIdle_0_dly <= 4'd0;

      if (phy_l0 && RxValid_0i && !RxElecIdle_0 && !ffs_rlol_ch0_int)
        RxValid_0 <= RxValid_0i;
      else if (RxValid_0i && rsl_rdy_cnt == RSL_RDY_CNT)
        RxValid_0 <= 1'b1;
      else if (!RxValid_0i ||
               (~current_pcie_rate & RxElecIdle_0 & (RxElecIdle_0_dly == RXEI_DLY_CNT)) ||
               ffs_rlol_ch0_int)
        RxValid_0 <= 1'b0;

   end
end

reg         [1:0]             pol_compliance_sync;
reg                           infer_rx_eidle_async;
reg                           infer_rx_eidle_sync;
always @ (posedge tx_pclk or negedge RESET_n) begin
  if (!RESET_n) begin
    RxElecIdle_0_in <= 1'b1;
    current_pcie_rate_sync <= 2'b11;
    rsl_rx_eidle_0 <= 1'b1;
    infer_rx_eidle_async <= 1'b1;
    infer_rx_eidle_sync <= 1'b1;
    pol_compliance_sync <= 2'd0;
  end
  else begin
    current_pcie_rate_sync <= {current_pcie_rate_sync[0],current_pcie_rate};
    infer_rx_eidle_async <= infer_rx_eidle[0];
    infer_rx_eidle_sync <= infer_rx_eidle_async;
    pol_compliance_sync <= {pol_compliance_sync[0],phy_pol_compliance};
    rsl_rx_eidle_0 <= (current_pcie_rate_sync[1] & ~pol_compliance_sync[1])? 1'b0 : rx_los_low_ch0_s;
    RxElecIdle_0_in <= (current_pcie_rate_sync[1] & ~pol_compliance_sync[1])? infer_rx_eidle_sync : rx_los_low_ch0_s;
  end
end


// =============================================================================
// pipe_top instantiation per channel
// =============================================================================
pcie2_x1_pipe pipe_top_0
(///*AUTOINST*/
 // Inputs
 .RESET_n                               (RESET_n),
 .PCLK                                  (PCLK),
 .clk_250                               (clk_250),
 .ffs_plol                              (ffs_plol),
 .TxDetectRx_Loopback                   (TxDetectRx_Loopback),
 .PowerDown                             (PowerDown[1:0]),
 .Rate_in                               (Rate),
 .TxDeemph_in                           (TxDeemph),
 .TxMargin_in                           (TxMargin[2:0]),
 .TxSwing_in                            (TxSwing),
 .ctc_disable                           (ctc_disable),
 .ctc_pause                             (ctc_pause),
 .TxData_in                             (flip_TxData_0[15:0]),
 .TxDataK_in                            (flip_TxDataK_0[1:0]),
 .TxElecIdle_in                         ({2{flip_TxElecIdle_0}}),
 .RxPolarity_in                         (flip_RxPolarity_0),
 .RxData_in                             (RxData_0_in[15:0]),
 .RxDataK_in                            (RxDataK_0_in[1:0]),
 .RxStatus_in                           (RxStatus_0_in[5:0]),
 .RxValid_in                            (RxValid_0_in),
 .RxElecIdle_in                         (Int_RxElecIdle_ch0),
 .ff_rx_fclk_chx                        (ff_rx_fclk_0),
 .pcie_con_x                            (pcie_con_0),
 .pcs_wait_done                         (pcs_wait_done),
 .start_mask                            (start_mask),
 .detsm_done                            (detsm_done),
 // Outputs
 .RxElecIdle_chx_16                     (RxElecIdle_ch0_8),
 .TxData_out                            (TxData_0_outt[15:0]),
 .TxDataK_out                           (TxDataK_0_outt[1:0]),
 .TxElecIdle_out                        (TxElecIdle_0_out[1:0]),
 .Rate_chx_out                          (),//(Rate_0_out),
 .TxDeemph_chx_out                      (),//(TxDeemph_0_out),
 .TxMargin_chx_out                      (),//(TxMargin_0_out[2:0]),
 .TxSwing_chx_out                       (),//(TxSwing_0_out),
 .RxData_out                            (flip_RxData_0[15:0]),
 .RxDataK_out                           (flip_RxDataK_0[1:0]),
 .RxStatus_out                          (flip_RxStatus_0[2:0]),
 .RxValid_out                           (flip_RxValid_0),
 .RxElecIdle_out                        (flip_RxElecIdle_0),
 .RxPolarity_out                        (RxPolarity_0_out),
 .ffc_fb_loopback                       (ffc_fb_loopback_0));


// =============================================================================
// pcs_top instantiation
// =============================================================================
pcie2_x1_pcs  pcs_top_0
(
 // Inputs
 .sli_rst                               (sli_rst ),           // rest to sync logic of softLOL
 //.sli_cpri_mode                         (3'b000),
 .sli_pcie_mode                         (current_pcie_rate),
 .hdinp                                 (hdinp0),
 .hdinn                                 (hdinn0),
 .rxrefclk                              (rxrefclk),
 .txi_clk                               (ff_tx_f_clk),
  // Tx Channel 0
 .txdata                                (TxData_0_out[15:0]),
 .tx_k                                  (TxDataK_0_out[1:0]),
 .tx_force_disp                         (flip_TxCompliance_0[1:0]),
 .tx_disp_sel                           (2'b0),
 .pci_ei_en                             (TxElecIdle_0_out[1:0]),
 .tx_idle_c                             (1'b0),
 .pcie_det_en_c                         (ffc_pcie_det_en_0),
 .pcie_ct_c                             (ffc_pcie_ct),
 .rx_invert_c                           (RxPolarity_0_out),
 .signal_detect_c                       (1'b1),
 .fb_loopback_c                         (ffc_fb_loopback_0),
 .tx_pwrup_c                            (ffc_pwdnb_0),
 .rx_pwrup_c                            (ffc_pwdnb_0),
  // SCI Input
 .sci_wrdata                            (sci_wrdata[7:0]),
 .sci_addr                              (sci_addr[5:0]),
 .sci_en_dual                           (sci_en_dual0),
 .sci_sel_dual                          (sci_sel_dual0),
 .sci_en                                (sci_en_chnl0),
 .sci_sel                               (sci_sel_chnl0),
 .sci_rd                                (sci_rd),
 .sci_wrn                               (sci_wrn),
 .cyawstn                               (cyawstn),
 .serdes_pdb                            (1'b1),
 .pll_refclki                           (pll_refclki),

 .rsl_disable                           (1'b0),
 .rsl_rst                               (~RESET_n),
 .serdes_rst_dual_c                     (~RESET_n),           // resets all serdes blocks (~RESET_n)
 .rst_dual_c                            (~RESET_n),          // resets all pcs blocks
 .tx_serdes_rst_c                       (~RESET_n),
 .rx_serdes_rst_c                       (~RESET_n),
 .tx_pcs_rst_c                          (rx_pcs_rst_c),
 .rx_pcs_rst_c                          (rx_pcs_rst_c),
 .rsl_rx_eidle                          (rsl_rx_eidle_0),
 // Outputs
 .hdoutp                                (hdoutp0),
 .hdoutn                                (hdoutn0),
 .tx_pclk                               (tx_pclk),
  // Rx Channel 0
 .rx_pclk                               (ff_rx_fclk_0),
 .rxdata                                (RxData_0_int[15:0]),
 .rx_k                                  (RxDataK_0_int[1:0]),
 .rxstatus0                             (RxStatus_0_in0[2:0]),
 .rxstatus1                             (RxStatus_0_in1[2:0]),
 .pcie_done_s                           (ffs_pcie_done_0),
 .pcie_con_s                            (ffs_pcie_con_0),
 .rx_los_low_s                          (rx_los_low_ch0_s),
 .lsm_status_s                          (RxValid_0_in),
 .rx_cdr_lol_s                          (ffs_rlol_ch0_int),
  // SCI Output
 .sci_rddata                            (sci_rddata[7:0]),
 .sci_int                               (sci_int) ,
 .pll_lol                               (ffs_plol),
 .rsl_tx_rdy                            (),
 .rsl_rx_rdy                            (rsl_rx_rdy));


pcie2_x1_sci_ctrl sci_ctrl_inst
(
 // Inputs
 .sci_clk                               (pll_refclki),
 .sci_rstn_async                        (RESET_n),
 .pcie_mode_alt                         (pcie_mode_alt),
 .pcie_mode                             (pcie_mode),
 .pcie_chnl_sel                         (pcie_chnl_sel[2:0]),
 .pcie_dual_sel                         (2'b11),
 .sci_rddata                            (sci_rddata),
 .sci_rate_busy                         (1'b1),
 .infer_rx_eidle                        (infer_rx_eidle[1:0]),
 .current_pcie_rate                     (current_pcie_rate),

 // Outputs
 .cyawstn                               (cyawstn),
 .scic_wip                              (scic_wip),
 .sci_wrn                               (sci_wrn),
 .sci_rd                                (sci_rd),
 .sci_wrdata                            (sci_wrdata),
 .sci_addr                              (sci_addr),
 .sci_sel_dual0                         (sci_sel_dual0),
 .sci_sel_dual1                         (),
 .sci_sel_chnl0                         (sci_sel_chnl0),
 .sci_sel_chnl1                         (sci_sel_chnl1),
 .sci_sel_caux                          (),
 .sci_en_chnl0                          (sci_en_chnl0),
 .sci_en_dual0                          (sci_en_dual0),
 .sci_en_chnl1                          (sci_en_chnl1),
 .sci_en_caux                           ()
 /*AUTOINST*/);


PCSCLKDIV pcs_clkdiv
(
 .CLKI                                  (tx_pclk),
 .RST                                   (~RESET_n),
 .SEL2                                  (pcsclk_div[2]),
 .SEL1                                  (pcsclk_div[1]),
 .SEL0                                  (pcsclk_div[0]),
 .CDIV1                                 (ff_tx_f_clk),
 .CDIVX                                 (PCLK_125));


endmodule //--USERNAME_PHY--


