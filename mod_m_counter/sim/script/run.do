vlib work
vlog ../../rtl/mod_m_counter.sv
vlog ../../tb/mod_m_counter_tb.sv
vsim -t 1ps -voptargs="+acc" work.mod_m_counter_tb -wlf mod_m_counter.wlf 
log -r *
run -all