// $Id: wb_tlc.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $

module wb_tlc #(parameter c_DATA_WIDTH = 64) (/*AUTOARG*/
   // Outputs
   wb_adr_o, wb_dat_o, wb_we_o, wb_sel_o, wb_stb_o, wb_cyc_o,
   wb_lock_o, pd_cr, ph_cr, npd_cr, nph_cr, tx_req, tx_data, tx_st,
   tx_end, tx_dwen, debug,
   // Inputs
   clk_125, wb_clk, rstn, rx_data, rx_st, rx_end, rx_dwen, rx_bar_hit,
   wb_ack_i, wb_dat_i, tx_rdy, tx_val, comp_id
   );
   
   input clk_125;
   input wb_clk;
   input rstn;
   
   input [c_DATA_WIDTH-1:0]  rx_data;
   input 		     rx_st;
   input 		     rx_end;
   input 		     rx_dwen;
   input [6:0] 		     rx_bar_hit;
   
   output [31:0] 	     wb_adr_o;
   output [c_DATA_WIDTH-1:0] wb_dat_o;
   output 		     wb_we_o;
   output [7:0] 	     wb_sel_o;
   output 		     wb_stb_o;
   output 		     wb_cyc_o;
   output 		     wb_lock_o;
   input 		     wb_ack_i;
   input [c_DATA_WIDTH-1:0]  wb_dat_i;
   
   output 		     pd_cr, ph_cr, npd_cr, nph_cr;
   
   input 		     tx_rdy;
   input 		     tx_val;
   output 		     tx_req;
   output [c_DATA_WIDTH-1:0] tx_data;
   output 		     tx_st;
   output 		     tx_end;
   output 		     tx_dwen;
   
   input [15:0] 	     comp_id; // completer id = {bus_num, dev_num, func_num}
   
   output [31:0] 	     debug;
   
/* -----\/----- EXCLUDED -----\/-----
   wire [c_DATA_WIDTH-1:0]   to_req_fifo_dout;
   wire 		     to_req_fifo_sop;
   wire 		     to_req_fifo_eop;
   wire 		     to_req_fifo_bad;
   wire 		     to_req_fifo_dwen;
   wire 		     to_req_fifo_wrn;
   wire 		     to_req_fifo_wen;
   wire [6:0] 		     to_req_fifo_bar;
   
   wire [c_DATA_WIDTH-1:0]   from_req_fifo_dout;
   wire 		     from_req_fifo_sop;
   wire 		     from_req_fifo_eop;
   wire 		     from_req_fifo_wrn;
   wire 		     tlp_avail;
 -----/\----- EXCLUDED -----/\----- */
   
   wire [c_DATA_WIDTH-1:0]   read_data;
/* -----\/----- EXCLUDED -----\/-----
   wire [9:0] 		     tran_len;
   wire [23:0] 		     tran_id;
   wire [7:0] 		     tran_be;
   wire [4:0] 		     tran_addr;
   wire [2:0] 		     tran_tc;
   wire [1:0] 		     tran_attr;
   
   wire [63:0] 		     cmpl_d;
   wire [6:0] 		     from_req_fifo_bar;
   
   wire 		     ph_cr_wb;
 -----/\----- EXCLUDED -----/\----- */
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [c_DATA_WIDTH-1:0] cmpl_d;		// From cpld of wb_tlc_cpld.v
   wire			cmpl_dwen;		// From cpld of wb_tlc_cpld.v
   wire			cmpl_eop;		// From cpld of wb_tlc_cpld.v
   wire			cmpl_sop;		// From cpld of wb_tlc_cpld.v
   wire			cmpl_wen;		// From cpld of wb_tlc_cpld.v
   wire [6:0]		from_req_fifo_bar;	// From req_fifo of wb_tlc_req_fifo.v
   wire [c_DATA_WIDTH-1:0] from_req_fifo_dout;	// From req_fifo of wb_tlc_req_fifo.v
   wire			from_req_fifo_dwen;	// From req_fifo of wb_tlc_req_fifo.v
   wire			from_req_fifo_eop;	// From req_fifo of wb_tlc_req_fifo.v
   wire			from_req_fifo_sop;	// From req_fifo of wb_tlc_req_fifo.v
   wire			from_req_fifo_wrn;	// From req_fifo of wb_tlc_req_fifo.v
   wire			tlp_avail;		// From req_fifo of wb_tlc_req_fifo.v
   wire [6:0]		to_req_fifo_bar;	// From dec of wb_tlc_dec.v
   wire [c_DATA_WIDTH-1:0] to_req_fifo_dout;	// From dec of wb_tlc_dec.v
   wire			to_req_fifo_dwen;	// From dec of wb_tlc_dec.v
   wire			to_req_fifo_eop;	// From dec of wb_tlc_dec.v
   wire			to_req_fifo_ren;	// From intf of wb_intf.v
   wire			to_req_fifo_sop;	// From dec of wb_tlc_dec.v
   wire			to_req_fifo_wen;	// From dec of wb_tlc_dec.v
   wire			to_req_fifo_wrn;	// From dec of wb_tlc_dec.v
   wire [4:0]		tran_addr;		// From intf of wb_intf.v
   wire [1:0]		tran_attr;		// From intf of wb_intf.v
   wire [7:0]		tran_be;		// From intf of wb_intf.v
   wire [23:0]		tran_id;		// From intf of wb_intf.v
   wire [9:0]		tran_len;		// From intf of wb_intf.v
   wire [2:0]		tran_tc;		// From intf of wb_intf.v
   // End of automatics
   
