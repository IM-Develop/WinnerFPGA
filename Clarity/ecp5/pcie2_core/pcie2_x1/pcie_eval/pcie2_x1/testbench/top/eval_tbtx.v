// $Id: pci_exp_x4_v0.0/pcie_x4_eval/username/testbench/top/eval_tbtx.v 1.1 2007/09/07 14:34:45PDT uananthi Exp  $
// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2002 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS
// Project          : PCI Express 4X
// File             : tbtx.v
// Title            : TX User interface
// Dependencies     : pci_exp_params.v
// Description      : This module implements the the PER VC user side TX interface
// =============================================================================
//                        REVISION HISTORY
// Version          : 1.0
// Author(s)        : Gopi
// Mod. Date        : April 13, 2004
// Changes Made     : Initial Creation
//
// =============================================================================

module tbtx
   (
    //------- Inputs
    sys_clk,           // System clock
    rst_n,             // Active low system reset

    tx_tc,             // TC

    //Credit Available Registers
    tx_ca_ph,         // Available credit for Posted Type Headers
    tx_ca_pd,         // For Posted - Data
    tx_ca_nph,        // For Non-posted - Header
    tx_ca_npd,        // For Non-posted - Data
    tx_ca_cplh,       // For Completion - Header
    tx_ca_cpld,       // For Completion - Data

    tx_rdy,           // Indicating the TX (Core) is ready to take the TLP
    tx_val,           // Val signal toggles during x2/x1 downgrade
    tx_ca_p_recheck,  // Only for VC0
    tx_ca_cpl_recheck,// Only for VC0

    //------- Outputs
    tx_req,            // Request to transfer TLP to Core
    tx_data,           // TLP Data
    tx_st,             // SOP
    tx_end,            // EOP
    tx_nlfy,           // Nullify this pkt
    tx_dwen            // Dword enable

    );

// =============================================================================
// =============================================================================
parameter  R         = 1'b0;
parameter  HEAD_4DW  = 1'b1;
parameter  HEAD_3DW  = 1'b0;

parameter  MEM_TYPE  = 5'b0_0000;
parameter  IO_TYPE   = 5'b0_0010;
parameter  CFG0_TYPE = 5'b0_0100;
parameter  CFG1_TYPE = 5'b0_0101;
parameter  MSG_TYPE  = 5'b1_0xxx;
//parameter  MSG_TYPE  = 5'b1_0000;  //Chosen "Routed to Root Complex"
parameter  CPL_TYPE  = 5'b0_1010;

parameter MEM_RD     = 4'b0000;
parameter MEM_WR     = 4'b0001;
parameter IO_RD      = 4'b0010;
parameter IO_WR      = 4'b0011;
parameter CFG_RD     = 4'b0100;
parameter CFG_WR     = 4'b0101;
parameter MSG        = 4'b0110;
parameter MSG_D      = 4'b0111;
parameter CPL        = 4'b1000;
parameter CPL_D      = 4'b1001;

parameter  TBTX_IDLE    = 2'b00;
parameter  TBTX_REQ     = 2'b01;
parameter  TBTX_WAIT    = 2'b10;

parameter  TBTX_SOP     = 2'b00;
parameter  TBTX_HEADER  = 2'b01;
parameter  TBTX_DATA    = 2'b10;

// =============================================================================
// Define all inputs / outputs
// =============================================================================
//---------Inputs------------
input                       sys_clk;
input                       rst_n;

input  [2:0]                tx_tc;

input  [8:0]                tx_ca_ph;
input  [12:0]               tx_ca_pd;
input  [8:0]                tx_ca_nph;
input  [12:0]               tx_ca_npd;
input  [8:0]                tx_ca_cplh;
input  [12:0]               tx_ca_cpld;

input                       tx_rdy;
input                       tx_val;
input                       tx_ca_p_recheck;
input                       tx_ca_cpl_recheck;

//---------Outputs------------
output                      tx_req;
output[63:0]                tx_data;
output                      tx_st;
output                      tx_end;
output                      tx_nlfy;
output                      tx_dwen;

