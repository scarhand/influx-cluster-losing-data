#!/bin/bash
BASEDIR=$(dirname $(readlink -f $0))
CONTAINER_NAME=$(basename $BASEDIR)

source $BASEDIR/functions.sh

set -e

build_container

stop_container "influx-node-1"
stop_container "influx-node-2"
stop_container "influx-node-3"

run_node_1
IP1=`docker inspect --format "{{ .NetworkSettings.IPAddress }}" influx-node-1`
run_node_2
IP2=`docker inspect --format "{{ .NetworkSettings.IPAddress }}" influx-node-2`
echo -e "Set the hostname of node 2 in node 1"
docker exec -it influx-node-1 /add_node_to_hosts.sh "influx-node-2" "$IP2"
sleep_countdown "Sleep 5 seconds before starting influx-node-3" 5
run_node_3
IP3=`docker inspect --format "{{ .NetworkSettings.IPAddress }}" influx-node-3`
echo -e "Set the hostname of node 3 in node 1"
docker exec -it influx-node-1 /add_node_to_hosts.sh "influx-node-3" "$IP3"
echo -e "Set the hostname of node 3 in node 2"
docker exec -it influx-node-2 /add_node_to_hosts.sh "influx-node-3" "$IP3"
sleep_countdown "Sleep 10 seconds to allow the cluster to fully start" 10
