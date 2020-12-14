build {
  sources = [
    "linode.main",
    "docker.main",
  ]

  provisioner "ansible" {
    # Wrap commands in a venv, install it during the run,
    # and set relevant environment variables
    command            = "${path.root}/scripts/call-ansible-playbook.sh"
    galaxy_command     = "${path.root}/scripts/call-ansible-galaxy.sh"
    skip_version_check = true

    # Because CentOS:
    sftp_command = "/usr/libexec/openssh/sftp-server -e"

    groups = ["packer"]

    # Paths to files and locations
    playbook_file       = "${path.root}/ansible/site.yml"
    galaxy_file         = "${path.root}/ansible/requirements.yml"
    roles_path          = "${path.root}/ansible/roles"
    collections_path    = "${path.root}/ansible/collections"
    inventory_directory = "${path.root}/ansible"
  }

  provisioner "shell" {
    scripts = [
      # This allows us to remove unique identifiers from
      # the template and minimize image size at the end.
      "${path.root}/cleanup.sh",
    ]

    except = ["docker.main"]
  }

  post-processor "docker-import" {
    repository = "quay.io/thelonelyghost/grafeas-molecule-legacy"
    tag        = "latest"

    only = ["docker.main"]
  }
}
