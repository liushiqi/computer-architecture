PARAMS = ""

all: open

open:
	mkdir -p log
	./run.sh open ${PARAMS} | tee log/open.log

simulation:
	mkdir -p log
	./run.sh simulation ${PARAMS} | tee log/simulation.log

bitstream:
	mkdir -p log
	./run.sh bitstream ${PARAMS} | tee log/bitstream.log

implementation:
	mkdir -p log
	./run.sh implementation ${PARAMS} | tee log/implementation.log

board:
	mkdir -p log
	./run.sh board ${PARAMS} | tee log/board.log

testbench:
	make -C src/testbench clean
	make -C src/testbench compile
	mkdir -p sim
	cp src/testbench/obj/data_ram.coe sim
	cp src/testbench/obj/inst_ram.coe sim
	cp src/testbench/obj/test.s sim
	rm -rf project trace_project

trace: sim/trace.txt

sim/trace.txt: sim/data_ram.coe sim/inst_ram.coe
	vivado -nojournal -nolog -mode batch -source "$(shell pwd)/scripts/trace.tcl" -notrace -tclarg simulation
