vlib work
vlog ../../rtl/transmitter.sv
vlog ../../tb/transmitter_tb.sv
vsim -t 1ps -voptargs="+acc" work.transmitter_tb -wlf transmitter.wlf 
log -r *
run -all