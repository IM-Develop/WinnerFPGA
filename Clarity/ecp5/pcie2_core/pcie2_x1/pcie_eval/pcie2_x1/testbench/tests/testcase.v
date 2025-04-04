// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2001 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                      web  : http://www.latticesemi.com/
// U.S.A                                    email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS
// Project          : pci_exp
// File             : testcase.v
// Title            : Loob Back Test using SERDES/PCSC
// Dependencies     :
// Description      : The following test checks if the interface between core and SERDES/PCS
//                    are OK. As connection is looped back on serial lines, the LTSSM
//                    will not move from congig state. This ensures TS orderset flow
//                    and then switching to "no_training" will make LTSSM to go to LO
//                    directly. Then TLP trafic is tested.
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Mod. Date        : Sep 22, 2004
// Changes Made     : Initial Creation
//
// Version          : 2.0
// Mod. Date        : May 2, 2006
// Changes Made     : Modified for ECP3 PCIe x1
// =============================================================================

parameter       TCNT = 'd25 ;

reg           test_complete;
reg [9:0]     stlp_size;
reg [9:0]     stlp_size_r;
reg [9:0]     rtlp_size;
reg [9:0]     rtlp_size_r;
reg [31:0]    seed;
reg [31:0]    rand_data[0:1023];
reg [31:0]    tlps_count;
reg           test_flag1;

integer       sp ;
integer       rp ;
integer       tp ;
integer       xp ;

always @* begin
  if(u1_top.u1_pcs_pipe.pcs_top_0.sll_inst.rpcie_mode == 1)
    force u1_top.u1_pcs_pipe.pcs_top_0.sll_inst.rcount_tc = 250;
  else
    force u1_top.u1_pcs_pipe.pcs_top_0.sll_inst.rcount_tc = 125;
end

