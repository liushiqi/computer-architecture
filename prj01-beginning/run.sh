#!/usr/bin/env bash

PARAM=$1

if [ "$PARAM" == "" ]; then
    PARAM="open"
fi

vivado -nojournal -nolog -mode batch -source "$(pwd)/scripts/run.tcl" -notrace -tclarg $PARAM