# vagrant-docker-swarm

This project uses [Vagrant](https://www.vagrantup.com/) to set up a number of virtual machines using [VirtualBox](https://www.virtualbox.org/), create a [Docker swarm](https://docs.docker.com/engine/swarm/) and deploy a service consisting of a very simple web application that reveals the identity of the container host that rendered the page.

Having installed Vagrant and VirtualBox, you start the cluster like this:

```bash
vagrant up
```

Being deployed in a swarm, the application will then load equivalently from any of the involved hosts:

- http://192.168.100.100:8080/
- http://192.168.100.101:8080/
- http://192.168.100.102:8080/
- ...

## Visualizing the swarm

There is a script that you can use to monitor what is going on. Run it on a manager host like this:

```bash
vagrant ssh host-1 -c "/vagrant/monitor.sh"
```

Alternatively, you can start the [Portainer](https://portainer.io/) application. It must also run on a manager host:

```bash
vagrant ssh host-1 -c "/vagrant/start-portainer.sh"
```
If you start it on `host-1`, it will be accessible on http://192.168.100.100:9000/
