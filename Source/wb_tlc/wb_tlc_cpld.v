// $Id: wb_tlc_cpld.v,v 1.1.1.1 2008/07/01 17:34:23 jfreed Exp $

module wb_tlc_cpld #(parameter c_DATA_WIDTH = 64) (/*AUTOARG*/
   // Outputs
   dout, dout_sop, dout_eop, dout_dwen, dout_wen,
   // Inputs
   wb_clk, rstn, din, sel, read, valid, tran_id, tran_length, tran_be,
   tran_addr, tran_tc, tran_attr, comp_id
   );
   
   input wb_clk;
   input rstn;
   
   input [c_DATA_WIDTH-1:0]  din;
   input [7:0] 		     sel;
   input 		     read;
   input 		     valid;
   input [23:0] 	     tran_id;  // tran_id = {req_id,tag}
   input [9:0] 		     tran_length;
   input [7:0] 		     tran_be;
   input [4:0] 		     tran_addr;
   input [2:0] 		     tran_tc;
   input [1:0] 		     tran_attr;
   input [15:0] 	     comp_id;
   output [c_DATA_WIDTH-1:0] dout;
   output 		     dout_sop;
   output 		     dout_eop;
   output 		     dout_dwen;
   output 		     dout_wen;
   
   reg [2:0] 		     sm;
   
   localparam IDLE  = 3'b000;
   localparam ACK   = 3'b010;
   localparam DAT   = 3'b011;
   localparam CLEAR = 3'b101;
   
   reg [c_DATA_WIDTH-1:0]    dout, din_p;
   reg 			     dout_sop, dout_eop, dout_wen;
   reg [11:0] 		     bc;
   reg [6:0] 		     la;
   
   reg 			     dout_dwen;
   
   always @(negedge rstn or posedge wb_clk)
     begin
	if (~rstn) begin
	   sm        <= IDLE;
	   dout      <= {c_DATA_WIDTH{1'b0}};
	   dout_sop  <= 1'b0;
	   dout_eop  <= 1'b0;
	   dout_dwen <= 1'b0;
	   din_p     <= {c_DATA_WIDTH{1'b0}};
	   
	   dout_wen  <= 1'b0;
	   la        <= 7'b0000000;
	end
	else begin
	   din_p     <= din;
	   
	   case (sm)
	     IDLE: begin
		if (read) sm <= ACK;
	     end
	     ACK: begin    // wait for data and valid
		if (valid) begin
		   dout_sop <= 1'b1;
		   dout_wen <= 1'b1;
		   dout     <= {8'h4a, 1'b0, tran_tc, 4'b0000, 2'b00, tran_attr, 2'b00, tran_length, comp_id, 3'b000, 1'b0, bc};            
		   sm       <= DAT;
		end
	     end
	     DAT: begin    // 3rd line of read completion
		dout[63:32] <= {tran_id, 1'b0, la};
		dout[31:0]  <= |sel[3:0] ? din_p[63:32] : din_p[31:0];
		dout_sop    <= 1'b0;
		dout_eop    <= 1'b1;
		dout_dwen   <= 1'b0;
		sm          <= CLEAR;
	     end
	     CLEAR: begin    // clean up  
		dout_wen  <= 1'b0;      
		dout_eop  <= 1'b0;      
		dout_dwen <= 1'b0;
		sm        <= IDLE;
	     end
	   endcase
	   
	   // implementation of table 2-21 from PCIe base spec
	   //tran_be = first, last
	   casex(tran_be)
	     8'b1xx10000: bc <= 12'h004;
	     8'b01x10000: bc <= 12'h003;
	     8'b1x100000: bc <= 12'h003;
	     8'b00110000: bc <= 12'h002;
	     8'b01100000: bc <= 12'h002;
	     8'b11000000: bc <= 12'h002;
	     8'b00010000: bc <= 12'h001;
	     8'b00100000: bc <= 12'h001;
	     8'b01000000: bc <= 12'h001;
	     8'b10000000: bc <= 12'h001;
	     8'b00000000: bc <= 12'h001;
	     8'bxxx11xxx: bc <= (tran_length*4);
	     8'bxxx101xx: bc <= (tran_length*4) - 1;
	     8'bxxx1001x: bc <= (tran_length*4) - 2;
	     8'bxxx10001: bc <= (tran_length*4) - 3;
	     8'bxx101xxx: bc <= (tran_length*4) - 1;
	     8'bxx1001xx: bc <= (tran_length*4) - 2;
	     8'bxx10001x: bc <= (tran_length*4) - 3;
	     8'bxx100001: bc <= (tran_length*4) - 4;
	     8'bx1001xxx: bc <= (tran_length*4) - 2;
	     8'bx10001xx: bc <= (tran_length*4) - 3;
	     8'bx100001x: bc <= (tran_length*4) - 4;
	     8'bx1000001: bc <= (tran_length*4) - 5;
	     8'b10001xxx: bc <= (tran_length*4) - 3;
	     8'b100001xx: bc <= (tran_length*4) - 4;
	     8'b1000001x: bc <= (tran_length*4) - 5;
	     8'b10000001: bc <= (tran_length*4) - 6;
	   endcase
	   
	   // implementation of table 2-22 from PCIe base spec
	   //tran_be = first, last
	   casex(tran_be[7:4])
	     4'b0000: la <= {tran_addr, 2'b00};     
	     4'bxxx1: la <= {tran_addr, 2'b00};     
	     4'bxx10: la <= {tran_addr, 2'b01};     
	     4'bx100: la <= {tran_addr, 2'b10};     
	     4'b1000: la <= {tran_addr, 2'b11};     
	   endcase
	end // else: !if(~rstn)
     end // always @ (negedge rstn or posedge wb_clk)
   
endmodule
