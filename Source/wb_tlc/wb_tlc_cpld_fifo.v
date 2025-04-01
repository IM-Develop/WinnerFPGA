// $Id: wb_tlc_cpld_fifo.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $

`timescale 1ns / 100ps

module wb_tlc_cpld_fifo #(parameter c_DATA_WIDTH = 64) (/*AUTOARG*/
   // Outputs
   tx_data, tx_st, tx_end, tx_dwen, tx_req,
   // Inputs
   rstn, clk_125, wb_clk, din, din_sop, din_eop, din_dwen, din_wen,
   tx_rdy, tx_val
   );
   
   input         rstn;
   input         clk_125;
   input         wb_clk;
   
   input [c_DATA_WIDTH-1:0]  din;
   input 		     din_sop;
   input 		     din_eop;
   input 		     din_dwen;
   input 		     din_wen;
   output [c_DATA_WIDTH-1:0] tx_data;
   output 		     tx_st;
   output 		     tx_end;
   output 		     tx_dwen;
   output 		     tx_req;
   input 		     tx_rdy;
   input 		     tx_val;
   
   wire [66:0] 		     fifo_in, fifo_out;
   reg 			     din_wen_p;
   reg [66:0] 		     fifo_out_p;
   reg 			     tx_eop_p, tx_st_p;
   
   reg 			     rden, rden_p;
   
   assign fifo_in  = {din_dwen, din_sop, din_eop, din};
   assign fifo_wen = din_wen | din_wen_p;
   
   // used to add 1 extra word to fifo to absorb rden latency
   always @(posedge wb_clk or negedge rstn)
     begin
	if (~rstn) din_wen_p <= 1'b0;
	else       din_wen_p <= din_wen;
     end
   
   pmi_fifo_dc #(
		 .pmi_data_width_w(67),
		 .pmi_data_width_r(67),
		 .pmi_data_depth_w(2048), // singe EBR
		 .pmi_data_depth_r(2048),
		 .pmi_full_flag(2048),
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
	 .Data(fifo_in),
	 .WrClock(wb_clk),
	 .RdClock(clk_125),
	 .WrEn(fifo_wen),
	 .RdEn(fifo_rden),
	 .Reset(~rstn),
	 .RPReset(1'b0),
	 .Q(fifo_out),
	 .Empty(),
	 .Full(),
	 .AlmostEmpty(empty),
	 .AlmostFull()
	 ); 
   
   assign tx_data  = fifo_out_p[63:0];
   assign tx_eop_i = fifo_out_p[64];
   assign tx_st_i  = fifo_out_p[65]; 
   assign tx_dwen  = fifo_out_p[66];
   
   assign tx_req   = ~empty;
   assign tx_st    = tx_st_i & ~tx_st_p;
   assign tx_end   = tx_eop_i & ~tx_eop_p ;
   
   assign fifo_eop = fifo_out[64];
   
   // assign fifo_rden = rden & tx_val;
   // use tx_rdy directly
   assign fifo_rden = tx_rdy & tx_val;
   
   always @(posedge clk_125 or negedge rstn)
     begin
	if (~rstn) begin
	   tx_eop_p   <= 1'b0;          
	   tx_st_p    <= 1'b0;          
	   
	   rden       <= 1'b0;
	   rden_p     <= 1'b0;
	   fifo_out_p <= 67'd0;
	end
	else begin
	   if (tx_val) begin
	      tx_eop_p   <= tx_eop_i ;          
	      tx_st_p    <= tx_st_i;    
	      fifo_out_p <= fifo_out;      
	      rden_p     <= rden;
              
	      // FIFO is written with 1 too many to absorb latency from eop detect to rden
	      if (tx_rdy & ~rden)         rden <= 1'b1;
	      else if (fifo_eop & rden_p) rden <= 1'b0;
	   end
	end // else: !if(~rstn)
     end // always @ (posedge clk_125 or negedge rstn)
   
endmodule

