log /*
add wave {sim:/tb_top/u1_top/rst_n}
add wave {sim:/tb_top/u1_top/hdoutp*}
add wave {sim:/tb_top/u1_top/hdoutn*}
add wave {sim:/tb_top/u1_top/pclk}
add wave {sim:/tb_top/u1_top/txp*_ln0}
add wave {sim:/tb_top/u1_top/txp_detect_rx_lb}
add wave {sim:/tb_top/u1_top/rxp*_ln0}
add wave {sim:/tb_top/u1_top/txp*_rate}
add wave {sim:/tb_top/u1_top/phy_status}
add wave {sim:/tb_top/u1_top/phy_ltssm_state}
add wave {sim:/tb_top/u_tbtx[0]/tx_req}
add wave {sim:/tb_top/u_tbtx[0]/tx_rdy}
add wave {sim:/tb_top/u_tbtx[0]/tx_data}
add wave {sim:/tb_top/u_tbtx[0]/tx_st}
add wave {sim:/tb_top/u_tbtx[0]/tx_end}
add wave {sim:/tb_top/u_tbrx[0]/rx_data}
add wave {sim:/tb_top/u_tbrx[0]/rx_st}
add wave {sim:/tb_top/u_tbrx[0]/rx_end}
run -all
quit
