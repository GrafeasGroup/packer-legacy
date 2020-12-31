build {
  sources = [
    "linode.main",
    "docker.main",
    "vagrant.main",
  ]

  provisioner "shell" {
    inline = [
      "apt-get update && apt-get install -y sudo",
    ]

    # This provider has non-root as the default login. By installing sudo,
    # we are able to consistently call `sudo <whatever>` even if the
    # executing user is `root`
    except = ["vagrant.main"]
  }

  provisioner "shell" {
    inline = [
      "apt-get install -y python3",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} sh -c {{ .Path }}"
  }

  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/setup-swap.sh",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} sh -c {{ .Path }}"

    except = ["docker.main"]
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
    playbook_file       = "${path.root}/ansible/test.yml"
    galaxy_file         = "${path.root}/ansible/requirements.yml"
    roles_path          = "${path.root}/ansible/roles"
    collections_path    = "${path.root}/ansible/collections"
    inventory_directory = "${path.root}/ansible"
  }

  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/teardown-swap.sh",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} sh -c {{ .Path }}"

    except = ["docker.main"]
  }

  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/cleanup.sh",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} sh -c {{ .Path }}"
  }
  provisioner "shell" {
    scripts = [
      # This allows us to remove unique identifiers from
      # the template and minimize image size at the end.
      "${path.root}/scripts/vm-cleanup.sh",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} sh -c {{ .Path }}"

    except = ["docker.main"]
  }

  post-processor "docker-tag" {
    repository = var.docker_image_name
    tags       = [var.docker_image_tag]

    only = ["docker.main"]
  }
}
