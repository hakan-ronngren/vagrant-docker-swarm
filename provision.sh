#!/bin/bash -e

# TODO: improve this script to handle the situation better when we are already in a swarm.
# Only if we are a worker and should be a manager, or vice versa, we need to leave it
# and join it again. The current design actually creates a new swarm if the original swarm
# manager is re-provisioned.

TYPE=$1                 # "manager" or "worker"
LEADER_IP_ADDRESS=$2    # ip address of first manager, where join scripts can be fetched
REPLICAS=$3             # the number of replicas, will be set if TYPE is "manager"

SERVICE=hostname_web

function heading()
{
    echo -e "\e[1;34m$1\e[0m"
}

cd /vagrant

heading "Ensure docker is installed"
if ! which docker 2> /dev/null ; then
    yum install -y docker
fi

heading "Ensure netstat is installed (for troubleshooting)"
if ! which netstat 2> /dev/null ; then
    yum install -y net-tools
fi

heading "Ensure docker is enabled for autostart"
if ! systemctl is-enabled docker > /dev/null 2>&1 ; then
    systemctl enable docker
fi

heading "Ensure docker is started"
if ! systemctl is-active docker > /dev/null 2>&1 ; then
    systemctl start docker
fi

heading "Ensure that there is a .ssh directory in root home"
mkdir -p ~/.ssh

heading "Ensure that we have the generated private key"
cp id_rsa ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa

heading "Ensure that there is a Docker image"
docker build --tag $SERVICE .

heading "Ensure that we are not already in a swarm"
docker swarm leave --force > /dev/null 2>&1 || true

if (ip addr | grep "inet ${LEADER_IP_ADDRESS}" > /dev/null) ; then
    # Steps for the leader manager

    heading "Ensure that root may logon using ssh with the generated key"
    if ! grep `cut -f2 -d' ' id_rsa.pub` ~/.ssh/authorized_keys > /dev/null ; then
        cat id_rsa.pub >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
    fi
    if ! grep '^PermitRootLogin yes' /etc/ssh/sshd_config > /dev/null 2>&1 ; then
        sed -i 's/.*PermitRootLogin .*//' /etc/ssh/sshd_config
        echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
        systemctl reload sshd
    fi

    heading "Initialize a swarm and save the command line to be used by other nodes"
    docker swarm init --advertise-addr $LEADER_IP_ADDRESS

    heading "Create the service"
    docker service create --replicas $REPLICAS --publish=8080:80 --name $SERVICE $SERVICE:latest
else
    # Steps for other managers and workers

    heading "Join the swarm as a $TYPE"
    ssh -o StrictHostKeyChecking=no $LEADER_IP_ADDRESS docker swarm join-token $TYPE | \
        sed -n '/^  */p;s/^  *//' > /tmp/join.sh
    . /tmp/join.sh
fi

if [ $TYPE == 'manager' ] ; then
    heading "Ensure that the swarm has $REPLICAS replicas of $SERVICE"
    docker service scale $SERVICE=$REPLICAS
fi