// =============================================================================
// Define Wire & Registers
// =============================================================================
//---- Registers
reg                         tx_req;
reg   [63:0]                tx_data;
reg                         tx_st;
reg                         tx_end;
reg                         tx_nlfy;
reg                         tx_dwen;

reg  [67:0]                 TBTX_REQ_FIFO [255:0];
reg  [7:0]                  service_cnt;
reg  [7:0]                  req_cnt;

reg                         pkt_inprogress;
reg  [1:0]                  tbtx_req_state;

reg  [1:0]                  tbtx_pkt_state;
reg                         TBTX_Error;
reg  [10:0]                 di, dj;
reg  [9:0]                  len_cnt;
reg  [15:0]                 pkt_id;   //2 x service_cnt width

reg  [31:0]                 H1_ms_data;
reg  [31:0]                 H1_ls_data;
reg  [31:0]                 H2_ms_data;
reg  [31:0]                 H2_ls_data;

reg                         credit_chk_ok;

reg  [1:0]                  stored_fmt;
reg  [10:0]                 stored_len;
reg                         stored_nul;
reg  [9:0]                  stored_nul_len;

reg  [31:0]                 data0, data1;
reg  [31:0]                 D [9:0];   //For User Manual Data

reg                         tx_st_del1;
reg                         tx_st_del2;
//---- Wires
wire  [67:0]                req_info;
wire                        req_cfg;
wire [7:0]                  req_be;
wire                        req_hdr;
wire                        req_td;
wire                        req_ep;
wire [9:0]                  req_len;
wire [31:0]                 req_addr;
wire [3:0]                  req_type;

wire                        req_nul;
wire [9:0]                  req_nul_len;

wire [11:0]                 req_bytecnt;
wire [6:0]                  req_loweraddr;
wire [2:0]                  req_status;

wire                        inifinite_credits;
wire                        credit_rchk;

// =============================================================================
// TD : Set indicates Presence of TLP Digest (ECRC)
// EP : Set indicates data Poisoned
// First DW BE :
// Last  DW BE :
// REQUESTER ID : 16 bits
// Tag  :8 bits
// Attr : 2 bits {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
// =============================================================================
reg [31:0]  TBTX_UPPER32_ADDR;
reg [15:0]  TBTX_REQ_ID;
reg [15:0]  TBTX_CPL_ID;
reg [7:0]   TBTX_TAG;
reg         TBTX_TD;
reg         TBTX_EP;
reg         TBTX_BCM;  //For CPL Header
reg [2:0]   TBTX_MSG_ROUTE;
reg [7:0]   TBTX_MSG_CODE;
reg [63:0]  TBTX_MSG_TYPE;

reg  [3:0]  First_DW_BE;
reg  [3:0]  Last_DW_BE;

reg         TBTX_MANUAL_DATA;
reg         TBTX_FIXED_PATTERN;
// =============================================================================
// TX Request Fifo
// =============================================================================
initial begin

  TBTX_UPPER32_ADDR = 32'h0000_0000;
  TBTX_REQ_ID       = 16'hAAAA;
  TBTX_CPL_ID       = 16'hBBBB;
  TBTX_TAG          = 8'h00;
  TBTX_TD           = 1'b0;
  TBTX_EP           = 1'b0;
  TBTX_BCM          = 1'b0;

  TBTX_MSG_ROUTE    = 3'b000; // Refer PNo 63
  TBTX_MSG_CODE     = 8'h00;  //Refer Page No 64-69
  TBTX_MSG_TYPE     = 64'h0000_0000_0000_0000;

  First_DW_BE       = 4'b1111;
  Last_DW_BE        = 4'b1111;

  D[0] = 0; D[1] = 0; D[2] = 0; D[3] = 0; D[4] = 0;
  D[5] = 0; D[6] = 0; D[7] = 0; D[8] = 0; D[9] = 0;
end

initial begin
   req_cnt = 0;
end

