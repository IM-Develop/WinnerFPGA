module pcie2_x1_ctc (
   input wire           rst_n,         // system reset
   input wire           rec_clk,       // recovered clock
   input wire           pclk,          // system clock

   input wire           ctc_dsb,       // Disable CTC function
   input wire           ctc_pause,     // pause CTC function
   input wire [15:0]    d_in,          // Data in rec_clk
   input wire [1:0]     k_in,          // K in rec_clk
   input wire [5:0]     sts_in,        // status
   input wire           lsyn_in,       // lane sync

   output reg           ctc_skp_ad,    // Skip added
   output reg           ctc_skp_rm,    // Skip removed
   output reg [15:0]    ctc_dout,      // data_in system clock
   output reg [1:0]     ctc_kout,      // K system clock
   output reg [2:0]     ctc_sts_out,   // Status output
   output reg           ctc_lsyn_out,  // Lane Sync
   output reg           ctc_uflow,     // Overflow error
   output wire          ctc_oflow      // Underflow error
);
// =============================================================================
wire [24:0] fifo_dout;
wire        fp_full, fp_emty, full, emty,pat_dec_out, skp_rm_out;

reg  [24:0] wdata_d2,wdata_d1,wdata_d0       /* synthesis syn_srlstyle="registers" */;
reg         wr_en_d0,fp_emty_d2,fp_emty_d1   /* synthesis syn_srlstyle="registers" */;
reg         oflow, pat_dec_in,wr_en,skp_rm_in,rd_en,skp_ad,wait_2rd;
reg         ctc_pause_dr1,ctc_pause_dr0,ctc_pause_dp1,ctc_pause_dp0;
reg         skp_det;
reg  [24:0] fifo_dout_q;
reg         pat_dec_out_q;

