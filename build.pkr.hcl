build {
  sources = [
    "linode.main",
    "vagrant.main",
  ]

  provisioner "shell" {
    # Ensure sudo for subsequent build steps. If no sudo and not
    # logging in as root, we're screwed anyway. Fail out.
    inline = [
      "if [ `id -u` -eq 1 ]; then apt-get update && apt-get install -y sudo; fi",
    ]
  }

  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/ansible-prep.sh",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} sh -c {{ .Path }}"
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
      "--extra-vars", "bot_username=${var.ssh_username} ssh_port=${var.ssh_port} ansible_python_interpreter=/usr/bin/python3",
    ]

    # Setting these should fix some of the (false alarm) warnings
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_COLLECTIONS_PATH=${path.root}/ansible/collections",
      "ANSIBLE_ROLES_PATH=${path.root}/ansible/roles",
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
      "--extra-vars", "bot_username=${var.ssh_username} ssh_port=${var.ssh_port} ansible_python_interpreter=/usr/bin/python3",
    ]

    # Setting these should fix some of the (false alarm) warnings
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_COLLECTIONS_PATH=${path.root}/ansible/collections",
      "ANSIBLE_ROLES_PATH=${path.root}/ansible/roles",
    ]

    groups = ["packer"]

    # Paths to files and locations
    playbook_file       = "${path.root}/ansible/test.yml"
    # galaxy_file         = "${path.root}/ansible/requirements.yml"
    # roles_path          = "${path.root}/ansible/roles"
    # collections_path    = "${path.root}/ansible/collections"
    inventory_directory = "${path.root}/ansible"
  }

  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/cleanup.sh",

      # This allows us to remove unique identifiers from
      # the template and minimize image size at the end.
      "${path.root}/scripts/vm-cleanup.sh",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} sh -c {{ .Path }}"
  }

  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/zero-out-disk.sh",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} sh -c {{ .Path }}"

    only = ["linode.main"]
  }

  post-processor "vagrant-cloud" {
    box_tag = var.vagrant_box_name
    version = var.vagrant_box_version

    vagrant_cloud_url = "https://app.vagrantup.com/api/v1"
    no_release        = true
  }
}
