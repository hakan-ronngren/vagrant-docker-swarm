# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'openssl'
require 'net/ssh'

HostInfos = [
    {name: "host-1", manager?: true,  ip_address: "192.168.99.101"},
    {name: "host-2", manager?: true,  ip_address: "192.168.99.102"},
    {name: "host-3", manager?: true,  ip_address: "192.168.99.103"},
    {name: "host-4", manager?: false, ip_address: "192.168.99.104"},
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
    if Vagrant::VERSION.split('.').first.to_i <= 1
        config.vm.box_url = "http://cloud.centos.org/centos/7/vagrant/x86_64/images/" +
                            "CentOS-7-x86_64-Vagrant-1801_02.VirtualBox.box"
    else
        config.vm.box_version = "1801.02"
    end

    config.vm.provider :virtualbox do |vb|
        vb.memory = "512"
    end

    HostInfos.each_with_index do |host_info, ix|
        config.vm.define(host_info[:name]) do |host|
            host.vm.hostname = host_info[:name]
    
            # Create a private network, which allows host-only access to the machine
            # using a specific IP.
            host.vm.network :private_network, ip: host_info[:ip_address]

            type = (host_info[:manager?] ? "manager" : "worker")
            host.vm.provision "shell", 
                path: "provision.sh", 
                args: "#{type} #{LeaderIpAddress} #{ix + 1}"
        end
    end
end
