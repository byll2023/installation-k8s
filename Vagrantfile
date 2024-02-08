# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Configuration de la première machine (Node maître)
  config.vm.box = "generic/ubuntu2204"
  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.1.171"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    master.vm.provision "shell", path: "provision.sh", privileged: false
  end

  # Configuration de la deuxième machine
  config.vm.box = "generic/ubuntu2204"
  config.vm.define "node2" do |node2|  
    node2.vm.hostname = "node2"
    node2.vm.network "private_network", ip: "192.168.1.172"
    node2.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    node2.vm.provision "shell", path: "provision.sh", privileged: false
  end

  # Configuration pour forcer le provisionnement à chaque démarrage
  config.vm.provision :shell, run: "always", inline: "echo Forcing provisioning"
end
