#!/bin/bash

sed "/$1/d" /etc/hosts > /tmp/hosts; echo "$2 $1" >> /tmp/hosts; cat /tmp/hosts > /etc/hosts