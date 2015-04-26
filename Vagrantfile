# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_CONFIGURATION_VERSION = 2

Vagrant.configure(VAGRANT_CONFIGURATION_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "private_network", ip: "192.168.33.12"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  config.vm.provision "shell", path: "install_docker.sh"
  config.vm.provision "shell", path: "install_docker_compose.sh"
end
