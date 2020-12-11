# Packer image builder for Linode

## Requirements

- Install [Packer] 1.6.0
- Install Python 3.6 or higher
- Linode API token generated

Environment variables set:

| Var                      | Description                                               |
|:------------------------:|:----------------------------------------------------------|
| `PKR_VAR_linode_api_key` | The API key mentioned in the 'Requirements' section above |
| `PKR_VAR_ssh_username`   | The automation-only account's username (secret)           |
| `PKR_VAR_ssh_port`       | The non-default SSH port to assign                        |

## Usage

```bash
packer validate .
packer build .
```

This will generate a new image with the same name (but different id) as any existing `private/` image in the Linode account. It is recommended to clear out images that are not being used by Terraform currently, or on-deck to be used next.

At time of writing, Linode allows for a max of 2 images stored for free. Each image can get no larger than 4GB.

[Packer]: https://www.packer.io/