initial begin
  `ifdef SOFT_LOL_ENABLE
   force u1_top.u1_pcs_pipe.wait_PLOL = 2'b10;
  `endif

  `ifdef Channel_1
   force u1_top.u1_pcs_pipe.pcs_top_0.rx_cdr_lol_ch0_s = 1'b0;
   force u1_top.u1_pcs_pipe.pcs_top_0.rx_cdr_lol_ch1_s = 1'b0;
  `else
   force u1_top.u1_pcs_pipe.pcs_top_0.rx_cdr_lol_s = 1'b0;
  `endif

   // Test Started
   $display("---INFO  : Eval Test STARTED at Time %0t", $time);
   RST_DUT;

   force u1_top.u1_pcs_pipe.RxValid_0 = u1_top.u1_pcs_pipe.RxValid_0i;
   `ifdef Channel_1
   force u1_top.u1_pcs_pipe.RxValid_1 = u1_top.u1_pcs_pipe.RxValid_1i;
   `endif
//----------- for RTL sim ----------------
   wait (u1_top.u1_dut.txp_detect_rx_lb); //
   $display("---INFO TESTCASE : Forcing Detect Result at Time %0t", $time);
   force u1_top.u1_pcs_pipe.ffs_pcie_con_0  = 1'b1;   // Receiver detected
   `ifdef Channel_1
   force u1_top.u1_pcs_pipe.ffs_pcie_con_1  = 1'b1;   // Receiver detected
   `endif

   repeat (25) @ (posedge sys_clk_125);
   $display("---INFO TESTCASE : Waiting for rxp_valid at Time %0t", $time);
   wait (u1_top.u1_pcs_pipe.RxValid_0); //wait for lane sync
   `ifdef Channel_1
   wait (u1_top.u1_pcs_pipe.RxValid_1); //wait for lane sync
   `endif

   $display("---INFO TESTCASE : Waiting for LTSSM to go to CFG at Time %0t", $time);
   wait ( u1_top.u1_dut.phy_ltssm_state == 4'd2);  // wait for DUT Config state

 `ifdef Channel_1
   $display("---INFO TESTCASE : Forcing rate change to Gen2 at time %0t", $time);
   force u1_top.u1_dut.u1_dut.u1_dut.u1_phy.u1_ltssm.rate_5g  = 1'b1;
   wait ( u1_top.u1_dut.phy_status == 1'b1);

   $display("---INFO TESTCASE : Waiting for LTSSM to go to Detect at Time %0t", $time);
   wait ( u1_top.u1_dut.phy_ltssm_state == 4'd0);  // wait for DUT Detect state
   $display("---INFO TESTCASE : Waiting for LTSSM to go to CFG at Time %0t", $time);
   wait ( u1_top.u1_dut.phy_ltssm_state == 4'd2);  // wait for DUT Config state
   repeat (100) @ (posedge sys_clk_125);
   $display("---INFO TESTCASE : Forcing MCA to realign data at Time %0t", $time);
   force u1_top.u1_dut.u1_dut.u1_dut.u1_phy.ltssm_config_ln  = 2'b11;
   force u1_top.u1_dut.u1_dut.u1_dut.u1_phy.phy_realign_req  = 1'b1;
   wait(u1_top.u1_dut.u1_dut.u1_dut.u1_phy.mca_align_done == 1'b1);
   repeat (1) @ (posedge sys_clk_125);
   force u1_top.u1_dut.u1_dut.u1_dut.u1_phy.phy_realign_req  = 1'b0;
   $display("---INFO TESTCASE : MCA realign done at Time %0t", $time);

   repeat (100) @ (posedge sys_clk_125);
 `else
   repeat (200) @ (posedge sys_clk_125);
 `endif
//--------------------------------------

   $display("---INFO TESTCASE : Forcing LTSSM to L0 at Time %0t", $time);
   `ifdef WISHBONE
      wb_write (13'h100C, 32'h0000_0001) ; // Set no_pcie_train
   `else
      force no_pcie_train = 1'b1;
   `endif

   repeat (10) @ (posedge sys_clk_125);
   wait (dl_up);
   $display("---INFO TESTCASE : FCI is done, dl_up asserted at Time %0t", $time);
//--------------------------------------
`ifdef Channel_1
   wait (u1_top.u1_dut.dl_active);
   $display("---INFO TESTCASE : dl_active asserted at Time %0t", $time);
`else
   repeat (200) @ (posedge sys_clk_125);
   $display("---INFO TESTCASE : Forcing rate change to Gen2 at time %0t", $time);
   force u1_top.u1_dut.u1_dut.u1_dut.u1_phy.u1_ltssm.rate_5g  = 1'b1;
   wait ( u1_top.u1_dut.phy_status == 1'b1);
   $display("---INFO TESTCASE : Rate change to GEN2 DONE at time %0t", $time);
   repeat (4000) @ (posedge sys_clk_125);
`endif
   wait ( u1_top.u1_dut.phy_ltssm_state == 4'd3);  // wait for DUT L0 in Gen2
   $display("---INFO TESTCASE : LTSSM reached L0 in GEN2 mode at time %0t", $time);

//--------------------------------------
   fork
      test_complete = 1'b0 ;
      begin
         seed = 'd9;
         // Send Packet from TX user Interface
         for (sp = 0 ; sp < TCNT; sp = sp+1) begin
            repeat (1) @ (posedge tb_sys_clk);
            stlp_size_r = {$random(seed)} % 31;
            stlp_size = (stlp_size_r <= 2) ? 3 : stlp_size_r;
            rand_data[sp] = stlp_size ;
            tbtx_mem_wr(3'd0, 32'hFFFF_FF80, stlp_size, 1'b0, 10'd0, 1'b0);
            $display("---INFO : TLP No. %0d scheduled from TBTX at Time %0t", sp, $time);
         end
      end
      begin
         // Check Packet from RX user Interface
         for (rp = 0 ; rp < TCNT; rp = rp+1) begin
            repeat (1) @ (posedge tb_sys_clk);
            rtlp_size = rand_data[rp];
            tbrx_mem_wr(3'd0, 32'hFFFF_FF80, rtlp_size, 1'b0, 4'd0);
         end
      end
      begin
         tlps_count = 'd0;
         for (tp = 0 ; tp < TCNT; tp = tp+1) begin
            wait (rx_end) ;
            $display("---INFO : TLP No. %0d received at TBRX at Time %0t", tp, $time);
            tlps_count = tlps_count + 1;
            repeat (2) @ (posedge tb_sys_clk);
         end
      end

      // Wait until packet is received by RX TB
      begin
         wait (|tbrx_cmd_prsnt == 1'b1) ;
         wait (|tbrx_cmd_prsnt == 1'b0) ;
         test_complete = 1'b1 ;
      end
   join
end

always @(posedge tb_sys_clk) begin
   if (tlps_count%30 == 0) begin
       u_tbrx[0].ph_buf_status   <= 1'b1;
       u_tbrx[0].pd_buf_status   <= 1'b1;
       u_tbrx[0].nph_buf_status  <= 1'b1;
       u_tbrx[0].npd_buf_status  <= 1'b1;
   end
   else if (tlps_count%30 == 2) begin
       u_tbrx[0].ph_buf_status   <= 1'b0;
       u_tbrx[0].pd_buf_status   <= 1'b0;
       u_tbrx[0].nph_buf_status  <= 1'b0;
       u_tbrx[0].npd_buf_status  <= 1'b0;
   end
end


always @(posedge tb_sys_clk) begin
   if (rx_st) begin
       u_tbrx[0].ph_processed   <= 1'b1;
       u_tbrx[0].pd_processed   <= 1'b1;
       u_tbrx[0].nph_processed  <= 1'b1;
       u_tbrx[0].npd_processed  <= 1'b1;
   end
   else if (rx_end) begin
       u_tbrx[0].ph_processed   <= 1'b0;
       u_tbrx[0].pd_processed   <= 1'b0;
       u_tbrx[0].nph_processed  <= 1'b0;
       u_tbrx[0].npd_processed  <= 1'b0;
   end
end

always @(error or test_complete)
begin
    // Test Completed
    if ((error == 1'b0) && (test_complete == 1'b1) && (tlps_count == TCNT)) begin
      repeat (10) @ (posedge tb_sys_clk);
      $display("---INFO  : Eval Test PASSED at Time %t", $time);
      $finish;
    end

    if (error == 1'b1) begin
      repeat (10) @ (posedge tb_sys_clk);
      $display("---ERROR : Eval Test FAILED at Time %t", $time);
      $finish;
    end
end
// =============================================================================
