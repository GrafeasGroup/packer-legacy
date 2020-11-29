build {
  sources = ["linode.main"]

  provisioner "ansible" {
    # Wrap commands in a venv, install it during the run,
    # and set relevant environment variables
    command            = "${path.root}/scripts/call-ansible.sh"
    galaxy_command     = "${path.root}/scripts/call-ansible-galaxy.sh"
    skip_version_check = true

    # Because CentOS:
    sftp_command = "/usr/libexec/openssh/sftp-server -e"

    # Paths to files and locations
    playbook_file       = "${path.root}/ansible/site.yml"
    galaxy_file         = "${path.root}/ansible/requirements.yml"
    roles_path          = "${path.root}/ansible/roles"
    collections_path    = "${path.root}/ansible/collections"
    inventory_directory = "${path.root}/ansible"
  }
}
