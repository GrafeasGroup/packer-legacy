IMAGE_VERSION:=$(shell cat ./VERSION)

IMAGE_NAME:=quay.io/thelonelyghost/grafeas-molecule-legacy
SSH_AUTH_SOCK=
PACKER_TMP_DIR=/tmp

VAGRANT_PROVIDER=virtualbox
VAGRANT_BOX_NAME:=grafeas/legacy
VAGRANT_CLOUD_TOKEN:=

.PHONY: all
all: test vagrant

.PHONY: release
release: vagrant-release

.PHONY: linode
linode: secrets.hcl
	packer build -var-file=./secrets.hcl -only=linode.main .

.PHONY: vagrant
vagrant:
	@echo "packer build -var 'vagrant_box_name=$(VAGRANT_BOX_NAME)' -var 'vagrant_box_version=$(IMAGE_VERSION)' -var 'vagrant_cloud_token=<sensitive>' -only=vagrant.main ."
	@packer build -var 'vagrant_box_name=$(VAGRANT_BOX_NAME)' -var 'vagrant_box_version=$(IMAGE_VERSION)' -var 'vagrant_cloud_token=$(VAGRANT_CLOUD_TOKEN)' -only=vagrant.main .

.PHONY: vagrant-login
vagrant-login:
	@echo "vagrant cloud auth login --token='<sensitive>'"
	@vagrant cloud auth login --token='$(VAGRANT_CLOUD_TOKEN)'

.PHONY: vagrant-release
vagrant-release: vagrant-login
	vagrant cloud publish --release $(VAGRANT_BOX_NAME) $(IMAGE_VERSION) $(VAGRANT_PROVIDER)

.PHONY: clean
clean:
	rm -rf ./ansible/venv

secrets.hcl:
	@echo "ERROR! Please configure secrets.hcl according to the README" 1>&2
	@exit 1

.PHONY: test
test:
	packer validate .
