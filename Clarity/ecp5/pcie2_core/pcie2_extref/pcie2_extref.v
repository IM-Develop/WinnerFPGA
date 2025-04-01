// Verilog netlist produced by program ASBGen: Ports rev. 1.1, Attr. rev. 1.50
// Netlist written on Tue Apr 01 13:40:10 2025
//
// Verilog Description of module pcie2_extref
//

`timescale 1ns/1ps
module pcie2_extref (refclkp, refclkn, refclko);
    input refclkp;
    input refclkn;
    output refclko;
    
    
    EXTREFB EXTREF1_inst (.REFCLKP(refclkp), .REFCLKN(refclkn), .REFCLKO(refclko)) /* synthesis LOC=EXTREF1 */ ;
    defparam EXTREF1_inst.REFCK_PWDNB = "0b1";
    defparam EXTREF1_inst.REFCK_RTERM = "0b1";
    defparam EXTREF1_inst.REFCK_DCBIAS_EN = "0b1";
    
endmodule

