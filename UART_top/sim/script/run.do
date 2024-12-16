vlib work
vlog ../../rtl/uart.sv
vlog ../../rtl/baudrate.sv
vlog ../../rtl/fifo_buffer.sv
vlog ../../rtl/receiver.sv
vlog ../../rtl/transmitter.sv

vlog ../../tb/uart_tb.sv
vsim -t 1ps -voptargs="+acc" work.uart_tb -wlf uart.wlf 
log -r *
run -all