// $Id: wb_intf.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $

`timescale 1ns / 100ps
module wb_intf #(parameter c_DATA_WIDTH = 64) (/*AUTOARG*/
   // Outputs
   din_ren, tran_id, tran_length, tran_be, tran_addr, tran_tc,
   tran_attr, wb_dat_o, wb_adr_o, wb_we_o, wb_sel_o, wb_stb_o,
   wb_cyc_o, wb_lock_o,
   // Inputs
   rstn, wb_clk, din, din_bar, din_sop, din_eop, din_dwen, din_wrn,
   tlp_avail, wb_ack_i
   );              
   
   input         rstn;
   input         wb_clk;
   
   input [c_DATA_WIDTH-1:0]  din;
   input [6:0] 		     din_bar;
   input 		     din_sop;
   input 		     din_eop;
   input 		     din_dwen;
   input 		     din_wrn;
   output 		     din_ren;
   input 		     tlp_avail;
   output [23:0] 	     tran_id;
   output [9:0] 	     tran_length;
   output [7:0] 	     tran_be;
   output [4:0] 	     tran_addr;
   output [2:0] 	     tran_tc;
   output [1:0] 	     tran_attr;
   output [c_DATA_WIDTH-1:0] wb_dat_o;
   output [31:0] 	     wb_adr_o;
   output 		     wb_we_o;
   output [7:0] 	     wb_sel_o;
   output 		     wb_stb_o;
   output 		     wb_cyc_o;
   output 		     wb_lock_o;
   input 		     wb_ack_i;
   
   reg [c_DATA_WIDTH-1:0]    dat_p;
   reg 			     din_ren;
   reg [23:0] 		     tran_id;
   reg 			     write;
   reg [9:0] 		     length, tran_length;
   reg [31:0] 		     wb_adr_o;
   reg [4:0] 		     tran_addr;
   reg [2:0] 		     tran_tc;
   reg [1:0] 		     tran_attr;
   reg 			     wb_cyc_o;
   reg 			     wb_stb_o;
   reg 			     ackd;
   reg [7:0] 		     tran_be;
   
   reg [3:0] 		     first_be, last_be;
   
   reg [c_DATA_WIDTH-1:0]    wb_dat_o;
   reg 			     last_dw, first_dw;
   
   reg [2:0] 		     sm;
   
   localparam IDLE  = 3'b000;
   localparam READ  = 3'b001;
   localparam ADR   = 3'b010;
   localparam DAT   = 3'b011;
   localparam CLEAR = 3'b101;
   
   always @(negedge rstn or posedge wb_clk)
     begin
	if (~rstn) begin
	   din_ren     <= 1'b0;  
	   sm          <= IDLE;
	   length      <= 10'd0;
	   tran_length <= 10'd0;
	   tran_addr   <= 5'd0;
	   tran_tc     <= 3'd0;
	   tran_attr   <= 2'b00;
	   wb_adr_o    <= 32'd0;    
	   wb_dat_o    <= 32'd0;
	   wb_stb_o    <= 32'd0;
	   
	   tran_id     <= 24'd0;                 
	   write       <= 1'b0;
	   wb_cyc_o    <= 1'b0;
	   ackd        <= 1'b0;
           
	   first_be    <= 4'd0;
	   last_be     <= 4'd0;
	   tran_be     <= 8'd0;
	   last_dw     <= 1'b0;
	   first_dw    <= 1'b0;
	   
	   dat_p       <= {c_DATA_WIDTH{1'b0}};
	end
	else begin
	   tran_be     <= {first_be, last_be}; 
	   
	   case (sm)
	     IDLE: begin
		if (tlp_avail) begin
		   din_ren <= 1'b1;            
		   sm      <= READ;
		end
	     end
	     READ: begin
		if (din_sop && din_ren) begin    // 1st 2 DWs
		   sm          <= ADR;                  
		   write       <= din_wrn;                      
		   length      <= din[41:32];                  
		   tran_length <= din[41:32];                  
		   tran_attr   <= din[45:44];
		   tran_tc     <= din[54:52];
		   tran_id     <= din[31:8]; // req_id and tag         
		   
		   // special case if length=1
		   if (din[41:32]==10'd1) begin
		      first_be <= din[3:0];
		      last_be  <= din[3:0]; 
		      din_ren  <= 1'b0;
		   end
		   else begin
		      first_be <= din[3:0];
		      last_be  <= din[7:4];          
		      din_ren  <= 1'b1;
		   end
		end      
		else begin
		   length <= 10'd0;         
		   write  <= 1'b0;         
		end
	     end // case: READ
	     ADR: begin    // 2nd line of TLP
		// Adjust WB addr for BAR
		case (din_bar)         
		  7'b0000001: begin    // BAR0 
		     wb_adr_o <= {14'd0, din[49:32]}; // BAR0 base is 0x0
		  end
		  7'b0000010: begin    // BAR1
		     wb_adr_o <= {14'd0, din[49:32]}; // BAR1 base is 0x0             
		  end
		  default: begin
		  end         
		endcase
		
		tran_addr    <= din[38:34];        
		
		dat_p[63:32] <= din[31:0];     
		din_ren      <= 1'b0;  // so far read 2 
		
		sm           <= DAT;
	     end
	     DAT: begin    // start length counter
		if (wb_ack_i) ackd <= 1'b1;         
		
		wb_cyc_o <= 1'b1;              
		
		if (wb_ack_i) begin
		   sm       <= CLEAR;        
		   wb_stb_o <= 1'b0;
		   wb_cyc_o <= 1'b0;
		end
		else begin
		   wb_stb_o <= 1'b1;
		   last_dw  <= 1'b1;
		   wb_dat_o[63:32] <= {dat_p[39:32], dat_p[47:40], dat_p[55:48], dat_p[63:56]};         
		   wb_dat_o[31:0]  <= {dat_p[39:32], dat_p[47:40], dat_p[55:48], dat_p[63:56]};         
		end
	     end
	     CLEAR: begin    // wait state
		if (ackd || wb_ack_i) begin
		   wb_cyc_o <= 1'b0;
		   write    <= 1'b0;
		   ackd     <= 1'b0;
		   sm       <= IDLE;
		end
	     end
	   endcase
	end // else: !if(~rstn)
     end // always @ (negedge rstn or posedge wb_clk)
   
   // order byte enables for WB little endian
   assign wb_sel_o  = wb_adr_o[2] ? {last_be[0],last_be[1],last_be[2],last_be[3], 4'b0000} : 
                      {4'b0000, last_be[0],last_be[1],last_be[2],last_be[3]};  
   
   assign wb_we_o   = write;         
   assign wb_lock_o = wb_cyc_o;
   
endmodule


