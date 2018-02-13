# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'openssl'
require 'net/ssh'

HostInfos = [
    {name: "host-1", manager?: true,  ip_address: "192.168.99.101"},
    {name: "host-2", manager?: false, ip_address: "192.168.99.102"},
    #{name: "host-3", manager?: false, ip_address: "192.168.99.103"},
]

unless HostInfos.first[:manager?]
    raise "The first host must be a manager, so there is a swarm for the rest to join"
end

# Generate an ssh key pair for hosts to use when retrieving the join command file
# and keep them so the same keys are reused when single hosts are provisioned again.
unless File.exist?("id_rsa")
    KeyPair = OpenSSL::PKey::RSA.new(2048)
    File.write("id_rsa", KeyPair.to_pem)
    File.write("id_rsa.pub", "#{KeyPair.ssh_type} #{[KeyPair.to_blob].pack('m0')}")
end

LeaderIpAddress = HostInfos.select {|hi| hi[:manager?]}.first[:ip_address]

Vagrant.configure("2") do |config|

    config.vm.box = "centos/7"
    config.vm.box_version = "1801.02"

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
    end

    HostInfos.each do |host_info|
        config.vm.define(host_info[:name]) do |host|
    
            # Create a private network, which allows host-only access to the machine
            # using a specific IP.
            host.vm.network "private_network", ip: host_info[:ip_address]

            type = (host_info[:manager?] ? "manager" : "worker")
            host.vm.provision "shell", 
                path: "provision.sh", 
                args: "#{type} #{LeaderIpAddress}"
        end
    end

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    # NOTE: This will enable public access to the opened port
    # config.vm.network "forwarded_port", guest: 80, host: 8080

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine and only allow access
    # via 127.0.0.1 to disable public access
    # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

end
