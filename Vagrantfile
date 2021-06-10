# -*- mode: ruby -*-
# vi: set ft=ruby :

# You need to install vagrant-vbguest.
#  $ vagrant plugin install vagrant-vbguest

proxy_script = <<EOS
if [ -n "#{ENV['http_proxy']}" ]; then
  echo "http_proxy=#{ENV['http_proxy']}" | sudo tee -a /etc/environment
  echo "https_proxy=#{ENV['https_proxy']}" | sudo tee -a /etc/environment
  if [ -f /etc/yum.conf ]; then
    echo "proxy=#{ENV['http_proxy']}" | sudo tee -a /etc/yum.conf
  fi
  if [ -d /etc/apt/apt.conf.d ]; then
    echo "Acquire::http::proxy \\\"#{ENV['http_proxy']}\\\";" >> /etc/apt/apt.conf.d/01proxy
    echo "Acquire::https::proxy \\\"#{ENV['https_proxy']}\\\";" >> /etc/apt/apt.conf.d/01proxy
  fi
fi
EOS

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

  config.vm.provision :root_user, type: "shell", :inline => proxy_script
  config.vm.provision :vagrant_user, type: "shell", privileged: false, :inline => ssh_script
end
