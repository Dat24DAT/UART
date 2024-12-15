vlib work
vlog ../../rtl/receiver.sv
vlog ../../tb/receiver_tb.sv
vsim -t 1ps -voptargs="+acc" work.receiver_tb -wlf receiver.wlf 
log -r *
run -all