
    cd "C:/Project/2024/Refael/Lightning/Vhdl/VersaTest/Vhdl/Versa_PCIeBasic/Clarity/ecp5um5G-45-Versa/pcie2_core/pcie2_core/pcie2_x1/pcie_eval/pcie2_x1/sim/aldec/rtl"
    workspace create pcie_space
    design create pcie_design .
    design open pcie_design
    cd "C:/Project/2024/Refael/Lightning/Vhdl/VersaTest/Vhdl/Versa_PCIeBasic/Clarity/ecp5um5G-45-Versa/pcie2_core/pcie2_core/pcie2_x1/pcie_eval/pcie2_x1/sim/aldec/rtl"
    set sim_working_folder .
    #==============================================================================
    # Compile
    #==============================================================================
    vlog +define+RSL_SIM_MODE +define+SIM_MODE +define+USERNAME_EVAL_TOP=pcie2_x1_eval_top  +define+DEBUG=0 +define+SIMULATE   +incdir+../../../../pcie2_x1/testbench/top +incdir+../../../../pcie2_x1/testbench/tests +incdir+../../../../models/ecp5um +incdir+../../../../pcie2_x1/src/params ../../../../pcie2_x1/src/params/pci_exp_params.v  ../../../../pcie2_x1/src/params/pci_exp_ddefines.v  ../../../../pcie2_x1/testbench/top/eval_pcie.v  ../../../../pcie2_x1/testbench/top/eval_tbtx.v  ../../../../pcie2_x1/testbench/top/eval_tbrx.v ../../../../models/ecp5um/pcie2_x1_ctc.v  ../../../../models/ecp5um/pcie2_x1_sync1s.v  ../../../../models/ecp5um/pcie2_x1_sci_ctrl.v  ../../../../models/ecp5um/pcie2_x1_pipe.v  ../../../../models/ecp5um/pcie2_x1_extref.v  ../../../../models/ecp5um/pcie2_x1_pcs_softlogic.v  ../../../../models/ecp5um/pcie2_x1_pcs.v  ../../../../models/ecp5um/pcie2_x1_phy.v  ../../../../pcie2_x1/src/top/pcie2_x1_core.v  ../../../../pcie2_x1/src/top/pcie2_x1_beh.v ../../../../pcie2_x1/src/top/pcie2_x1_eval_top.v  

    #==============================================================================
    # Run
    #==============================================================================
    vsim -o2 +access +r -t 1ps pcie_design.tb_top -lib pcie_design  -L ovi_ecp5um  -L pmi_work 
    
add wave {sim:/tb_top/u1_top/rst_n}
add wave {sim:/tb_top/u1_top/sys_clk_125}
add wave {sim:/tb_top/u_tbtx[0]/tx_st}
add wave {sim:/tb_top/u_tbtx[0]/tx_end}
add wave {sim:/tb_top/u_tbtx[0]/tx_data}
add wave {sim:/tb_top/u_tbtx[0]/tx_val}
add wave {sim:/tb_top/u_tbtx[0]/tx_req}
add wave {sim:/tb_top/u_tbtx[0]/tx_rdy}
add wave {sim:/tb_top/u_tbrx[0]/rx_us_req}
add wave {sim:/tb_top/u_tbrx[0]/rx_st}
add wave {sim:/tb_top/u_tbrx[0]/rx_end}
add wave {sim:/tb_top/u_tbrx[0]/rx_data}
add wave {sim:/tb_top/u_tbrx[0]/rx_malf_tlp}
add wave sim:/tb_top/u1_top/hdoutp*
add wave sim:/tb_top/u1_top/hdoutn*
add wave sim:/tb_top/u1_top/hdinp*
add wave sim:/tb_top/u1_top/hdinn*
run -all