// =============================================================================
// 10 + 1 + 4 + 32 + 10 + 1 + 1 + 1 + 4 + 4  = 68
// NULL_len + NULLIFY + kind + addr + len + 3dw/4dw + TD + EP + FirstDwBE + LastDwBE
// =============================================================================
assign req_info = TBTX_REQ_FIFO[service_cnt];
assign req_cfg  = req_info[0];  //For Config  (Config0 or Config1)
assign req_be   = req_info[7:0];
assign req_ep   = req_info[8];
assign req_td   = req_info[9];
assign req_hdr  = req_info[10];

assign req_len  = req_info[20:11];   // Length of Pkt
assign req_addr = req_info[52:21];   // Addr
assign req_type = req_info[56:53];   // Type of pkt

assign req_nul  = req_info[57];         //Nullify
assign req_nul_len = req_info[67:58];   //Nullify Length

assign req_bytecnt   = req_addr[31:20];
assign req_loweraddr = req_addr[19:13];
assign req_status    = req_addr[12:10];

// =============================================================================
// Request Generation
// tx_req is generated when there is a request in TBTX_REQ_FIFO and when there
// are sufficient credits are available.
// =============================================================================
assign inifinite_credits = tx_ca_ph[8] & tx_ca_nph[8] & tx_ca_cplh[8] & tx_ca_pd[12] & tx_ca_npd[12] & tx_ca_cpld[12];

