variable "vagrant_box_name" {
  type        = string
  description = "The shortname of the vagrant box"
  default     = "grafeas/legacy"
  sensitive   = false
}

variable "vagrant_box_version" {
  type        = string
  description = "Semver-compliant version string"
  default     = "0.0.1"
  sensitive   = false
}

variable "ssh_port" {
  type        = number
  description = "Non-default port on which to operate the SSH daemon."
  default     = 8022 # Not a real user, but this makes it easier for a docker-only build
  sensitive   = true
}

variable "ssh_username" {
  type        = string
  description = "Username of a bot user, allowing an access point for later automation to manage this machine."
  default     = "my-automation-user" # Not a real user, but this makes it easier for a docker-only build
  sensitive   = true
}

variable "ssh_pubkey" {
  type        = string
  description = "Public key contents of a bot user, allowing SSH access for later automation."
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOlrB2crict8ZzD6OnTWelbaX8+3W4/UdtXaSg2jI6w"
  sensitive   = false
}
