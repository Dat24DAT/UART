vlib work
vlog ../../rtl/fifo_buffer.sv
vlog ../../tb/fifo_buffer_tb.sv
vsim -t 1ps -voptargs="+acc" work.fifo_buffer_tb -wlf fifo_buffer.wlf 
log -r *
run -all