packer {
  required_version = "~> 1.6"
}

source "linode" "main" {
  linode_token = var.linode_api_key
  image        = "linode/debian10"
  region       = "us-east"
  ssh_username = "root"

  image_label       = "tor-legacy"
  image_description = "A Debian-based image ready to run Python-based workloads"
  
  instance_type  = "g6-nanode-1"
  instance_label = "packer-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  instance_tags  = ["packer", "delete-me-if-older-than-4-hours"]
}

source "vagrant" "main" {
  communicator = "ssh"
  provider     = "virtualbox"
  add_force    = true
  source_path  = "generic/debian10"

  output_vagrantfile = <<-EOH
  Vagrant.configure("2") do |config|
    config.ssh.guest_port = ${var.ssh_port}
  end
  EOH
}
