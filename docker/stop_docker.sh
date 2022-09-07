#!/bin/bash

ids=$(docker ps -a |  awk  '{ if ( $13 == "nginx-app" || $12 == "apache-app") print $1;}')
if [ -n "$ids" ]; then
    echo "Deleting existing containers..."
    docker rm -f $ids
fi