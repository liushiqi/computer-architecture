#!/bin/bash

if [[ $# -lt 5 ]]; then
  echo "should have at least 5 arguments PROJECT_ID PROJECT_DIR_NAME PROJECT_NAME DESIGN_TOP SIMULATION_TOP"
  exit 1
fi

PROJECT_ID=`printf "%02d" $1`

PROJECT_DIR_NAME=$2

PROJECT_DIR="prj$PROJECT_ID-$PROJECT_DIR_NAME"

PROJECT_NAME=$3

DESIGN_TOP=$4

SIMULATION_TOP=$5

cp -r prj00-template $PROJECT_DIR
m4 -D "PROJECT_NAME=$PROJECT_NAME" -D "DESIGN_TOP=$DESIGN_TOP" -D "SIMULATION_TOP=$SIMULATION_TOP" $PROJECT_DIR/scripts/run.tcl.in > $PROJECT_DIR/scripts/run.tcl
rm $PROJECT_DIR/scripts/run.tcl.in