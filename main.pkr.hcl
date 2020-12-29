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

# This is for later molecule tests in the Ansible
# workspace for deploying things
source "docker" "main" {
  image  = "docker.io/library/debian:10"
  tmpfs  = [
    "/run",
  ]
  commit = true
}

source "vagrant" "main" {
  communicator = "ssh"
  provider     = "virtualbox"
  add_force    = true
  source_path  = "generic/debian10"
}
