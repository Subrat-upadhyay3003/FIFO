vlib work
vlog FIFO.sv +acc
vlog FIFO_TB.vhd +acc
vsim work.FIFO_TB
add wave -r *
run -all 
