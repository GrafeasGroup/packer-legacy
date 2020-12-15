# Packer image builder for Linode

HashiCorp [Packer] is a tool for building (primarily) VM templates, for use with on-prem or cloud providers, in a repeatable, scripted manner. For our purposes, it creates a base image where we can cache some rather expensive (time, CPU, etc.) operations so that scaling or disaster recovery occurs much faster. It's also one of the core components of an ephemeral infrastructure approach to things.

## Requirements

- Install [Packer] 1.6.0
- Install Python 3.6 or higher
- Linode API token generated
- (optional) Make (default on Linux or MacOS should be fine)

Set these environment variables to your chosen values, if you need to override the defaults:

| Var                         | Default                                          | Description                                               |
|:---------------------------:|:------------------------------------------------:|:----------------------------------------------------------|
| `PKR_VAR_docker_image_name` | `quay.io/thelonelyghost/grafeas-molecule-legacy` | Docker image name (and host) for the `docker.main` target |
| `PKR_VAR_docker_image_tag`  | `latest`                                         | Docker image tag for the `docker.main` target             |

... and set these values in `secrets.hcl`:

```hcl
linode_api_key = "fake-api-key-xxxxxxxxxxxxxxxx"
ssh_username   = "my-automation-user"
ssh_port       = 8022
```

For the real values of these, see [our private wiki entry][wiki-packer]

## Usage

```shell
~/workspace/packer-legacy $ packer validate .
~/workspace/packer-legacy $ packer build -only=linode.main -var-file=./secrets.hcl .

# Or...

~/workspace/packer-legacy $ make test linode
```

This will generate a new image with the same name (but different id) as any existing `private/` image in the Linode account. It is recommended to clear out images that are not being used by Terraform currently, or on-deck to be used next.

At time of writing, Linode allows for a max of 2 images stored for free. Each image can get no larger than 4GB.

## Testing

For testing purposes later down the line, we want to create a container image that's similar to the VM template we've just created. This is to help with testing [Ansible] that is intended for use once this VM image is in-use in the wild.

To build that container image on your local workstation, you'll need [Docker] installed and access to the internet. The build process looks a little something like this:

```shell
~/workspace/packer-legacy $ packer validate .
~/workspace/packer-legacy $ packer build -only=docker.main .

# Or...

~/workspace/packer-legacy $ export IMAGE_NAME='quay.io/thelonelyghost/grafeas-molecule-legacy'
~/workspace/packer-legacy $ make test docker IMAGE_NAME='quay.io/thelonelyghost/grafeas-molecule-legacy'

# Then publish it

~/workspace/packer-legacy $ docker login "${IMAGE_NAME/\/*/}"  # as dictated by your hosting provider
~/workspace/packer-legacy $ docker push "$IMAGE_NAME"
```

[Packer]: https://www.packer.io/
[Docker]: https://www.docker.com/
[Ansible]: https://docs.ansible.com/
[wiki-packer]: https://app.gitbook.com/@grafeas-group/s/dev/infra/packer