/* -----\/----- EXCLUDED -----\/-----
   wb_tlc_dec dec(.clk_125(clk_125), .rstn(rstn),
		  .rx_din(rx_data), .rx_sop(rx_st), .rx_eop(rx_end), .rx_dwen(rx_dwen), .rx_bar_hit(rx_bar_hit),
		  .fifo_dout(to_req_fifo_dout), .fifo_sop(to_req_fifo_sop), .fifo_eop(to_req_fifo_eop),  
		  .fifo_dwen(to_req_fifo_dwen), .fifo_wrn(to_req_fifo_wrn), .fifo_wen(to_req_fifo_wen),
		  .fifo_bar(to_req_fifo_bar)
		  );
 -----/\----- EXCLUDED -----/\----- */

   /*wb_tlc_dec AUTO_TEMPLATE (
    .fifo_dout        (to_req_fifo_dout[c_DATA_WIDTH-1:0]),
    .fifo_sop         (to_req_fifo_sop),
    .fifo_eop         (to_req_fifo_eop),
    .fifo_dwen        (to_req_fifo_dwen),
    .fifo_wrn         (to_req_fifo_wrn),
    .fifo_wen         (to_req_fifo_wen),
    .fifo_bar         (to_req_fifo_bar[6:0]),
    
    .rx_din           (rx_data[c_DATA_WIDTH-1:0]),
    .rx_sop           (rx_st),
    .rx_eop           (rx_end),
    .rx_dwen          (rx_dwen),
    ); */
   wb_tlc_dec #(.c_DATA_WIDTH (c_DATA_WIDTH)) dec(/*AUTOINST*/
						  // Outputs
						  .fifo_dout		(to_req_fifo_dout[c_DATA_WIDTH-1:0]), // Templated
						  .fifo_sop		(to_req_fifo_sop), // Templated
						  .fifo_eop		(to_req_fifo_eop), // Templated
						  .fifo_dwen		(to_req_fifo_dwen), // Templated
						  .fifo_wrn		(to_req_fifo_wrn), // Templated
						  .fifo_wen		(to_req_fifo_wen), // Templated
						  .fifo_bar		(to_req_fifo_bar[6:0]), // Templated
						  // Inputs
						  .rstn			(rstn),
						  .clk_125		(clk_125),
						  .rx_din		(rx_data[c_DATA_WIDTH-1:0]), // Templated
						  .rx_sop		(rx_st),	 // Templated
						  .rx_eop		(rx_end),	 // Templated
						  .rx_dwen		(rx_dwen),	 // Templated
						  .rx_bar_hit		(rx_bar_hit[6:0]));
   
