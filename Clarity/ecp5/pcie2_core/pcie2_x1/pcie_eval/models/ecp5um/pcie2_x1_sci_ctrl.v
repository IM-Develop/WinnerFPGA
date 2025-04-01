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
// Project          : ECP5 PCIe
// File             : sci_ctrl.v
// Title            : sci_ctrl
// Dependencies     :
// Description      : Controls the User Master Interface of the sysbus to updated
//                    the PCS/SERDES registers through SCI bus
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Author(s)        : whan
// Mod. Date        : DEC 12, 2015
// Changes Made     : Initial Creation
//
// =============================================================================
module pcie2_x1_sci_ctrl

( //--begin_ports--
//----------------------------
// Inputs
//----------------------------
input                         sci_clk        , // User SCI interface clock
input                         sci_rstn_async , // User SCI interface asynchronize reset

input                         pcie_mode_alt  , // PCIe Mode Alternate
input       [1:0]             pcie_mode      , // PCIe Mode
input       [2:0]             pcie_chnl_sel  , // PLL Channel Address
input       [1:0]             pcie_dual_sel  , // PLL Dual Address
input       [7:0]             sci_rddata     ,
input                         sci_rate_busy,
input       [1:0]             infer_rx_eidle,
input                         current_pcie_rate,

//----------------------------
// Outputs
//----------------------------
output reg                    scic_wip   , // SCI Controller Write In Progress

output reg                    sci_rd     ,
output reg                    sci_wrn    , // SCI Write Strobe
output reg  [7:0]             sci_wrdata , // SCI Write Data
output reg  [5:0]             sci_addr   , // SCI Address


output reg                    sci_sel_dual0,
output reg                    sci_sel_dual1,
output reg                    sci_sel_chnl0,
output reg                    sci_sel_chnl1,
output reg                    sci_sel_caux,
output reg                    sci_en_dual0,
output reg                    sci_en_chnl0,
output reg                    sci_en_chnl1,
output reg                    sci_en_caux,
output reg                    cyawstn

); //--end_ports--

   // =============================================================================
   // Local parameter declarations
   // =============================================================================
   localparam SCIC_IDLE = 3'b000;
   localparam SCIC_INIT = 3'b001;
   localparam SCIC_DSET = 3'b011;
   localparam SCIC_WSTB = 3'b111;
   localparam SCIC_DHLD = 3'b101;
   localparam SCIC_LCHK = 3'b110;
   localparam SCIC_DONE = 3'b010;

   localparam WRITE_BYTE_CNT = 3'b110;    // 7-1

   localparam SCIC_DSET_CNT = 3'b010;     // N+1 sci_clk cycles for Setup time
   localparam SCIC_WSTB_CNT = 3'b010;     // N+1 sci_clk cycles for Strobe time
   localparam SCIC_DHLD_CNT = 3'b010;     // N+1 sci_clk_cycles for Hold time
   localparam SCIC_LCHK_CNT = 3'b100;

   // =============================================================================
   // Internal signals
   // =============================================================================
   // Registers
   reg [3:0]     pcie_alt_sense;
   reg [1:0]     pcie_mode_sense;

   reg [2:0]     scic_state, scic_next;
   reg [2:0]     scic_cnt;

   reg [1:0]     sciaddr_dual;
   reg [2:0]     sciaddr_chnl;

   reg [2:0]     timing_cnt;

   reg [7:0]     ctrl_dat_0;
   reg [7:0]     ctrl_dat_1;
   reg [7:0]     ctrl_dat_2;
   reg [7:0]     ctrl_dat_3;
   reg [7:0]     ctrl_dat_4;
   reg [7:0]     ctrl_dat_5;
   reg [7:0]     ctrl_dat_6;

   wire        [5:0]          rate_sci_addr;
   wire                       rate_sci_en_dual0;
   reg                        rate_sci_en_chnl0;
   reg                        rate_sci_en_chnl1;
   wire                       rate_sci_sel_chnl0;
   wire                       rate_sci_sel_chnl1;
   reg         [7:0]          rate_sci_wrdata;
   reg                        rate_sci_wrn;
   wire                       rate_sci_sel_dual0;
   wire                       rate_sci_sel_dual1;
   wire                       rate_sci_sel_caux;
   reg                        rate_sci_en_caux;

   // Wires
   wire          pcie_event;
   wire          cst_init, cst_dset, cst_wstb, cst_dhld, cst_done;
   wire          cst_lchk;
   wire          pcie_mode0, pcie_mode1, pcie_mode2, pcie_mode3;

   wire          timing_cnt_nz, timing_cnt_zero;
   wire          scic_cnt_dec;
   wire          scic_cnt_zero;

   /*AUTOWIRE*/
   wire        [5:0]          rlos_sci_addr;    // From sci_prog_rlos of sci_prog_rlos.v
   wire                       rlos_sci_en_chnl0;// From sci_prog_rlos of sci_prog_rlos.v
   wire                       rlos_sci_en_chnl1;// From sci_prog_rlos of sci_prog_rlos.v
   wire                       rlos_sci_sel_chnl0;// From sci_prog_rlos of sci_prog_rlos.v
   wire                       rlos_sci_sel_chnl1;// From sci_prog_rlos of sci_prog_rlos.v
   wire        [7:0]          rlos_sci_wrdata;  // From sci_prog_rlos of sci_prog_rlos.v
   wire                       rlos_sci_wrn;     // From sci_prog_rlos of sci_prog_rlos.v

   // =============================================================================
   // Input Signal Processing
   // =============================================================================
   always @(posedge sci_clk or negedge sci_rstn_async)
     begin
        if (~sci_rstn_async) pcie_alt_sense <= {3{1'b0}};
        else                 pcie_alt_sense <= {pcie_mode_alt, pcie_alt_sense[2:1]};
     end
   assign pcie_event = (pcie_alt_sense[1] & ~pcie_alt_sense[0]);

   always @(posedge sci_clk or negedge sci_rstn_async)
     begin
        if (~sci_rstn_async) pcie_mode_sense <= 2'b00;
        else                 pcie_mode_sense <= pcie_mode;
     end
   assign pcie_mode0 = (pcie_mode_sense == 2'b00);
   assign pcie_mode1 = (pcie_mode_sense == 2'b01);
   assign pcie_mode2 = (pcie_mode_sense == 2'b10);
   assign pcie_mode3 = (pcie_mode_sense == 2'b11);

   // =============================================================================
   // Next State Logic for SCI Control FSM
   // =============================================================================
   assign timing_cnt_nz   = (|timing_cnt);
   assign timing_cnt_zero = ~timing_cnt_nz;

   wire dset_cnt_set = cst_init | scic_cnt_dec;
   wire wstb_cnt_set = cst_dset & timing_cnt_zero;
   wire dhld_cnt_set = cst_wstb & timing_cnt_zero;
   always @(posedge sci_clk or negedge sci_rstn_async) begin
        if (~sci_rstn_async)    timing_cnt <= 3'b000;
        else if (dset_cnt_set)  timing_cnt <= SCIC_DSET_CNT;
        else if (wstb_cnt_set)  timing_cnt <= SCIC_WSTB_CNT;
        else if (dhld_cnt_set)  timing_cnt <= SCIC_DHLD_CNT;
        else if (timing_cnt_nz) timing_cnt <= timing_cnt - 1'b1;
        else                    timing_cnt <= timing_cnt;
   end

   always @* begin
        case (scic_state)
          SCIC_IDLE : begin
             if (pcie_event)       scic_next = SCIC_INIT;
             else                  scic_next = SCIC_IDLE;
          end
          SCIC_INIT :              scic_next = SCIC_DSET;
          SCIC_DSET : begin
             if (timing_cnt_zero)  scic_next = SCIC_WSTB;
             else                  scic_next = SCIC_DSET;
          end
          SCIC_WSTB : begin
             if (timing_cnt_zero)  scic_next = SCIC_DHLD;
             else                  scic_next = SCIC_WSTB;
          end
          SCIC_DHLD : begin
             if (timing_cnt_zero) begin
                if (scic_cnt_zero) scic_next = SCIC_DONE;
                else               scic_next = SCIC_DSET;
             end
             else                  scic_next = SCIC_DHLD;
          end
          default   :              scic_next = SCIC_IDLE;
        endcase // case (scic_state)
     end // always @ (...

   // =============================================================================
   // Sequencial Logic for SCI Control FSM
   // =============================================================================
   always @(posedge sci_clk or negedge sci_rstn_async)
     if (~sci_rstn_async) scic_state <= SCIC_IDLE;
     else                 scic_state <= scic_next;

   // SCI STROBE
    always @(posedge sci_clk or negedge sci_rstn_async)
      if (~sci_rstn_async) rate_sci_wrn <= 1'b0;
      else                 rate_sci_wrn <= (scic_next == SCIC_WSTB) ? 1'b1 : 1'b0;

   // States Decoding
   assign cst_init = (scic_state == SCIC_INIT);
   assign cst_dset = (scic_state == SCIC_DSET);
   assign cst_wstb = (scic_state == SCIC_WSTB);
   assign cst_dhld = (scic_state == SCIC_DHLD);
   assign cst_lchk = (scic_state == SCIC_LCHK);
   assign cst_done = (scic_state == SCIC_DONE);

   // SCI Write Byte Counter
   assign scic_cnt_dec  = (cst_dhld & timing_cnt_zero & ~scic_cnt_zero);
   always @(posedge sci_clk or negedge sci_rstn_async)
     if (~sci_rstn_async)    scic_cnt <= 3'b111;
     else if (cst_init)      scic_cnt <= WRITE_BYTE_CNT;
     else if (scic_cnt_dec)  scic_cnt <= scic_cnt - 1'b1;
     else if (cst_done)      scic_cnt <= 3'b111;
     else                    scic_cnt <= scic_cnt;

   assign scic_cnt_zero = ~(|scic_cnt);     // scic_cnt == 3'b000

   // SCI Write In Progress
   always @(posedge sci_clk or negedge sci_rstn_async) begin
     if (~sci_rstn_async) begin
       scic_wip <= 1'b0;
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       cyawstn <= {1{1'b0}};
       // End of automatics
     end
     else begin
       scic_wip <= (scic_next != SCIC_IDLE);
       cyawstn <= 1'b0;
     end
   end

   // Write Data
   always @* begin
     case(pcie_mode_sense)
`ifdef DISABLE_5G_TXDEEMPH
       2'b00,2'b01 : begin  // 5G , disabled deemphasis
         ctrl_dat_0 = 8'h01;
         ctrl_dat_1 = 8'h13;
         ctrl_dat_2 = 8'h51;
         ctrl_dat_3 = 8'hF1;
         ctrl_dat_4 = 8'hC3;
         ctrl_dat_5 = 8'h00;
         ctrl_dat_6 = 8'hC0;
       end
`else
       2'b00 : begin  // 5G , -6dB
         ctrl_dat_0 = 8'h21;
         ctrl_dat_1 = 8'h13;
         ctrl_dat_2 = 8'h3C;
         ctrl_dat_3 = 8'hC5;
         ctrl_dat_4 = 8'h80;
         ctrl_dat_5 = 8'hC0;
         ctrl_dat_6 = 8'hC0;
       end
       2'b01 : begin  // 5G , -3.5dB
         ctrl_dat_0 = 8'h21;
         ctrl_dat_1 = 8'h13;
         ctrl_dat_2 = 8'h73;
         ctrl_dat_3 = 8'hC5;
         ctrl_dat_4 = 8'h40;
         ctrl_dat_5 = 8'hC0;
         ctrl_dat_6 = 8'hC0;
       end
`endif
       default : begin // 2.5G , -3.5dB
         ctrl_dat_0 = 8'h13;
         ctrl_dat_1 = 8'h13;
         ctrl_dat_2 = 8'h62;
         ctrl_dat_3 = 8'hC5;
         ctrl_dat_4 = 8'h40;
         ctrl_dat_5 = 8'hC0;
         ctrl_dat_6 = 8'hC2;
       end
     endcase
   end //--always @*--

   always @* begin
     case (scic_cnt)
       3'b000  : rate_sci_wrdata = ctrl_dat_0;
       3'b001  : rate_sci_wrdata = ctrl_dat_1;
       3'b010  : rate_sci_wrdata = ctrl_dat_2;
       3'b011  : rate_sci_wrdata = ctrl_dat_3;
       3'b100  : rate_sci_wrdata = ctrl_dat_4;
       3'b101  : rate_sci_wrdata = ctrl_dat_5;
       3'b110  : rate_sci_wrdata = ctrl_dat_6;
       default : rate_sci_wrdata = {8{1'b0}};
     endcase // case (scic_cnt)
   end // always @ (...

   // Write Address

   // assign sciaddr = {sciaddr_dual, sciaddr_chnl, 2'b01, 1'b0, scic_cnt};
   assign rate_sci_addr = {2'b01, 1'b0, scic_cnt};

   // Channel Enable and Select
   always @(posedge sci_clk or negedge sci_rstn_async)
     begin
        if (~sci_rstn_async) sciaddr_dual <= {2{1'b1}};
        else if (pcie_event) sciaddr_dual <= pcie_dual_sel;
     end
   assign rate_sci_sel_dual0 = (sciaddr_dual == 2'b00);
   assign rate_sci_sel_dual1 = (sciaddr_dual == 2'b01);
   assign rate_sci_en_dual0  = 1'b0;

   always @(posedge sci_clk or negedge sci_rstn_async)
     begin
        if (~sci_rstn_async) sciaddr_chnl <= {3{1'b0}};
        else if (pcie_event) sciaddr_chnl <= pcie_chnl_sel;
     end
   assign rate_sci_sel_chnl0 = (sciaddr_chnl == 3'b000);
   assign rate_sci_sel_chnl1 = (sciaddr_chnl == 3'b001);
   assign rate_sci_sel_caux  = (sciaddr_chnl == 3'b100);

   always @(posedge sci_clk or negedge sci_rstn_async)
     if (~sci_rstn_async) rate_sci_en_chnl0 <= 1'b0;
     else if (cst_init)   rate_sci_en_chnl0 <= rate_sci_sel_chnl0;
     else if (cst_done)   rate_sci_en_chnl0 <= 1'b0;

   always @(posedge sci_clk or negedge sci_rstn_async)
     if (~sci_rstn_async) rate_sci_en_chnl1 <= 1'b0;
     else if (cst_init  ) rate_sci_en_chnl1 <= rate_sci_sel_chnl1;
     else if (cst_done)   rate_sci_en_chnl1 <= 1'b0;

   always @(posedge sci_clk or negedge sci_rstn_async)
     if (~sci_rstn_async) rate_sci_en_caux <= 1'b0;
     else if (cst_init)   rate_sci_en_caux <= rate_sci_sel_caux;
     else if (cst_done)   rate_sci_en_caux <= 1'b0;

// SCI STROBE
//--------------------------------------------
//-- Sequential block --
//--------------------------------------------
always @(posedge sci_clk or negedge sci_rstn_async) begin
  if(~sci_rstn_async) begin
    /*AUTORESET*/
    // Beginning of autoreset for uninitialized flops
    sci_addr <= {6{1'b0}};
    sci_en_caux <= {1{1'b0}};
    sci_en_chnl0 <= {1{1'b0}};
    sci_en_chnl1 <= {1{1'b0}};
    sci_en_dual0 <= {1{1'b0}};
    sci_rd <= {1{1'b0}};
    sci_sel_caux <= {1{1'b0}};
    sci_sel_chnl0 <= {1{1'b0}};
    sci_sel_chnl1 <= {1{1'b0}};
    sci_sel_dual0 <= {1{1'b0}};
    sci_sel_dual1 <= {1{1'b0}};
    sci_wrdata <= {8{1'b0}};
    sci_wrn <= {1{1'b0}};
    // End of automatics
  end
  else begin
    if(sci_rate_busy) begin
      sci_rd <= 1'b0;
      sci_wrn <= rate_sci_wrn;
      sci_addr <= rate_sci_addr;
      sci_wrdata <= rate_sci_wrdata;
      sci_en_dual0 <= rate_sci_en_dual0;
      sci_en_chnl0 <= rate_sci_en_chnl0;
      sci_en_chnl1 <= rate_sci_en_chnl1;
      sci_sel_chnl0 <= rate_sci_sel_chnl0;
      sci_sel_chnl1 <= rate_sci_sel_chnl1;

      sci_sel_dual0 <= rate_sci_sel_dual0;
      sci_sel_dual1 <= rate_sci_sel_dual1;
      sci_en_caux <= rate_sci_en_caux;
      sci_sel_caux <= rate_sci_sel_caux;
    end
    else begin
      sci_wrn <= rlos_sci_wrn;
      sci_addr <= rlos_sci_addr;
      sci_wrdata <= rlos_sci_wrdata;
      sci_en_chnl0 <= rlos_sci_en_chnl0;
      sci_en_chnl1 <= rlos_sci_en_chnl1;
      sci_sel_chnl0 <= rlos_sci_sel_chnl0;
      sci_sel_chnl1 <= rlos_sci_sel_chnl1;
      sci_en_dual0  <= 1'b0;
      sci_sel_dual0 <= 1'b0;
      sci_sel_dual1 <= 1'b0;
      sci_en_caux <= 1'b0;
      sci_sel_caux <= 1'b0;
    end
  end
end //--always @(posedge sci_clk or negedge sci_rstn_async)--

assign rlos_sci_wrn         = 'd0;
assign rlos_sci_wrdata      = 'd0;
assign rlos_sci_addr        = 'd0;
assign rlos_sci_sel_chnl0   = 'd0;
assign rlos_sci_sel_chnl1   = 'd0;
assign rlos_sci_en_chnl0    = 'd0;
assign rlos_sci_en_chnl1    = 'd0;

endmodule // sci_ctrl


// =============================================================================
