#!/bin/bash
BASEDIR=$(dirname $(readlink -f $0))
CONTAINER_NAME=$(basename $BASEDIR)

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

function build_container() {
	set +e
	`docker history "$CONTAINER_NAME" &>/dev/null`
	rc=$?
	set -e
	if [[ $rc != 0 ]]; then
		echo -e "${BOLD}Building container...${NC}"
		$BASEDIR/build.sh
	fi
}

function sleep_countdown() {
	echo -e $1
	secs=$2
	while [ $secs -gt 0 ]; do
	   echo -ne "$secs\033[K\r"
	   sleep 1
	   : $((secs--))
	done
}

function run_node_1() {
	mkdir -p $BASEDIR/influx-node-1
	echo -e "${GREEN}${BOLD}Running influx-node-1 in daemon mode${NC}"
	docker run -d \
		--name="influx-node-1" \
		-h "influx-node-1" \
		-v "$BASEDIR/influx-node-1":/data \
		-e WAIT="false" \
		-e META="false" \
		$CONTAINER_NAME 1>/dev/null
}

function run_node_2() {
	mkdir -p $BASEDIR/influx-node-2
	echo -e "${GREEN}${BOLD}Running influx-node-2 in daemon mode${NC}"
	docker run -d \
		--name="influx-node-2" \
		-h "influx-node-2" \
		-v "$BASEDIR/influx-node-2":/data \
		-e WAIT="true" \
		-e META="false" \
		--link influx-node-1:influx-node-1 \
		-e JOIN="influx-node-1:8091" \
		$CONTAINER_NAME 1>/dev/null
}

function run_node_3(){
	mkdir -p $BASEDIR/influx-node-3
	echo -e "${GREEN}${BOLD}Running influx-node-3 in daemon mode${NC}"
	docker run -d \
		--name="influx-node-3" \
		-h "influx-node-3" \
		-v "$BASEDIR/influx-node-3":/data \
		-e WAIT="true" \
		-e META="true" \
		--link influx-node-1:influx-node-1 \
		--link influx-node-2:influx-node-2 \
		-e JOIN="influx-node-1:8091 influx-node-2:8091" \
		$CONTAINER_NAME 1>/dev/null
}

function stop_container() {
	if docker inspect --format "{{ .State.Running }}" $1 &>/dev/null; then
		echo "Stopping $1"
		docker stop $1 > /dev/null
		echo "Removing old $1"
		docker rm $1 > /dev/null
	else
		echo "$1 does not exist, or is not running"
	fi
}