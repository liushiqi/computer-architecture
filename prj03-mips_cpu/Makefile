PARAMS := ""
TESTBENCH = 8
MEMORY_GAME = 0

TESTBENCH_BASE_DIR = src/testbench
ifeq (${MEMORY_GAME}, 0)
	TESTBENCH_DIR := "${TESTBENCH_BASE_DIR}/test$(shell printf "%02d" ${TESTBENCH})"
else
	TESTBENCH_DIR := "${TESTBENCH_BASE_DIR}/memory_game"
endif

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

sim/axi_ram.coe:
	testbench

testbench:
	make -C ${TESTBENCH_DIR} clean
	make -C ${TESTBENCH_DIR} all
	mkdir -p sim
	cp ${TESTBENCH_DIR}/obj/data_ram.coe sim
	cp ${TESTBENCH_DIR}/obj/inst_ram.coe sim
	cp ${TESTBENCH_DIR}/obj/inst_ram.coe sim/axi_ram.coe
	cp ${TESTBENCH_DIR}/obj/test.s sim
	rm -rf project trace_project

trace: sim/trace.txt

sim/trace.txt: sim/axi_ram.coe
	vivado -nojournal -nolog -mode batch -source "$(shell pwd)/scripts/trace.tcl" -notrace -tclarg simulation | tee log/trace.log

clean:
	for dir in ${TESTBENCH_BASE_DIR}/*; do \
	  make -C $${dir} clean; \
	done
	rm -rf project trace_project xsim.dir xvlog.pb .Xil .idea
