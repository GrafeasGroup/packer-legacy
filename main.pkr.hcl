packer {
  required_version = "~> 1.5"
}

source "linode" "main" {
  linode_token = var.linode_api_key
  image        = "linode/centos8"
  region       = "us-east"
  ssh_username = "root"

  image_label       = "tor-legacy"
  image_description = "A CentOS 8.x based image ready to run Python-based workloads"
  
  instance_type  = "g6-nanode-1"
  instance_label = "packer-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  instance_tags  = ["packer", "delete-me-if-older-than-4-hours"]
}
