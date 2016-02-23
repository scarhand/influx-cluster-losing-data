#!/bin/bash
BASEDIR=$(dirname $(readlink -f $0))
CONTAINER_NAME=$(basename $BASEDIR)

echo -e "Sudo is needed to clear the data."

echo "Clearing data of node 1"
sudo rm -rf $BASEDIR/influx-node-1
echo "Clearing data of node 2"
sudo rm -rf $BASEDIR/influx-node-2
echo "Clearing data of node 3"
sudo rm -rf $BASEDIR/influx-node-3