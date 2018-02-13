#!/bin/bash -e

TYPE=$1                 # "manager" or "worker"
LEADER_IP_ADDRESS=$2    # ip address of first manager

JOIN_SCRIPT=/tmp/join.sh

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
docker swarm leave --force || true

if (ip addr | grep "inet ${LEADER_IP_ADDRESS}" > /dev/null) ; then
    # Steps for the leader manager

    # Ensure that root may logon using ssh with the generated key
    cat /vagrant/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    systemctl reload sshd

    # Initialize a swarm and save the command line to be used by other nodes
    docker swarm init --advertise-addr $LEADER_IP_ADDRESS | \
        sed -n '/^  */p;s/^  *//' > $JOIN_SCRIPT
    cat $JOIN_SCRIPT
elif [ "$1" == "manager" ] ; then
    # Steps for other managers

    echo "Non-leader managers cannot be provisioned, for the time being." >&2
    false
else
    # Steps for workers

    # Join the swarm as a worker
    scp -o StrictHostKeyChecking=no $LEADER_IP_ADDRESS:$JOIN_SCRIPT $JOIN_SCRIPT
    . $JOIN_SCRIPT
fi
