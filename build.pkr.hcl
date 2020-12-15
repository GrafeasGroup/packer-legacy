build {
  sources = [
    "linode.main",
    "docker.main",
  ]

  provisioner "shell" {
    inline = [
      # This allows us to remove unique identifiers from
      # the template and minimize image size at the end.
      "apt-get update",
      "apt-get install -y python3 sudo",
    ]

    only = ["docker.main"]
  }

  provisioner "ansible" {
    # Wrap commands in a venv, install it during the run,
    # and set relevant environment variables
    command            = "${path.root}/ansible/bin/call-ansible-playbook.sh"
    galaxy_command     = "${path.root}/ansible/bin/call-ansible-galaxy.sh"
    skip_version_check = true

    # Because CentOS:
    # sftp_command = "/usr/libexec/openssh/sftp-server -e"

    extra_arguments = [
      "--extra-vars", "bot_username=${var.ssh_username} ssh_port=${var.ssh_port}",
    ]

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
      "${path.root}/scripts/cleanup.sh",
    ]

    except = ["docker.main"]
  }
  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/docker-cleanup.sh",
    ]

    only = ["docker.main"]
  }

  post-processor "docker-tag" {
    repository = var.docker_image_name
    tags       = [var.docker_image_tag]

    only = ["docker.main"]
  }
}
