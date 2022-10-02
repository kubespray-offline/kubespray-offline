# -*- mode: ruby -*-
# vi: set ft=ruby :

# You need to install vagrant-vbguest.
#  $ vagrant plugin install vagrant-vbguest

ssh_script = <<EOS
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
EOS

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false

  config.vm.synced_folder ".", "/home/vagrant/kubespray-offline", owner: "vagrant", group: "vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

  config.vm.define "ubuntu20" do |c|
    c.vm.hostname = "ubuntu20"
    c.vm.network "private_network", ip: "192.168.56.51"
    c.vm.box = "generic/ubuntu2004"
    #c.vm.network :forwarded_port, id: "ssh", guest: 22, host: 2230
  end

  config.vm.define "ubuntu22" do |c|
    c.vm.hostname = "ubuntu22"
    c.vm.network "private_network", ip: "192.168.56.54"
    c.vm.box = "generic/ubuntu2204"
    #c.vm.network :forwarded_port, id: "ssh", guest: 22, host: 2230
  end

  config.vm.define "alma8" do |c|
    c.vm.hostname = "alma8"
    c.vm.network "private_network", ip: "192.168.56.52"
    #c.vm.box = "almalinux/8"  # disk size is too small...
    c.vm.box = "bento/almalinux-8"
    #c.vm.network :forwarded_port, id: "ssh", guest: 22, host: 2231
  end

  config.vm.define "rhel8" do |c|
    c.vm.hostname = "rhel8"
    c.vm.network "private_network", ip: "192.168.56.55"
    c.vm.box = "generic/rhel8"
    #c.vm.network :forwarded_port, id: "ssh", guest: 22, host: 2233
  end

  config.vm.define "cent7" do |c|
    c.vm.hostname = "cent7"
    c.vm.network "private_network", ip: "192.168.56.53"
    c.vm.box = "generic/centos7"
    #c.vm.network :forwarded_port, id: "ssh", guest: 22, host: 2232
  end

  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.enabled  = true
    config.proxy.http     = "#{ENV['http_proxy']}"
    config.proxy.https    = "#{ENV['https_proxy']}"
    #config.proxy.no_proxy = "#{ENV['no_proxy']}"
  end

  config.vm.provision :vagrant_user, type: "shell", privileged: false, :inline => ssh_script
end
