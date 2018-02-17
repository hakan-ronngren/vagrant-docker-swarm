#!/bin/sh

# Run this script on a manager host to get an overview of the current status

while true ; do
    clear
    echo "Nodes:"
    sudo docker node ls
    echo ; echo
    echo "Service replicas:"
    sudo docker service ps hostname_web
    sleep 2
done
