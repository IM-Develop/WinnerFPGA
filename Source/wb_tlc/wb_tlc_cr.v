// $Id: wb_tlc_cr.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $

module wb_tlc_cr (/*AUTOARG*/
   // Outputs
   cr_125,
   // Inputs
   clk_125, wb_clk, rstn, cr_wb
   );
   
   input  clk_125;
   input  wb_clk;
   input  rstn;
   
   input  cr_wb;
   output cr_125;
   
   reg 	  cr_wb_p;
   reg 	  cr_wb2;
   reg 	  cr_c1, cr_c2, cr_c2p, cr_c2p2;
   
   // pulse stretcher
   always @(posedge wb_clk or negedge rstn)
     begin
	if (~rstn) begin
	   cr_wb_p <= 1'b0;
	   cr_wb2  <= 1'b0;
	end
	else begin
	   cr_wb_p <= cr_wb;    
	   cr_wb2  <= cr_wb | cr_wb_p;
	end
     end // always @ (posedge wb_clk or negedge rstn)
   
   always @(posedge clk_125 or negedge rstn)
     begin
	if (~rstn) begin
	   cr_c1   <= 1'b0;
	   cr_c2p  <= 1'b0;        
	   cr_c2p2 <= 1'b0;   
	end
	else begin
	   cr_c1   <= cr_wb2;
	   cr_c2p  <= cr_c2;
	   cr_c2p2 <= cr_c2p;    
	end
     end // always @ (posedge clk_125 or negedge rstn)
   
   assign cr_125 = cr_c2p & ~cr_c2p2;
   
   always @(negedge clk_125 or negedge rstn)
     begin
	if (~rstn) begin
	   cr_c2 <= 1'b0;    
	end
	else begin
	   cr_c2 <= cr_c1;
	end
     end
   
endmodule

