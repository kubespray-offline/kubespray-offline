# -*- mode: ruby -*-
# vi: set ft=ruby :

# You need to install vagrant-vbguest.
#  $ vagrant plugin install vagrant-vbguest

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false

  config.vm.synced_folder ".", "/home/vagrant/kubespray-offline", owner: "vagrant", group: "vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

  config.vm.define "cent7" do |c|
    c.vm.hostname = "cent7"
    c.vm.network "private_network", ip: "10.240.0.50"
    c.vm.box = "generic/centos7"
  end

  config.vm.define "ubuntu" do |c|
    c.vm.hostname = "ubuntu"
    c.vm.network "private_network", ip: "10.240.0.51"
    c.vm.box = "generic/ubuntu2004"
  end

  config.vm.define "cent8" do |c|
    c.vm.hostname = "cent8"
    c.vm.network "private_network", ip: "10.240.0.52"
    c.vm.box = "generic/centos8"
  end
end
