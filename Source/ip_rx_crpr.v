// $Id: ip_rx_crpr.v,v 1.1.1.1 2008/07/01 17:34:22 jfreed Exp $

module ip_rx_crpr #(parameter c_DATA_WIDTH = 64) (/*AUTOARG*/
   // Outputs
   pd_cr, pd_num, ph_cr, npd_cr, nph_cr,
   // Inputs
   clk, rstn, rx_st, rx_end, rx_dwen, rx_din, rx_bar_hit
   );
   
   input clk;
   input rstn;
   
   input                    rx_st;
   input 		    rx_end;
   input 		    rx_dwen;
   input [c_DATA_WIDTH-1:0] rx_din;
   input [6:0] 		    rx_bar_hit;
   
   output 		    pd_cr;
   output [7:0] 	    pd_num;
   output 		    ph_cr;
   output 		    npd_cr;
   output 		    nph_cr;
   
   localparam e_IDLE = 2'b00;
   localparam e_WAIT = 2'b01;
   
   reg 			    pd_cr;
   reg [7:0] 		    pd_num;
   reg 			    ph_cr;
   reg 			    npd_cr;
   reg 			    nph_cr;
   
   reg 			    one_nph;
   reg 			    one_ph;
   reg 			    one_pd;
   reg 			    one_npd;
   
   reg [1:0] 		    sm;
   
   always @(posedge clk or negedge rstn)
     begin
	if (~rstn) begin
	   pd_cr   <= 1'b0;
	   pd_num  <= 8'd0;
	   ph_cr   <= 1'b0;
	   npd_cr  <= 1'b0;
	   nph_cr  <= 1'b0;
	   one_ph  <= 1'b0;
	   one_pd  <= 1'b0;
	   one_nph <= 1'b0;
	   one_npd <= 1'b0;
	   
	   sm      <= e_IDLE;
	end
	else begin
	   case (sm)    
	     e_IDLE: begin    // wait for TLP
		// Decode Type of Request
		if (rx_st) begin
		   casex (rx_din[63:56])
		     8'h00: begin    // MRd to BAR other than 0 or 1
			if (~(rx_bar_hit[1] || rx_bar_hit[0])) begin
			   one_nph <= 1'b1;
			end
		     end
		     8'h40: begin    // MWr to BAR other than 0 or 1
			if (~(rx_bar_hit[1] || rx_bar_hit[0])) begin
			   one_ph <= 1'b1;
			   one_pd <= 1'b1;
			   pd_num <= rx_din[38:32]; // get length          
			end
		     end
		     8'b00110xxx: begin    // Msg
			one_ph <= 1'b1;
		     end
		     8'b01110xxx: begin    // MsgD
			one_ph <= 1'b1;
			one_pd <= 1'b1;
			pd_num <= rx_din[38:32]; // get length
		     end
		     8'h44: begin    // CfgWr0
			one_nph <= 1'b1;
			one_npd <= 1'b1;
		     end
		     8'h04: begin    // CfgRd0
			one_nph <= 1'b1;
		     end
		     8'h45: begin    // CfgWr1
			one_nph <= 1'b1;
			one_npd <= 1'b1;
		     end
		     8'h05: begin    // CfgRd1
			one_nph <= 1'b1;
		     end
		     default: begin
		     end
		   endcase
		   
		   sm <= e_WAIT;
		end
		else begin
		   one_ph  <= 1'b0;
		   one_pd  <= 1'b0;
		   one_nph <= 1'b0;
		   one_npd <= 1'b0;
		end
		
		ph_cr  <= 1'b0;
		pd_cr  <= 1'b0;
		nph_cr <= 1'b0;
		npd_cr <= 1'b0;
	     end
	     e_WAIT: begin    // process credits
		ph_cr   <= one_ph;
		one_ph  <= 1'b0;
		
		nph_cr  <= one_nph;
		one_nph <= 1'b0;
		
		npd_cr  <= one_npd;
		one_npd <= 1'b0;
		
		pd_cr   <= one_pd;      
		one_pd  <= 1'b0;
		
		sm      <= e_IDLE;  
	     end
	     default: begin
	     end
	   endcase
	end // else: !if(~rstn)
     end // always @ (posedge clk or negedge rstn)
   
endmodule


  