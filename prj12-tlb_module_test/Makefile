PARAMS := ""
TESTBENCH = 7
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

clean:
	rm -rf project trace_project xsim.dir xvlog.pb .Xil .idea
