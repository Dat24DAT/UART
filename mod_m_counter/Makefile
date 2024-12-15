design_name = mod_m_counter
build: clean_build
	cd ./sim/work && vsim -c -do ../script/run.do
simu:
	cd ./sim/work && vsim $(design_name).wlf -do ../script/add_wave.do
clean_build:
	cd ./sim/work && del /Q *
clean: clean_build 
.PHONY: clean_build 