/* -----\/----- EXCLUDED -----\/-----
   wb_tlc_req_fifo req_fifo (.rstn(rstn), .clk_125(clk_125), .wb_clk(wb_clk),
			     .din(to_req_fifo_dout), .din_bar(to_req_fifo_bar), .din_sop(to_req_fifo_sop), .din_eop(to_req_fifo_eop), 
			     .din_wrn(to_req_fifo_wrn),.din_dwen(to_req_fifo_dwen), .din_wen(to_req_fifo_wen), 
			     .dout(from_req_fifo_dout), .dout_sop(from_req_fifo_sop), .dout_eop(from_req_fifo_eop), .dout_wrn(from_req_fifo_wrn), 
			     .dout_bar(from_req_fifo_bar), .dout_dwen(from_req_fifo_dwen),
			     .dout_ren(to_req_fifo_ren), .tlp_avail(tlp_avail)
			     );
 -----/\----- EXCLUDED -----/\----- */

   /*wb_tlc_req_fifo AUTO_TEMPLATE (
    .dout             (from_req_fifo_dout[c_DATA_WIDTH-1:0]),
    .dout_sop         (from_req_fifo_sop),
    .dout_eop         (from_req_fifo_eop),
    .dout_dwen        (from_req_fifo_dwen),
    .dout_wrn         (from_req_fifo_wrn),
    .dout_bar         (from_req_fifo_bar[6:0]),
    
    .din              (to_req_fifo_dout[c_DATA_WIDTH-1:0]),
    .din_bar          (to_req_fifo_bar[6:0]),
    .din_sop          (to_req_fifo_sop),
    .din_eop          (to_req_fifo_eop),
    .din_dwen         (to_req_fifo_dwen),
    .din_wrn          (to_req_fifo_wrn),
    .din_wen          (to_req_fifo_wen),
    .dout_ren         (to_req_fifo_ren),
    ); */
   wb_tlc_req_fifo #(.c_DATA_WIDTH (c_DATA_WIDTH)) req_fifo (/*AUTOINST*/
							     // Outputs
							     .dout		(from_req_fifo_dout[c_DATA_WIDTH-1:0]), // Templated
							     .dout_sop		(from_req_fifo_sop), // Templated
							     .dout_eop		(from_req_fifo_eop), // Templated
							     .dout_dwen		(from_req_fifo_dwen), // Templated
							     .dout_wrn		(from_req_fifo_wrn), // Templated
							     .dout_bar		(from_req_fifo_bar[6:0]), // Templated
							     .tlp_avail		(tlp_avail),
							     // Inputs
							     .rstn		(rstn),
							     .clk_125		(clk_125),
							     .wb_clk		(wb_clk),
							     .din		(to_req_fifo_dout[c_DATA_WIDTH-1:0]), // Templated
							     .din_bar		(to_req_fifo_bar[6:0]), // Templated
							     .din_sop		(to_req_fifo_sop), // Templated
							     .din_eop		(to_req_fifo_eop), // Templated
							     .din_dwen		(to_req_fifo_dwen), // Templated
							     .din_wrn		(to_req_fifo_wrn), // Templated
							     .din_wen		(to_req_fifo_wen), // Templated
							     .dout_ren		(to_req_fifo_ren)); // Templated
   
   assign ph_cr_wb = from_req_fifo_sop & from_req_fifo_wrn;
   
/* -----\/----- EXCLUDED -----\/-----
   wb_tlc_cr phcr(.rstn(rstn), .clk_125(clk_125), .wb_clk(wb_clk), .cr_wb(ph_cr_wb), .cr_125(ph_cr));
 -----/\----- EXCLUDED -----/\----- */
   
   /*wb_tlc_cr AUTO_TEMPLATE (
    .cr_125           (ph_cr),
    
    .cr_wb            (ph_cr_wb),
    ); */
   wb_tlc_cr phcr (/*AUTOINST*/
		   // Outputs
		   .cr_125		(ph_cr),		 // Templated
		   // Inputs
		   .clk_125		(clk_125),
		   .wb_clk		(wb_clk),
		   .rstn		(rstn),
		   .cr_wb		(ph_cr_wb));		 // Templated
   
   assign pd_cr = ph_cr;
   
   
