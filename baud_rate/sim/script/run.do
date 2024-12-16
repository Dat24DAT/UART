vlib work
vlog ../../rtl/baudrate.sv
vlog ../../tb/baudrate_tb.sv
vsim -t 1ps -voptargs="+acc" work.baudrate_tb -wlf baudrate.wlf 
log -r *
run -all