# vagrant-docker-swarm

This project sets up a number of virtual machines using [VirtualBox](https://www.virtualbox.org/), sets up a [Docker swarm](https://docs.docker.com/engine/swarm/) and deploys a service consisting of a very simple web application that reveals the identity of the container host that rendered the page.

Being deployed in a swarm, the application loads equivalently from any of the involved hosts:

- http://192.168.99.101:8080/
- http://192.168.99.102:8080/
- http://192.168.99.103:8080/
- ...

## Visualizing the swarm

There is a script that you can use to monitor what is going on. Run it on a manager host like this:

```bash
vagrant ssh host-1 -c "/vagrant/monitor.sh"
```

Alternatively, you can start the Portainer application. It must also run on a manager host:

```bash
vagrant ssh host-1 -c "/vagrant/start-portainer.sh"
```
