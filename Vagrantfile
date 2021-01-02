# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "grafeas/legacy"
  config.vm.box_version = ::File.read('VERSION').strip

  config.ssh.guest_port = 8022
  config.vm.network "forwarded_port", id: "ssh", guest: 8022, host: 2222, auto_correct: true
end
