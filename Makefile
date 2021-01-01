# weird static analysis bugs are weird
.PHONY: CURL PACKER

IMAGE_VERSION:=$(shell cat ./VERSION)

IMAGE_NAME:=quay.io/thelonelyghost/grafeas-molecule-legacy
SSH_AUTH_SOCK=
PACKER_TMP_DIR=/tmp

VAGRANT_PROVIDER=virtualbox
VAGRANT_BOX_NAME:=grafeas/legacy
VAGRANT_API_BASE=https://app.vagrantup.com
# VAGRANT_CLOUD_TOKEN:=
# LINODE_TOKEN:=

CURL:=$(shell command -v curl)
PACKER:=$(shell command -v packer)


.PHONY: all
all: test vagrant

.PHONY: release
release: vagrant-release

.PHONY: linode
linode: secrets.hcl linode-login
	$(PACKER) build -var-file=./secrets.hcl -only=linode.main .

.PHONY: linode-login
linode-login:
ifneq ($(strip $(LINODE_TOKEN)),)
	@$(CURL) --fail --silent --show-error --location \
		--output /dev/null \
		--header 'Authorization: Bearer $(LINODE_TOKEN)' \
		https://api.linode.com/v4/account
	@echo LINODE_TOKEN is valid
else
	@echo 'ERROR: Missing environment variable value for LINODE_TOKEN. Set it and export it' >&2
	@exit 1
endif

.PHONY: vagrant
vagrant: vagrant-login
	$(PACKER) build \
		-var 'vagrant_box_name=$(VAGRANT_BOX_NAME)' \
		-var 'vagrant_box_version=$(IMAGE_VERSION)' \
		-only=vagrant.main .

.PHONY: vagrant-box
vagrant-box: vagrant-login
	if $(CURL) --fail --silent --location --header 'Authorization: Bearer $(VAGRANT_CLOUD_TOKEN)' $(VAGRANT_API_BASE)/api/v1/box/$(VAGRANT_BOX_NAME) 1>/dev/null 2>&1; then \
		$(CURL) --fail --show-error --silent --location \
			--data '{ "box": { "username": "$(word 1,$(subst /, ,$(VAGRANT_BOX_NAME)))", "name": "$(word 2,$(subst /, ,$(VAGRANT_BOX_NAME)))", "short_description": "", "description": "", "is_private": false } }' \
			--header 'Content-Type: application/json' \
			--header 'Authorization: Bearer $(VAGRANT_CLOUD_TOKEN)' \
			$(VAGRANT_API_BASE)/api/v1/boxes \
	fi

.PHONY: vagrant-login
vagrant-login:
ifneq ($(strip $(VAGRANT_CLOUD_TOKEN)),)
	@$(CURL) --fail --silent --show-error --location \
		--output /dev/null \
		--header 'Authorization: Bearer $(VAGRANT_CLOUD_TOKEN)' \
		https://app.vagrantup.com/api/v1/authenticate
	@# vagrant cloud auth login --check 1>/dev/null 2>&1
	@echo VAGRANT_CLOUD_TOKEN is valid
else
	@echo 'ERROR: Missing environment variable value for VAGRANT_CLOUD_TOKEN. Set it and export it' >&2
	@exit 1
endif

.PHONY: vagrant-release
vagrant-release: vagrant-login vagrant-box
	@# vagrant cloud publish --release $(VAGRANT_BOX_NAME) $(IMAGE_VERSION) $(VAGRANT_PROVIDER)
	$(CURL) --fail --show-error --silent --location \
		--header 'Authorization: Bearer $(VAGRANT_CLOUD_TOKEN)' \
		--request PUT \
		$(VAGRANT_API_BASE)/api/v1/boxes/$(VAGRANT_BOX_NAME)/$(IMAGE_VERSION)/release

.PHONY: clean
clean:
	rm -rf ./ansible/venv

secrets.hcl:
	@echo "ERROR! Please configure secrets.hcl according to the README" 1>&2
	@exit 1

.PHONY: test
test: test-packer vagrant-login linode-login

.PHONY: test-login
test-login: vagrant-login linode-login

.PHONY: test-packer
test-packer:
	$(PACKER) validate .
