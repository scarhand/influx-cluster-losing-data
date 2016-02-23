#!/bin/bash
BASEDIR=$(dirname $(readlink -f $0))
CONTAINER_NAME=$(basename $BASEDIR)

source $BASEDIR/functions.sh

set -e

stop_container "influx-node-1"
stop_container "influx-node-2"
stop_container "influx-node-3"