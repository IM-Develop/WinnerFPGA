// $Id: wb_tlc_req_fifo.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $


`timescale 1ns / 100ps

module wb_tlc_req_fifo #(parameter c_DATA_WIDTH = 64) (/*AUTOARG*/
   // Outputs
   dout, dout_sop, dout_eop, dout_dwen, dout_wrn, dout_bar, tlp_avail,
   // Inputs
   rstn, clk_125, wb_clk, din, din_bar, din_sop, din_eop, din_dwen,
   din_wrn, din_wen, dout_ren
   );
   
   input         rstn;
   input         clk_125;
   input         wb_clk;
   
   input [c_DATA_WIDTH-1:0]  din;
   input [6:0] 		     din_bar;
   input 		     din_sop;
   input 		     din_eop;
   input 		     din_dwen;
   input 		     din_wrn;
   input 		     din_wen;
   
   output [c_DATA_WIDTH-1:0] dout;
   output 		     dout_sop;
   output 		     dout_eop;
   output 		     dout_dwen;
   output 		     dout_wrn;
   output [6:0] 	     dout_bar;
   input 		     dout_ren;
   output 		     tlp_avail;
   
   wire [74:0] 		     fifo_din, fifo_dout;
   
   assign fifo_din = {din_bar, din_dwen, din_wrn, din_eop, din_sop, din[63:0]};
   
   pmi_fifo_dc #(
		 .pmi_data_width_w(75),
		 .pmi_data_width_r(75),
		 .pmi_data_depth_w(4096),
		 .pmi_data_depth_r(4096),
		 .pmi_full_flag(4096),
		 .pmi_empty_flag(0),
		 .pmi_almost_full_flag(2), // 1 or more MRd or MWr TLPs in the FIFO
		 .pmi_almost_empty_flag(1),
		 .pmi_regmode("noreg"),
		 .pmi_resetmode("async"),
		 .pmi_family("ECP4U") ,
		 .module_type("pmi_fifo_dc"),
		 .pmi_implementation("EBR")
		 )
   fifo (
	 .Data(fifo_din),
	 .WrClock(clk_125),
	 .RdClock(wb_clk),
	 .WrEn(din_wen),
	 .RdEn(dout_ren),
	 .Reset(~rstn),
	 .RPReset(1'b0),
	 .Q(fifo_dout),
	 .Empty(),
	 .Full(),
	 .AlmostEmpty(empty),
	 .AlmostFull()
	 );
   
   assign dout      = fifo_dout[63:0];
   assign dout_sop  = fifo_dout[64];
   assign dout_eop  = fifo_dout[65];
   assign dout_wrn  = fifo_dout[66];
   assign dout_dwen = fifo_dout[67];
   assign dout_bar  = fifo_dout[74:68];
   
   assign tlp_avail = ~empty;
   
endmodule

