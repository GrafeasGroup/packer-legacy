variable "linode_api_key" {
  type        = string
  description = "Linode API key from https://cloud.linode.com/profile/tokens"
  sensitive   = true
}

variable "ssh_port" {
  type        = number
  description = "Non-default port on which to operate the SSH daemon."
  sensitive   = true
}

variable "ssh_username" {
  type        = string
  description = "Username of a bot user, allowing an access point for later automation to manage this machine."
  sensitive   = true
}

variable "ssh_pubkey" {
  type        = string
  description = "Public key contents of a bot user, allowing SSH access for later automation."
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOlrB2crict8ZzD6OnTWelbaX8+3W4/UdtXaSg2jI6w"
  sensitive   = false
}
