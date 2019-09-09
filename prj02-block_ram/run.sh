#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
  PARAM="open"
fi

if [ "$#" -ge 0 ]; then
  for vars in $@; do
    PARAM="$PARAM $vars"
  done
fi

if [[ $1 == "tcl" ]]; then
  TYPE="tcl"
else
  TYPE="batch"
fi

vivado -nojournal -nolog -mode ${TYPE} -source "$(pwd)/scripts/run.tcl" -notrace -tclarg "$PARAM"
