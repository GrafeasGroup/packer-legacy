IMAGE_VERSION:=$(shell cat ./VERSION)

IMAGE_NAME:=quay.io/thelonelyghost/grafeas-molecule-legacy
SSH_AUTH_SOCK=
PACKER_TMP_DIR=/tmp

VAGRANT_PROVIDER=virtualbox
VAGRANT_BOX_NAME:=grafeas/legacy

.PHONY: all
all: test vagrant

.PHONY: release
release: vagrant-release

.PHONY: linode
linode: secrets.hcl
	packer build -var-file=./secrets.hcl -only=linode.main .

.PHONY: vagrant
vagrant: vagrant-clean
	packer build -only=vagrant.main .

.PHONY: vagrant-login
vagrant-login:
	@# Because the username/password login method won't work if we have
	@# MFA enabled, it requires a token existing ahead of time. Let's
	@# let it fail like it normally would when running `whoami` and pass
	@# the (helpful) error message on to the end user.
	vagrant cloud auth whoami 1>/dev/null

.PHONY: vagrant-push
vagrant-push: output-main/package.box vagrant-login
	vagrant cloud publish $(VAGRANT_BOX_NAME) $(IMAGE_VERSION) $(VAGRANT_PROVIDER) ./output-main/package.box

.PHONY: vagrant-release
vagrant-release: vagrant-push vagrant-login
	vagrant cloud publish --release $(VAGRANT_BOX_NAME) $(IMAGE_VERSION) $(VAGRANT_PROVIDER)

.PHONY: vagrant-clean
vagrant-clean:
	rm -rf ./output-main

.PHONY: clean
clean: vagrant-clean
	rm -rf ./ansible/venv

secrets.hcl:
	@echo "ERROR! Please configure secrets.hcl according to the README" 1>&2
	@exit 1

output-main/package.box:
	@echo "ERROR! Vagrant box is not yet built" 1>&2
	@exit 1

.PHONY: test
test:
	packer validate .