assign credit_rchk = ((tx_ca_p_recheck | tx_ca_cpl_recheck) & (tx_tc == 3'b000)); //Only for VC0
always @(posedge sys_clk or negedge rst_n) begin
   if (!rst_n)  begin
      pkt_inprogress  <= 1'b0;
      tbtx_req_state  <= TBTX_IDLE;
      tx_req          <= 1'b0;
      service_cnt     <= 0;
      tx_st_del1      <= 1'b0;
      tx_st_del2      <= 1'b0;
   end
   else if( tx_val) begin
      tx_st_del1  <= tx_st;
      tx_st_del2  <= tx_st_del1;

      if(tx_st) begin
         pkt_inprogress <= 1'b1;
      end
      else if(tx_end || tx_nlfy) begin
         pkt_inprogress <= 1'b0;
      end

      //For getting continous requests from TBTX when pkts are pending in FIFO
      // INIFINTE CREDITS for all types
      if(inifinite_credits) begin  //-----------------------------------
         if((!tx_st && (req_cnt != service_cnt)) || (tx_st && (req_cnt != (service_cnt + 1)))) begin
            tx_req   <= 1'b1;
         end
         else begin
            tx_req   <= 1'b0;
         end
         if(tx_st)
            service_cnt   <= service_cnt + 1;
      end
      else begin  //For Non-inifinite
      // NON-INIFINTE CREDITS
      //Waits fro credit update from DUT and checks CREDIT avaialable
         if(tx_st)
            tx_req  <= 1'b0;

         case(tbtx_req_state) //-----------------------------------
            TBTX_IDLE : begin
               if(req_cnt != service_cnt) begin
                  CREDIT_CHECK;
                  if(credit_chk_ok) begin
                     tbtx_req_state  <= TBTX_REQ;
                     tx_req          <= 1'b1;
                  end
               end
            end
            TBTX_REQ : begin  //Wait for Ready from DUT
               if(credit_rchk)
                  CREDIT_CHECK;

               if(credit_rchk && !credit_chk_ok) begin
                  tbtx_req_state  <= TBTX_IDLE;
                  tx_req          <= 1'b0;   //De-assert the req.
               end
               else if(tx_rdy && !pkt_inprogress) begin
                  tbtx_req_state  <= TBTX_WAIT;
               end
            end
            TBTX_WAIT : begin   //Start Pkt here
               //if(tx_st) begin  // ???? Change it according to the delay DUT takes to Update Credits
               //if(tx_st_del1) begin  // ???? Change it according to the delay DUT takes to Update Credits
               if(tx_st_del2) begin  // ???? Change it according to the delay DUT takes to Update Credits
                  tbtx_req_state  <= TBTX_IDLE;
                  service_cnt     <= service_cnt + 1;
               end
            end
         endcase //---------------------------------------------------
       end  //For Non-inifinite
   end
end

// =============================================================================
// Checking the available credit for the req
// =============================================================================
task CREDIT_CHECK;
reg   ph,nph,cplh,  pd,npd,cpld;
reg   h_ok, d_ok;
reg   [11:0]  tmp_len;
begin
   {ph, nph, cplh, pd, npd, cpld} = 0;
   //Dividing by 4  (Conversion from DW to 4DW)
   //1 Credit = 4 DW  (length is in DWs)
   tmp_len = {2'b00,req_len};

    case (req_type)
       MEM_RD : nph = 1;
       MEM_WR : ph  = 1;
       CFG_RD : nph = 1;
       CFG_WR : nph = 1;
       IO_RD  : nph = 1;
       IO_WR  : nph = 1;
       MSG    : ph  = 1;
       MSG_D  : ph  = 1;
       CPL    : cplh = 1;
       CPL_D  : cplh = 1;
    endcase

    case (req_type)
       MEM_WR : pd  = 1;
       CFG_WR : npd = 1;
       IO_WR  : npd = 1;
       MSG_D  : pd  = 1;
       CPL_D  : cpld = 1;
    endcase

    case(1'b1)
       ph   : h_ok = (tx_ca_ph != 0) ? 1'b1 : 1'b0;
       nph  : h_ok = (tx_ca_nph != 0) ? 1'b1 : 1'b0;
       cplh : h_ok = (tx_ca_cplh != 0) ? 1'b1 : 1'b0;
    endcase

    if(pd || npd || cpld)
       case(1'b1)
          pd   : d_ok = ((tx_ca_pd[12]) || ((tx_ca_pd[11:0]*4) >= tmp_len)) ? 1'b1 : 1'b0;
          npd  : d_ok = ((tx_ca_npd*4) != 0) ? 1'b1 : 1'b0;
          cpld : d_ok = ((tx_ca_cpld[12]) || ((tx_ca_cpld[11:0]*4) >= tmp_len)) ? 1'b1 : 1'b0;
       endcase
    else
       d_ok = 1;

    credit_chk_ok = h_ok & d_ok;
end
endtask

// =============================================================================
// Pkt transmission based on tx_rdy signal.
// SOP comes 1 clk after tx_rdy
// =============================================================================
always @(posedge sys_clk or negedge rst_n) begin
   if (!rst_n)  begin
      tbtx_pkt_state  <= TBTX_SOP;
      tx_st           <= 1'b0;
      tx_end          <= 1'b0;
      tx_nlfy         <= 1'b0;
      tx_dwen         <= 1'b0;
      tx_data         <= 64'd0;
      len_cnt         <= 0;
      di               = 0;
      dj               = 0;
      pkt_id          <= 0;
      TBTX_Error       = 1'b0;
   end
   else if (tx_val) begin
      //----------- tx_rdy timing check -----------------
      if(tbtx_pkt_state == TBTX_SOP) begin
         if(tx_rdy && tx_end) begin
            $display ("TBTX-TC%d: **** ERROR **** : tx_rdy is NOT De-asserted before tx_end at time %0t", tx_tc, $time);
            TBTX_Error = 1'b1;
         end
         if(tx_rdy && !tx_req && !tx_nlfy) begin  //recheck case may give error ???
            $display ("TBTX-TC%d: **** ERROR **** : Grant without Req at time %0t", tx_tc, $time);
            TBTX_Error = 1'b1;
         end
      end
      else begin
         if(!tx_rdy) begin
            $display ("TBTX-TC%d: **** ERROR **** : tx_rdy is De-asserted before PKT ends at time %0t", tx_tc, $time);
            TBTX_Error = 1'b1;
         end
      end

      tx_st     <= 1'b0;
      tx_end    <= 1'b0;
      tx_nlfy   <= 1'b0;
      tx_dwen   <= 1'b0;   //Valid only during tx_end
      //----------- Sending Pkt -----------
      case(tbtx_pkt_state)
         TBTX_SOP: begin
            //if(tx_rdy && !tx_nlfy) begin
            //If credits are not sufficient tx_req is removed after credit_recheck
            if(tx_rdy && !tx_nlfy && (!credit_rchk && tx_req)) begin
               tx_st           <= 1'b1;
               tbtx_pkt_state  <= TBTX_HEADER;
               FORM_HEADER;
               tx_data         <= {H1_ms_data, H1_ls_data};
               pkt_id          <= {service_cnt, service_cnt};
            end
         end
         TBTX_HEADER: begin
            //a) If no data   : Send EOP
            //b) 3 DW, 1 data : Send EOP
            case(stored_fmt)
               2'b00 : begin  //3DW No Data
                  tx_end          <= 1'b1;
                  tx_dwen         <= 1'b1;
                  tx_data         <= {H2_ms_data, H2_ls_data};
                  tbtx_pkt_state  <= TBTX_SOP;
               end
               2'b01 : begin  //4DW No Data
                  tx_end          <= 1'b1;
                  tx_dwen         <= 1'b0;
                  tx_data         <= {H2_ms_data, H2_ls_data};
                  tbtx_pkt_state  <= TBTX_SOP;
               end
               2'b10 : begin  //3DW With Data
                  GEN_DATA(0);
                  tx_data    <= {H2_ms_data, data0};
                  di          = 1;
                  if(stored_len == 1) begin
                     tx_end          <= 1'b1;
                     tx_dwen         <= 1'b0;
                     tbtx_pkt_state  <= TBTX_SOP;
                  end
                  else begin
                     //len_cnt         <= stored_len - 1;
                     tbtx_pkt_state  <= TBTX_DATA;
                  end
               end
               2'b11 : begin  //4DW With Data
                  tx_data         <= {H2_ms_data, H2_ls_data};
                  //len_cnt         <= stored_len;
                  di               = 0;
                  tbtx_pkt_state  <= TBTX_DATA;
               end
            endcase
         end
         TBTX_DATA: begin
            GEN_DATA(di);
            tx_data   <= {data0, data1};
            di        = di+2;
            //len_cnt   <= len_cnt - 2;
            //if((len_cnt == 1) || (len_cnt == 2)) begin
            if((di == stored_len) || (di == (stored_len+1))) begin
               tx_end          <= 1'b1;
               tx_dwen         <= (di == stored_len) ? 1'b0 : 1'b1;
               tbtx_pkt_state  <= TBTX_SOP;
            end
            if(stored_nul && ((di == stored_nul_len) || (di == (stored_nul_len+1)))) begin
               tx_nlfy         <= 1'b1;
               tbtx_pkt_state  <= TBTX_SOP;
            end
         end
      endcase
   end
end

// =============================================================================
// HEADER Generation for the Requested Pkt
// =============================================================================
task FORM_HEADER;
reg        TD, EP;
reg [7:0]  TAG;
reg [1:0]  ATTR;
reg [2:0]  TC;
reg [1:0]  fmt;
reg [4:0]  typp;
reg [9:0]  len;
reg [3:0]  LastDW_BE;
reg [3:0]  FirstDW_BE;
begin
    TAG       = TBTX_TAG + 1;
    TBTX_TAG  = TAG;
    TAG       = {3'b000, TBTX_TAG[4:0]};

    TD     = req_td;
    EP     = req_ep;

    case (req_type)
       MEM_RD,
       MEM_WR :  begin
          TC         = tx_tc;
          ATTR       = 2'b00; // Attr : 2 bits {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
          fmt[1]     = (req_type == MEM_RD) ? 1'b0 : 1'b1;
          fmt[0]     = (req_hdr) ? 1'b1 : 1'b0;   //32-bit /64-bit addressing (3 DW /4 DW)
          typp       = MEM_TYPE;
          len        = req_len;
          FirstDW_BE = req_be[7:4];
          LastDW_BE  = req_be[3:0];

          //First 8 bytes of Header
          H1_ms_data  = {R, fmt, typp, R, TC, R,R,R,R, TD, EP, ATTR, R, R, len};
          H1_ls_data  = {TBTX_REQ_ID, TAG, LastDW_BE, FirstDW_BE};

          //Second 4 bytes of Header
          if(req_hdr) begin  //64-bit Addr / 4 DW header
             H2_ms_data  = TBTX_UPPER32_ADDR;
             H2_ls_data  = {req_addr[31:2], R, R};
          end
          else begin
             H2_ms_data  = {req_addr[31:2], R, R};
             H2_ls_data  = 32'd0;
          end
       end
       CFG_RD,
       CFG_WR : begin
          TC         = 3'b000;  //Always
          ATTR       = 2'b00;   //Always
          fmt[1]     = (req_type == CFG_RD) ? 1'b0 : 1'b1;
          fmt[0]     = 1'b0;    //Always 3 DW
          typp       = (req_cfg) ? CFG1_TYPE : CFG0_TYPE;
          len        = 10'd1;   //Always
          FirstDW_BE = req_be[7:4];
          LastDW_BE  = 4'b0000; //Always

          //First 8 bytes of Header
          H1_ms_data  = {R, fmt, typp, R, TC, R,R,R,R, TD, EP, ATTR, R, R, len};
          H1_ls_data  = {TBTX_REQ_ID, TAG, LastDW_BE, FirstDW_BE};

          //Second 4 bytes of Header
          H2_ms_data  = req_addr;
          H2_ls_data  = 32'd0;
       end
       IO_RD,
       IO_WR  : begin
          TC         = 3'b000;  //Always
          ATTR       = 2'b00;   //Always
          fmt[1]     = (req_type == IO_RD) ? 1'b0 : 1'b1;
          //fmt[0]     = (req_hdr) ? 1'b1 : 1'b0;   //32-bit /64-bit addressing (3 DW /4 DW)
          fmt[0]     = 1'b0;    //Always 3 DW
          typp       = IO_TYPE;
          len        = 10'd1;   //Always
          FirstDW_BE = req_be[7:4];
          LastDW_BE  = 4'b0000; //Always

          //First 8 bytes of Header
          H1_ms_data  = {R, fmt, typp, R, TC, R,R,R,R, TD, EP, ATTR, R, R, len};
          H1_ls_data  = {TBTX_REQ_ID, TAG, LastDW_BE, FirstDW_BE};

          //Second 4/8 bytes of Header
          if(req_hdr) begin  //64-bit Addr / 4 DW header
             H2_ms_data  = TBTX_UPPER32_ADDR;
             H2_ls_data  = {req_addr[31:2], R, R};
          end
          else begin
             H2_ms_data  = {req_addr[31:2], R, R};
             H2_ls_data  = 32'd0;
          end
       end
       MSG,
       MSG_D  : begin
          TC         = tx_tc;
          ATTR       = 2'b00; // Attr : 2 bits {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
          fmt[1]     = (req_type == MSG) ? 1'b0 : 1'b1;
          fmt[0]     = 1'b1;    //Always 4 DW
          typp       = {MSG_TYPE[4:3], TBTX_MSG_ROUTE};
          len        = req_len;

          //First 8 bytes of Header
          H1_ms_data  = {R, fmt, typp, R, TC, R,R,R,R, TD, EP, ATTR, R, R ,len};
          H1_ls_data  = {TBTX_REQ_ID, TAG, TBTX_MSG_CODE};

          //Second 8 bytes of Header
          {H2_ms_data, H2_ls_data} = TBTX_MSG_TYPE;
       end
       CPL,
       CPL_D  : begin
          TC         = tx_tc;
          ATTR       = 2'b00; // Attr : 2 bits {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
          fmt[1]     = (req_type == CPL) ? 1'b0 : 1'b1;
          fmt[0]     = 1'b0;    //Always 3 DW
          typp       = CPL_TYPE;
          len        = req_len;

          //First 8 bytes of Header
          H1_ms_data  = {R, fmt, typp, R, TC, R,R,R,R, TD, EP, ATTR, R, R, len};
          H1_ls_data  = {TBTX_CPL_ID, req_status, TBTX_BCM, req_bytecnt};

          //Second 4 bytes of Header
          H2_ms_data  = {TBTX_REQ_ID, TAG, R, req_loweraddr};
          H2_ls_data  = 32'd0;
       end
    endcase

    stored_fmt      <= fmt;
    stored_len      <= (len == 'd0) ? {1'b1,len} : {1'b0,len};
    stored_nul      <= req_nul;
    stored_nul_len  <= req_nul_len;

end
endtask

// =============================================================================
// TD : Set indicates Presence of TLP Digest (ECRC)
// EP : Set indicates data Poisoned
// First DW BE :
// Last  DW BE :
// REQUESTER ID : 16 bits
// Tag  :8 bits
// Attr : 2 bits {Ordering, Snoop} = {0,0} -> {Strong Order, Snoop}
// =============================================================================

// =============================================================================
// 10 + 1 + 4 + 32 + 10 + 1 + 1 + 1 + 4 + 4  = 68
// NULL_len + NULLIFY + kind + addr + len + 3dw/4dw + TD + EP + FirstDwBE + LastDwBE
// =============================================================================
// len = 0
// =============================================================================
task tbtx_mem_rd;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW
begin
   TBTX_REQ_FIFO[req_cnt] = {MEM_RD, addr, length, hdr_type, TBTX_TD, TBTX_EP, First_DW_BE, 4'h0};
   req_cnt = req_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbtx_mem_wr;
input  [31:0]  addr;
input  [9:0]   length;
input          hdr_type;  //3 DW or 4 DW
input  [9:0]   nul_len;
input          nullify;
begin
   if(length == 1)
      Last_DW_BE = 4'b0000;

   TBTX_REQ_FIFO[req_cnt] = {nul_len, nullify, MEM_WR, addr, length, hdr_type, TBTX_TD, TBTX_EP, First_DW_BE, Last_DW_BE};
   req_cnt = req_cnt + 1;

   if(nullify && (length < nul_len))
      $display ("TBTX-TC%d: **** ERROR **** : NULLIFY Length is Greeater than Data Length at time %0t", tx_tc, $time);
end
endtask

// =============================================================================
// len = 0
// =============================================================================
task tbtx_msg;
begin
   //Meaasge Route & Meassge Code are default values
   TBTX_REQ_FIFO[req_cnt] = {11'd0, MSG, 32'd0, 10'd0, HEAD_4DW, TBTX_TD, TBTX_EP, 4'b0, 4'b0};
   req_cnt = req_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbtx_msg_d;
input [9:0]   length;
input  [9:0]   nul_len;
input          nullify;
begin
   //Meaasge Route & Meassge Code are default values
   TBTX_REQ_FIFO[req_cnt] = {nul_len, nullify, MSG_D, 32'd0, length, HEAD_4DW, TBTX_TD, TBTX_EP, 4'b0, 4'b0};
   req_cnt = req_cnt + 1;

   if(nullify && (length < nul_len))
      $display ("TBTX-TC%d: **** ERROR **** : NULLIFY Length is Greeater than Data Length at time %0t", tx_tc, $time);
end
endtask

// =============================================================================
// len = 0
// =============================================================================
task tbtx_cfg_rd;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
begin
   TBTX_REQ_FIFO[req_cnt] = {11'd0, CFG_RD, addr, 10'd0, HEAD_3DW, TBTX_TD, TBTX_EP, First_DW_BE, 3'h0, cfg};
   req_cnt = req_cnt + 1;
end
endtask

// =============================================================================
// len = 1
// =============================================================================
task tbtx_cfg_wr;
input          cfg;  //0: cfg0, 1: cfg1
input  [31:0]  addr;  //{Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
begin
   //addr = {Bus No, Dev. No, Function No, 4'h0, Ext Reg No, Reg No, 2'b00}
   TBTX_REQ_FIFO[req_cnt] = {11'd0, CFG_WR, addr, 10'd1, HEAD_3DW, TBTX_TD, TBTX_EP, First_DW_BE, 3'h0, cfg};
   req_cnt = req_cnt + 1;
end
endtask

// =============================================================================
// len = 0
// =============================================================================
task tbtx_io_rd;
input  [31:0]  addr;
begin
   TBTX_REQ_FIFO[req_cnt] = {11'd0, IO_RD, addr, 10'd0, HEAD_3DW, TBTX_TD, TBTX_EP, First_DW_BE, 4'h0};
   req_cnt = req_cnt + 1;
end
endtask

// =============================================================================
// len = 1
// =============================================================================
task tbtx_io_wr;
input  [31:0]  addr;
begin
   TBTX_REQ_FIFO[req_cnt] = {11'd0, IO_WR, addr, 10'd1, HEAD_3DW, TBTX_TD, TBTX_EP, First_DW_BE, 4'h0};
   req_cnt = req_cnt + 1;
end
endtask

// =============================================================================
// len = 0
// =============================================================================
task tbtx_cpl;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
begin
   TBTX_REQ_FIFO[req_cnt] = {11'd0, CPL, byte_cnt, lower_addr, status, 10'd0,  10'd0,  HEAD_3DW, TBTX_TD, TBTX_EP, 8'h0};
   req_cnt = req_cnt + 1;
end
endtask

// =============================================================================
// =============================================================================
task tbtx_cpl_d;
input [11:0]  byte_cnt;
input [6:0]   lower_addr;
input [2:0]   status;
input [9:0]   length;
input  [9:0]  nul_len;
input         nullify;
begin
   TBTX_REQ_FIFO[req_cnt] = {nul_len, nullify, CPL_D, byte_cnt, lower_addr, status,  10'd0, length,  HEAD_3DW, TBTX_TD, TBTX_EP, 8'h0};
   req_cnt = req_cnt + 1;

   if(nullify && (length < nul_len))
      $display ("TBTX-TC%d: **** ERROR **** : NULLIFY Length is Greeater than Data Length at time %0t", tx_tc, $time);
end
endtask

// =============================================================================
// Data Generation
// =============================================================================
task GEN_DATA;
input  [8:0]   data_no;
integer        i,j;
reg    [15:0]  i_reg, j_reg;
begin
   i = data_no;
   j = data_no+1;
   i_reg = i;
   j_reg = j;
   if(TBTX_MANUAL_DATA) begin
      data0 = D[i];
      data1 = D[j];
   end
   else if(TBTX_FIXED_PATTERN) begin
      case(data_no[3:0])
         0  : {data0, data1} = 64'h00000000_11111111;
         1  : {data0, data1} = 64'h11111111_22222222;
         2  : {data0, data1} = 64'h22222222_33333333;
         3  : {data0, data1} = 64'h33333333_44444444;
         4  : {data0, data1} = 64'h44444444_55555555;
         5  : {data0, data1} = 64'h55555555_66666666;
         6  : {data0, data1} = 64'h66666666_77777777;
         7  : {data0, data1} = 64'h77777777_88888888;
         8  : {data0, data1} = 64'h88888888_99999999;
         9  : {data0, data1} = 64'h99999999_AAAAAAAA;
         10 : {data0, data1} = 64'hAAAAAAAA_BBBBBBBB;
         11 : {data0, data1} = 64'hBBBBBBBB_CCCCCCCC;
         12 : {data0, data1} = 64'hCCCCCCCC_DDDDDDDD;
         13 : {data0, data1} = 64'hDDDDDDDD_EEEEEEEE;
         14 : {data0, data1} = 64'hEEEEEEEE_FFFFFFFF;
         15 : {data0, data1} = 64'hFFFFFFFF_00000000;
      endcase
   end
   else begin  //Default - Incremental Data
      data0 = i;
      data1 = j;
      //data0 = {pkt_id, i_reg};
      //data1 = {pkt_id, j_reg};
   end
end
endtask

// =============================================================================
// ERROR Conditions : Simulation stopped
// =============================================================================
always @(TBTX_Error) begin
   if(TBTX_Error) begin
      repeat (100) @(posedge sys_clk);
      $finish;
   end
end

endmodule
// =============================================================================
// $Id: pci_exp_x4_v0.0/pcie_x4_eval/username/testbench/top/eval_tbtx.v 1.1 2007/09/07 14:34:45PDT uananthi Exp  $
