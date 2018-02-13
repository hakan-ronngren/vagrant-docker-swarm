#!/bin/bash -e

set -x

TYPE=$1                 # "manager" or "worker"
LEADER_IP_ADDRESS=$2    # ip address of first manager

# Ensure docker is installed
if ! which docker 2> /dev/null ; then
    yum install -y docker
fi

# Ensure docker is started
if ! systemctl status docker > /dev/null 2>&1 ; then
    systemctl start docker
fi

# Ensure that there is a .ssh directory in root home
mkdir -p ~/.ssh

# Ensure that every host has the generated private key
cp /vagrant/id_rsa ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa

# Ensure that we are not already in a swarm
docker swarm leave --force > /dev/null 2>&1 || true

if (ip addr | grep "inet ${LEADER_IP_ADDRESS}" > /dev/null) ; then
    # Steps for the leader manager

    # Ensure that root may logon using ssh with the generated key
    cat /vagrant/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    systemctl reload sshd

    # Initialize a swarm and save the command line to be used by other nodes
    docker swarm init --advertise-addr $LEADER_IP_ADDRESS
else
    # Steps for other managers and workers

    # Join the swarm
    #ssh -o StrictHostKeyChecking=no $LEADER_IP_ADDRESS docker swarm join-token $TYPE | \
    #    sed -n '/^  */p;s/^  *//' | sh
    ssh -o StrictHostKeyChecking=no $LEADER_IP_ADDRESS docker swarm join-token $TYPE | \
        sed -n '/^  */p;s/^  *//' > /tmp/join.sh
    . /tmp/join.sh
fi