/* -----\/----- EXCLUDED -----\/-----
   wb_intf intf (.rstn(rstn), .wb_clk(wb_clk), 
		 .din(from_req_fifo_dout), .din_sop(from_req_fifo_sop), .din_eop(from_req_fifo_eop), 
		 .din_bar(from_req_fifo_bar), .din_wrn(from_req_fifo_wrn), .din_dwen(from_req_fifo_dwen),
		 .din_ren(to_req_fifo_ren), .tlp_avail(tlp_avail),
		 .tran_id(tran_id), .tran_length(tran_len), .tran_be(tran_be), .tran_addr(tran_addr), .tran_tc(tran_tc), .tran_attr(tran_attr),
		 .wb_adr_o(wb_adr_o), .wb_dat_o(wb_dat_o), .wb_we_o(wb_we_o), .wb_sel_o(wb_sel_o), .wb_stb_o(wb_stb_o), .wb_cyc_o(wb_cyc_o), .wb_lock_o(wb_lock_o), .wb_ack_i(wb_ack_i)
		 );
 -----/\----- EXCLUDED -----/\----- */

   /*wb_intf AUTO_TEMPLATE (
    .din_ren          (to_req_fifo_ren),
    .tran_length      (tran_len[9:0]),
    
    .din              (from_req_fifo_dout[c_DATA_WIDTH-1:0]),
    .din_bar          (from_req_fifo_bar[6:0]),
    .din_sop          (from_req_fifo_sop),
    .din_eop          (from_req_fifo_eop),
    .din_dwen	      (from_req_fifo_dwen),
    .din_wrn          (from_req_fifo_wrn),
    ); */
   wb_intf #(.c_DATA_WIDTH (c_DATA_WIDTH)) intf (/*AUTOINST*/
						 // Outputs
						 .din_ren		(to_req_fifo_ren), // Templated
						 .tran_id		(tran_id[23:0]),
						 .tran_length		(tran_len[9:0]), // Templated
						 .tran_be		(tran_be[7:0]),
						 .tran_addr		(tran_addr[4:0]),
						 .tran_tc		(tran_tc[2:0]),
						 .tran_attr		(tran_attr[1:0]),
						 .wb_dat_o		(wb_dat_o[c_DATA_WIDTH-1:0]),
						 .wb_adr_o		(wb_adr_o[31:0]),
						 .wb_we_o		(wb_we_o),
						 .wb_sel_o		(wb_sel_o[7:0]),
						 .wb_stb_o		(wb_stb_o),
						 .wb_cyc_o		(wb_cyc_o),
						 .wb_lock_o		(wb_lock_o),
						 // Inputs
						 .rstn			(rstn),
						 .wb_clk		(wb_clk),
						 .din			(from_req_fifo_dout[c_DATA_WIDTH-1:0]), // Templated
						 .din_bar		(from_req_fifo_bar[6:0]), // Templated
						 .din_sop		(from_req_fifo_sop), // Templated
						 .din_eop		(from_req_fifo_eop), // Templated
						 .din_dwen		(from_req_fifo_dwen), // Templated
						 .din_wrn		(from_req_fifo_wrn), // Templated
						 .tlp_avail		(tlp_avail),
						 .wb_ack_i		(wb_ack_i));
   

   assign read_data = {wb_dat_i[7:0], wb_dat_i[15:8], wb_dat_i[23:16], wb_dat_i[31:24], 
                       wb_dat_i[39:32], wb_dat_i[47:40], wb_dat_i[55:48], wb_dat_i[63:56]}; // order bytes back to PCIe order
   
