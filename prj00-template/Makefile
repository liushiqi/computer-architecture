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