// WRITE Logic: (Deletes SKP(1C) When FIFO Partial Full)
always @(posedge rec_clk, negedge rst_n) begin
   if (!rst_n) begin
      {wdata_d2,wdata_d1,wdata_d0} <= 0;
      {pat_dec_in, wr_en, wr_en_d0, skp_rm_in, oflow} <= 5'd0;
      {ctc_pause_dr1,ctc_pause_dr0} <= 0;
      skp_det <= 1'b0;
   end
   else begin
      // pipeline incoming data
      {wdata_d2,wdata_d1,wdata_d0} <= {wdata_d1,wdata_d0,{lsyn_in,sts_in,k_in,d_in}};
      wr_en_d0 <= wr_en;

      // Detect Clock Compensation pattern COM,SKP
      pat_dec_in <= (wdata_d0[17:16]== 2'b11 & wdata_d0[15:0] == {8'h1C,8'h1C}) ? 1'b1 : 1'b0;
      skp_det <= (wdata_d0[17:16]== 2'b11 & wdata_d0[15:0] == {8'hBC,8'h1C}) |
                 (({wdata_d0[16],k_in[1]} == 2'b11) & ({wdata_d0[7:0],d_in[15:8]} == {8'hBC,8'h1C}));

      {ctc_pause_dr1,ctc_pause_dr0} <= {ctc_pause_dr0,ctc_pause};
      // don't write to fifo when partial full and detect start of idle code group
      if (ctc_dsb) wr_en <= 1'b1;
      else wr_en <= ((fp_full & pat_dec_in)||ctc_pause_dr1) ? 1'b0 : wdata_d1[24];
      if (ctc_dsb) skp_rm_in <= 1'b0;
      else skp_rm_in <= (fp_full & skp_det & ~ctc_pause_dr1) ? 1'b1 : 1'b0;

      // overflow error
      oflow <= (full & wr_en) ? 1'b1 : 1'b0;
   end
end

// Read Logic: (Adds SKP(1C) When FIFO Partial Empty)
always @(posedge pclk, negedge rst_n) begin
   if (!rst_n) begin
      {rd_en, skp_ad, wait_2rd, ctc_uflow} <= 0;
      {fp_emty_d1, fp_emty_d2} <= 2'b11;
      {ctc_pause_dp1,ctc_pause_dp0} <= 0;
      fifo_dout_q <= 'd0;
      pat_dec_out_q <= 1'b0;
   end
   else begin
      fp_emty_d1 <= fp_emty;
      fp_emty_d2 <= fp_emty_d1;

      pat_dec_out_q <= pat_dec_out;
      fifo_dout_q <= (pat_dec_out_q)? fifo_dout : fifo_dout_q;

      // Wait for data to be written before start reading
      if (!fp_emty) wait_2rd <= 1'b1;
      else          wait_2rd <= 1'b0;

      {ctc_pause_dp1,ctc_pause_dp0} <= {ctc_pause_dp0,ctc_pause};
      // don't read fifo when partial empty & detect start of pattern, else read fifo
      if(!emty) begin
        if (ctc_dsb) rd_en  <= (wait_2rd ? 1'b1 : rd_en);
        else rd_en  <= ((fp_emty & pat_dec_out)||ctc_pause_dp1) ? 1'b0 : (wait_2rd ? 1'b1 : rd_en) ;
      end
      else rd_en <= 1'b0;

      if (ctc_dsb) skp_ad <= (wait_2rd ? 1'b1 : skp_ad);
      else skp_ad <= (fp_emty & pat_dec_out && !ctc_pause_dp1) ? 1'b1 : (wait_2rd ? 1'b0 : skp_ad) ;

      // underflow error
      ctc_uflow <= (emty & rd_en) ? 1'b1 : 1'b0;
   end
end

// PMI FIFO
//`ifdef SIMULATE
//parameter FIFO_DEPTH     = 64;
//parameter FIFO_HI_THRESH = 48;
//parameter FIFO_LO_THRESH = 16;
//`else
parameter FIFO_DEPTH     = 32;
parameter FIFO_HI_THRESH = 28;
parameter FIFO_LO_THRESH = 4;
//`endif
pmi_fifo_dc #(
   .pmi_data_width_w      (27),
   .pmi_data_width_r      (27),
   .pmi_data_depth_w      (FIFO_DEPTH),
   .pmi_data_depth_r      (FIFO_DEPTH),
   .pmi_full_flag         (FIFO_DEPTH),
   .pmi_empty_flag        (0),
   .pmi_almost_full_flag  (FIFO_HI_THRESH),
   .pmi_almost_empty_flag (FIFO_LO_THRESH),
   .pmi_regmode           ("reg"),
   .pmi_resetmode         ("async"),
   .pmi_family            ("ECP5U"),
   .module_type           ("pmi_fifo_dc"),
   .pmi_implementation    ("LUT"))
   u1_ctc_fifo (
   .Reset       (~rst_n),
   .RPReset     (~rst_n),
   .WrClock     (rec_clk),
   .WrEn        (wr_en),
   .Data        ({skp_rm_in,pat_dec_in,wdata_d2}),
   .RdClock     (pclk),
   .RdEn        (rd_en),
   .Q           ({skp_rm_out,pat_dec_out,fifo_dout}),
   .Empty       (emty),
   .Full        (full),
   .AlmostEmpty (fp_emty),
   .AlmostFull  (fp_full));


// Sync oflow
pcie2_x1_sync1s #(1) u1_sync1s (.rst_n(rst_n), .f_clk(rec_clk), .s_clk(pclk), .in_fclk(oflow), .out_sclk(ctc_oflow));

// Outputs data
always @(posedge pclk, negedge rst_n) begin
   if (!rst_n) {ctc_dout,ctc_kout,ctc_lsyn_out,ctc_skp_ad,ctc_skp_rm,ctc_sts_out} <= 0;
   else begin
      ctc_dout     <= skp_ad ? 16'h1C1C : ctc_skp_ad ? fifo_dout_q[15:0]  : fifo_dout[15:0];
      ctc_kout     <= skp_ad ? 2'b11    : ctc_skp_ad ? fifo_dout_q[17:16] : fifo_dout[17:16];
      ctc_lsyn_out <= fifo_dout[24] & ~emty;
      casex({skp_ad,skp_rm_out})
         2'b10:   ctc_sts_out <= 3'b001;
         2'b01:   ctc_sts_out <= 3'b010;
         2'b11:   ctc_sts_out <= 3'b000;
         default: ctc_sts_out <= 3'b000;
         //default: ctc_status_out <= fifo_dout[23:18];
      endcase
      ctc_skp_ad  <= skp_ad;
      ctc_skp_rm  <= skp_rm_out;
   end
end

endmodule

