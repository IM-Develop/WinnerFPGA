
  #==============================================================================
  # Set up modelsim work library
  #==============================================================================
  cd "C:/Project/2024/Refael/Lightning/Vhdl/VersaTest/Vhdl/Versa_PCIeBasic/Clarity/ecp5um5G-45-Versa/pcie2_core/pcie2_core/pcie2_x1/pcie_eval/pcie2_x1/sim/modelsim/rtl"
  vlib                  work
  vmap pcsd_mti_work "C:/lscc/diamond/3.13/cae_library/simulation/blackbox/pcsd_work"
  vmap ecp5u_bb "C:/lscc/diamond/3.13/cae_library/simulation/blackbox/ecp5u_black_boxes"
  vlog -refresh -quiet -work pcsd_mti_work
  vlog -refresh -quiet -work ecp5u_bb
  #==============================================================================
  # Make vlog and vsim commands
  #==============================================================================
  vlog +define+RSL_SIM_MODE +define+SIM_MODE +define+USERNAME_EVAL_TOP=pcie2_x1_eval_top -novopt  +define+DEBUG=0 +define+SIMULATE   +incdir+../../../../pcie2_x1/testbench/top +incdir+../../../../pcie2_x1/testbench/tests +incdir+../../../../models/ecp5um +incdir+../../../../pcie2_x1/src/params  -y C:/lscc/diamond/3.13/cae_library/simulation/verilog/ecp5u +libext+.v -y C:/lscc/diamond/3.13/cae_library/simulation/verilog/pmi +libext+.v  ../../../../pcie2_x1/src/params/pci_exp_params.v  ../../../../pcie2_x1/src/params/pci_exp_ddefines.v  ../../../../pcie2_x1/testbench/top/eval_pcie.v  ../../../../pcie2_x1/testbench/top/eval_tbtx.v  ../../../../pcie2_x1/testbench/top/eval_tbrx.v ../../../../models/ecp5um/pcie2_x1_ctc.v  ../../../../models/ecp5um/pcie2_x1_sync1s.v  ../../../../models/ecp5um/pcie2_x1_sci_ctrl.v  ../../../../models/ecp5um/pcie2_x1_pipe.v  ../../../../models/ecp5um/pcie2_x1_extref.v  ../../../../models/ecp5um/pcie2_x1_pcs_softlogic.v  ../../../../models/ecp5um/pcie2_x1_pcs.v  ../../../../models/ecp5um/pcie2_x1_phy.v  ../../../../pcie2_x1/src/top/pcie2_x1_core.v  ../../../../pcie2_x1/src/top/pcie2_x1_beh.v ../../../../pcie2_x1/src/top/pcie2_x1_eval_top.v  -work work

  vsim -novopt -t 1ps -c work.tb_top  -L work -L ecp5u_bb -L pcsd_mti_work    -l  eval_pcie.log   -wlf eval_pcie.wlf 
  do ../sim.do
  
