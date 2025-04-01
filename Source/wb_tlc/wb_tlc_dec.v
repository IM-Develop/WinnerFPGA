// $Id: wb_tlc_dec.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $

`timescale 1ns / 100ps

module wb_tlc_dec #(parameter c_DATA_WIDTH = 64) (/*AUTOARG*/
   // Outputs
   fifo_dout, fifo_sop, fifo_eop, fifo_dwen, fifo_wrn, fifo_wen,
   fifo_bar,
   // Inputs
   rstn, clk_125, rx_din, rx_sop, rx_eop, rx_dwen, rx_bar_hit
   );
   
   input         rstn;
   input         clk_125;
   
   input [c_DATA_WIDTH-1:0]  rx_din;
   input 		     rx_sop;
   input 		     rx_eop;
   input 		     rx_dwen;
   input [6:0] 		     rx_bar_hit;
   output [c_DATA_WIDTH-1:0] fifo_dout;
   output 		     fifo_sop;
   output 		     fifo_eop;
   output 		     fifo_dwen;
   output 		     fifo_wrn;
   output 		     fifo_wen;
   output [6:0] 	     fifo_bar;
   
   reg [c_DATA_WIDTH-1:0]    rx_din_p;
   reg 			     rx_sop_p;
   reg 			     rx_eop_p, rx_eop_p2;
   reg 			     rx_dwen_p;
   
   reg [c_DATA_WIDTH-1:0]    fifo_dout;
   reg [6:0] 		     fifo_bar;
   reg 			     fifo_sop;
   reg 			     fifo_eop;
   reg 			     fifo_dwen;
   reg 			     fifo_wrn, fifo_wrn_p;
   reg 			     fifo_wen;
   reg 			     drop;
   
   always @(negedge rstn or posedge clk_125)
     begin
	if (~rstn) begin
	   rx_din_p   <= {c_DATA_WIDTH{1'b0}};
	   rx_sop_p   <= 1'b0;
	   rx_eop_p   <= 1'b0;
	   rx_dwen_p  <= 1'b0;    
	   
	   fifo_dout  <= {c_DATA_WIDTH{1'b0}};
	   fifo_sop   <= 1'b0;
	   fifo_eop   <= 1'b0;   
	   fifo_dwen  <= 1'b0;
	   fifo_wrn   <= 1'b0;
	   fifo_wrn_p <= 1'b0;        
	   fifo_wen   <= 1'b0;     
	   fifo_bar   <= 7'd0;
	   drop       <= 1'b0;
	end
	else begin
	   rx_din_p  <= rx_din;
	   rx_sop_p  <= rx_sop;
	   rx_eop_p  <= rx_eop;
	   rx_eop_p2 <= rx_eop_p;
	   rx_dwen_p <= rx_dwen;
	   fifo_wrn  <= fifo_wrn_p;
	   fifo_dout <= rx_din_p;
	   fifo_sop  <= rx_sop_p;
	   fifo_dwen <= rx_dwen_p;
	   
	   // Decode Type of Request
	   if (rx_sop) begin
	      fifo_bar <= rx_bar_hit;
	      
	      if (rx_bar_hit[0] || rx_bar_hit[1]) begin
		 casex (rx_din[63:56])
		   8'b00x00000: begin    // MRd
		      fifo_wrn_p <= 1'b0;          
		      drop       <= 1'b0;
		   end 
		   8'b01x00000: begin    // MWr
		      fifo_wrn_p <= 1'b1;          
		      drop       <= 1'b0;
		   end
		   default: begin    // Unsuppored by WB
		      drop <= 1'b1;
		   end
		 endcase
	      end // if (rx_bar_hit[0] || rx_bar_hit[1])
	      else begin
		 drop <= 1'b1;
	      end // else: !if(rx_bar_hit[0] || rx_bar_hit[1])
	   end // if (rx_sop)
	   else begin    // not sop
	      fifo_wrn_p <= 1'b0;      
	   end // else: !if(rx_sop)
	   
	   rx_eop_p2 <= rx_eop_p; 
	   fifo_eop  <= rx_eop_p;
	   
	   // FIFO Write Enable Control
	   if (rx_sop_p) begin
	      fifo_wen <= ~drop;              
	   end
	   else if (rx_eop_p2 && !rx_sop_p) begin
	      fifo_wen <= 1'b0;              
	   end
	end // else: !if(~rstn)
     end // always @ (negedge rstn or posedge clk_125)
   
endmodule

