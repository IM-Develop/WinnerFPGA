// $Id: UR_gen.v,v 1.1.1.1 2008/07/01 17:34:22 jfreed Exp $

// This module is the catch all for any TLP that is not supported by the other
// clients.  
// Currently this module will generate UR for MRdLk, IO, Cfg1, Cpl, and Memory reads other than BAR1


`timescale 1ns / 100ps

module UR_gen #(parameter c_DATA_WIDTH = 64) (/*AUTOARG*/
   // Outputs
   tx_req, tx_dout, tx_sop, tx_eop, tx_dwen,
   // Inputs
   rstn, clk, rx_din, rx_sop, rx_eop, rx_dwen, rx_us, rx_bar_hit,
   tx_rdy, tx_val, comp_id
   );
   
   input         rstn;
   input         clk;
   
   input [c_DATA_WIDTH-1:0]  rx_din;
   input 		     rx_sop;
   input 		     rx_eop;
   input 		     rx_dwen;
   input 		     rx_us;
   input [6:0] 		     rx_bar_hit;
   input 		     tx_rdy;
   input 		     tx_val;
   output 		     tx_req;
   output [c_DATA_WIDTH-1:0] tx_dout;
   output 		     tx_sop;
   output 		     tx_eop;
   output 		     tx_dwen;
   input [15:0] 	     comp_id; 
   
   localparam e_idle    = 3'b000;
   localparam e_rcv_req = 3'b001;
   localparam e_check   = 3'b010;
   localparam e_xmit    = 3'b011;
   localparam e_clear   = 3'b100;
   
   reg [c_DATA_WIDTH-1:0]    tx_dout;
   reg 			     tx_sop;
   reg 			     tx_eop;
   reg 			     tx_dwen;
   reg 			     tx_req;
   reg [2:0] 		     sm;
   reg [23:0] 		     req_id;
   reg [2:0] 		     sts;
   
   always @(negedge rstn or posedge clk)
     begin
	if (~rstn) begin
	   tx_req  <= 1'b0;
	   tx_sop  <= 1'b0;
	   tx_eop  <= 1'b0;
	   tx_dwen <= 1'b0;
	   tx_dout <= {c_DATA_WIDTH{1'b0}};
	   sm      <= e_idle;
	   req_id  <= 24'd0;
	   sts     <= e_idle;
	end
	else begin
	   case (sm)
	     e_idle: begin    // Decode Type of Request
		if (rx_sop) begin
		   req_id <= rx_din[31:8];
		   
		   if (rx_us) begin    // IP core indicates CfgWr1, CfgRd1, MRdLk, CplLk, CplDLk, Msg (Vendor Defined) 
		      sm  <= e_rcv_req;
		      sts <= e_rcv_req;
		   end
		   else begin
		      casex(rx_din[63:56])
			8'b00000010: begin    // IORd
			   sm  <= e_rcv_req;
			   sts <= e_rcv_req;
			end // IORd
			8'b01000010: begin    // IOWr
			   sm  <= e_rcv_req;
			   sts <= e_rcv_req;
			end // IOWr
			8'b00000000: begin    // MRd
			   if (rx_bar_hit[1] || rx_bar_hit[0]) begin
			      sm <= e_idle;    // BAR0 or BAR1 read, do nothing
			   end
			   else begin
			      sm  <= e_rcv_req;    // Send UR          
			      sts <= e_rcv_req;
			   end
			end
			default: begin
			   sm <= e_idle;
			end
		      endcase
		   end // else: !if(rx_us)
		end // if (rx_sop)
	     end // case: e_idle
	     e_rcv_req: begin    // Send completion
		if (tx_val) begin
		   tx_req <= 1'b1;
		   sm     <= e_check;
		end
	     end
	     e_check: begin
		if (tx_val && tx_rdy) begin
		   tx_sop  <= 1'b1;
		   tx_dout <= {8'b00001010, 24'h000000, comp_id, sts, 13'd4};
		   tx_req  <= 1'b0;
		   sm      <= e_xmit;
		end
	     end
	     e_xmit: begin
		if (tx_val && tx_rdy) begin
		   tx_sop  <= 1'b0;
		   tx_dout <= {req_id, 8'h00, 32'd0};
		   tx_eop  <= 1'b1;
		   tx_dwen <= 1'b1;
		   sm      <= e_clear; // Clear
		end
	     end
	     e_clear: begin    // clear
		if (tx_val) begin
		   tx_sop  <= 1'b0;
		   tx_dout <= {c_DATA_WIDTH{1'b0}};
		   tx_eop  <= 1'b0;
		   tx_dwen <= 1'b0;
		   sm      <= e_idle;
		end
	     end
	   endcase
	end // else: !if(~rstn)
     end // always @ (negedge rstn or posedge clk)
   
endmodule

