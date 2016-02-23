#!/bin/bash
BASEDIR=$(dirname $(readlink -f $0))
CONTAINER_NAME=$(basename $BASEDIR)

set -e

# Pull the baseimage
docker pull `head $BASEDIR/build/Dockerfile -n 1 | sed 's/FROM //i'`

# Build the container
docker build -t $CONTAINER_NAME $BASEDIR/build
