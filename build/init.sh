#!/bin/bash

HOST=`hostname`
# echo "Setting the IP_ADDR '$IP_ADDR'"
sed -i "s/<HOST>/$HOST/g" /etc/influxdb/influxdb.conf

if [ -d "/data/meta" ]; then
	echo "Cleaning meta dir"
	rm -rf  /data/meta/*
fi

if [ "$META" = "true" ]; then
	echo "This node is a just a meta node"
	sed -i "s/<ENABLE_DATA>/false/g" /etc/influxdb/influxdb.conf
else
	echo "This node is a data node and a meta node"
	sed -i "s/<ENABLE_DATA>/true/g" /etc/influxdb/influxdb.conf	
fi

if [ "$WAIT" = "true" ]; then
	echo "Sleeping for 5 seconds, to allow the other nodes to be added to the hosts file"
	sleep 5
fi

if [ ! -z "$JOIN" ]; then
	echo "Joining $JOIN"
	INFLUXD_OPTS="-join $JOIN"
fi
exec influxd -config /etc/influxdb/influxdb.conf $INFLUXD_OPTS