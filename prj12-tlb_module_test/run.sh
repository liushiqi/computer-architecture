#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
  PARAM="open"
fi

if [ "$#" -ge 0 ]; then
  for vars in "$@"; do
    PARAM="$PARAM $vars"
  done
fi

vivado -nojournal -nolog -mode batch -source "$(pwd)/scripts/run.tcl" -notrace -tclarg $PARAM
