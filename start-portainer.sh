#!/bin/sh

sudo docker volume create --name portainer_data
sudo docker run -d --privileged --name portainer -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