/* -----\/----- EXCLUDED -----\/-----
   wb_tlc_cpld  cpld (.wb_clk(wb_clk), .rstn(rstn),
                      .din(read_data), .sel(wb_sel_o), .read(wb_stb_o && ~wb_we_o), .valid(wb_ack_i),
                      .tran_id(tran_id), .tran_length(tran_len), .tran_be(tran_be), .tran_addr(tran_addr), .tran_tc(tran_tc), .tran_attr(tran_attr), .comp_id(comp_id),
                      .dout(cmpl_d), .dout_sop(cmpl_sop), .dout_eop(cmpl_eop), .dout_dwen(cmpl_dwen),  .dout_wen(cmpl_wen)
		      );
 -----/\----- EXCLUDED -----/\----- */

   /*wb_tlc_cpld AUTO_TEMPLATE (
    .dout             (cmpl_d[c_DATA_WIDTH-1:0]),
    .dout_sop         (cmpl_sop),
    .dout_eop         (cmpl_eop),
    .dout_dwen        (cmpl_dwen),
    .dout_wen         (cmpl_wen),
    
    .din              (read_data[c_DATA_WIDTH-1:0]),
    .sel              (wb_sel_o[7:0]),
    .read             (wb_stb_o && ~wb_we_o),
    .valid            (wb_ack_i),
    .tran_length      (tran_len[9:0]),
    ); */
   wb_tlc_cpld #(.c_DATA_WIDTH (c_DATA_WIDTH)) cpld (/*AUTOINST*/
						     // Outputs
						     .dout		(cmpl_d[c_DATA_WIDTH-1:0]), // Templated
						     .dout_sop		(cmpl_sop),	 // Templated
						     .dout_eop		(cmpl_eop),	 // Templated
						     .dout_dwen		(cmpl_dwen),	 // Templated
						     .dout_wen		(cmpl_wen),	 // Templated
						     // Inputs
						     .wb_clk		(wb_clk),
						     .rstn		(rstn),
						     .din		(read_data[c_DATA_WIDTH-1:0]), // Templated
						     .sel		(wb_sel_o[7:0]), // Templated
						     .read		(wb_stb_o && ~wb_we_o), // Templated
						     .valid		(wb_ack_i),	 // Templated
						     .tran_id		(tran_id[23:0]),
						     .tran_length	(tran_len[9:0]), // Templated
						     .tran_be		(tran_be[7:0]),
						     .tran_addr		(tran_addr[4:0]),
						     .tran_tc		(tran_tc[2:0]),
						     .tran_attr		(tran_attr[1:0]),
						     .comp_id		(comp_id[15:0]));
   
   
/* -----\/----- EXCLUDED -----\/-----
   wb_tlc_cpld_fifo cpld_fifo(.rstn(rstn), .clk_125(clk_125), .wb_clk(wb_clk),
			      .din(cmpl_d), .din_sop(cmpl_sop), .din_eop(cmpl_eop),  .din_dwen(cmpl_dwen), .din_wen(cmpl_wen),
			      .tx_data(tx_data), .tx_st(tx_st), .tx_end(tx_end), .tx_dwen(tx_dwen),  
			      .tx_rdy(tx_rdy), .tx_req(tx_req), .tx_val(tx_val)
			      );
 -----/\----- EXCLUDED -----/\----- */
   
   /*wb_tlc_cpld_fifo AUTO_TEMPLATE (
    .tx_data          (tx_data[c_DATA_WIDTH-1:0]),
    .tx_dwen          (tx_dwen),
    
    .din              (cmpl_d[c_DATA_WIDTH-1:0]),
    .din_sop          (cmpl_sop),
    .din_eop          (cmpl_eop),
    .din_dwen         (cmpl_dwen),
    .din_wen          (cmpl_wen),
    ); */
   wb_tlc_cpld_fifo #(.c_DATA_WIDTH (64)) cpld_fifo (/*AUTOINST*/
						     // Outputs
						     .tx_data		(tx_data[c_DATA_WIDTH-1:0]), // Templated
						     .tx_st		(tx_st),
						     .tx_end		(tx_end),
						     .tx_dwen		(tx_dwen),	 // Templated
						     .tx_req		(tx_req),
						     // Inputs
						     .rstn		(rstn),
						     .clk_125		(clk_125),
						     .wb_clk		(wb_clk),
						     .din		(cmpl_d[c_DATA_WIDTH-1:0]), // Templated
						     .din_sop		(cmpl_sop),	 // Templated
						     .din_eop		(cmpl_eop),	 // Templated
						     .din_dwen		(cmpl_dwen),	 // Templated
						     .din_wen		(cmpl_wen),	 // Templated
						     .tx_rdy		(tx_rdy),
						     .tx_val		(tx_val));
   
   assign nph_cr = tx_st & tx_val;
   
endmodule
