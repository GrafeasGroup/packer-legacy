# Packer image builder for Linode

HashiCorp [Packer] is a tool for building (primarily) VM templates, for use with on-prem or cloud providers, in a repeatable, scripted manner. For our purposes, it creates a base image where we can cache some rather expensive (time, CPU, etc.) operations so that scaling or disaster recovery occurs much faster. It's also one of the core components of an ephemeral infrastructure approach to things.

We output 2 types of images here:

- [Linode]
- [Vagrant] (provider: [VirtualBox])

The Vagrant box is intended entirely for testing purposes in downstream efforts.

## Special note on testing

## Requirements

- Install [Packer] 1.6.0
- Install Python 3.6 or higher
- Install Make (default on Linux or MacOS should be fine)
- [Linode] API token generated
- Install [Vagrant]
- Install [VirtualBox] (with extension pack)

Set these environment variables to your chosen values, if you need to override the defaults:

| Var                   | Default           | Description                                                   |
|:---------------------:|:-----------------:|:--------------------------------------------------------------|
| `LINODE_TOKEN`        | _(required)_      | Linode token for the `linode.main` Packer target              |
| `VAGRANT_CLOUD_TOKEN` | _(required)_      | Vagrant Cloud token name for the `vagrant.main` Packer target |
| `VAGRANT_BOX_NAME`    | `grafeas/legacy`  | Vagrant box name for the `vagrant.main` Packer target         |

... and set these values in `secrets.hcl`:

```hcl
ssh_username   = "my-automation-user"
ssh_port       = 8022
```

For the real values of these, see [our private wiki entry][wiki-packer]

## Usage

### Linode

```shell
# Validate it

~/workspace/packer-legacy $ make test

# Build / publish it

~/workspace/packer-legacy $ make linode
```

This will generate a new image with the same name (but different id) as any existing `private/` image in the Linode account. It is recommended to clear out images that are not being used by Terraform currently, or on-deck to be used next.

At time of writing and keeping with our billing model, Linode allows for a max of 2 images stored with each image no larger than 4GB.

## Test Images

For testing purposes later down the line, we may want to create a container image that's similar to the VM template we've just created. Since testing systemd doesn't work too well in containers, we create a local VM image for use with [Vagrant]. Due to cross-platform support and ease of access, the [VirtualBox] provider was chosen to work with Vagrant.

These base images (except Linode's) are to help with testing [Ansible] in downstream efforts, such as deploying applications to the servers, running a copy of the application in a production-like environment, etc.

### Container-based Images

[Docker] provides a good approximation of a VM environment, with some caveats, and allows for a _vast_ increase in speed of iterating as compared to a VM. One known caveat is an incompatibility between Docker and systemd, even when [jumping][docker-systemd-1] [through][docker-systemd-2] [drastic][docker-systemd-3] [hoops][docker-systemd-4]. Any of the solutions found were required a lot of hackery-pokery or flat-out didn't work when tested.

For these reasons, we use the Vagrant box for testing. This allows us to more fully emulate how a system would work in Linode, but entirely on a local basis.

[docker-systemd-1]: https://markandruth.co.uk/2020/10/10/running-systemd-inside-a-centos-8-docker-container
[docker-systemd-2]: https://developers.redhat.com/blog/2014/05/05/running-systemd-within-docker-container/
[docker-systemd-3]: https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container/
[docker-systemd-4]: https://lwn.net/Articles/676831/

### Local VM Images

To build the image that can be imported into Vagrant later, you'll need [Vagrant] and [VirtualBox] installed and access to the internet. The build process might look like this:

```shell
# Validate it

~/workspace/packer-legacy $ make test

# Set your Vagrant box's name

~/workspace/packer-legacy $ export VAGRANT_BOX_NAME='grafeas/legacy'

# Set the semver-style version of the Vagrant box (e.g., 1.0.1)

~/workspace/packer-legacy $ echo '1.0.1' > ./VERSION

# Build / publish it

~/workspace/packer-legacy $ make vagrant
```

Once it's tested and deemed in good working order, mark it as stable with `make vagrant-release`.

## CI/CD

Note that there is no continuous integration for this repository. This is due to a few reasons:

1. [Linode] creates new images on each upload (e.g., `private/12345` vs. `private/67890`) instead of replacing an existing one, which conflicts with our billing model's mandate of 2 custom images at the maximum.
2. [VirtualBox] is hard to scale and are very resource-intensive for a CI system, so few (if any) offer it out-of-box like they do [Docker].

Once these 2 issues are resolved, automatic builds and publishing can occur using a CI/CD system. Until then, builds should be done manually on local workstations in the manner outlined above.

[Linode]: https://www.linode.com/
[Packer]: https://www.packer.io/
[Docker]: https://www.docker.com/
[Vagrant]: https://www.vagrantup.com/
[VirtualBox]: https://www.virtualbox.org/
[Ansible]: https://docs.ansible.com/
[wiki-packer]: https://app.gitbook.com/@grafeas-group/s/dev/infra/packer
