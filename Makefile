.PHONY: linode docker docker-clean docker-push vagrant vagrant-clean vagrant-push test clean all

IMAGE_NAME:=quay.io/thelonelyghost/grafeas-molecule-legacy
SSH_AUTH_SOCK=
PACKER_TMP_DIR=/tmp

VAGRANT_PROVIDER=virtualbox
VAGRANT_BOX_NAME:=grafeas/legacy
VAGRANT_BOX_VERSION:=`cat ./VERSION`

all: linode docker vagrant

linode: secrets.hcl
	packer build -var-file=./secrets.hcl -only=linode.main .

vagrant:
	packer build -only=vagrant.main .

vagrant-push: output-main/package.box
	vagrant cloud push $(VAGRANT_BOX_NAME) $(VAGRANT_BOX_VERSION) $(VAGRANT_PROVIDER) ./output-main/package.box

vagrant-clean:
	rm -rf ./output-main

docker:
	packer build -only=docker.main -var 'docker_image_name=$(IMAGE_NAME)' .

docker-push:
	docker push '$(IMAGE_NAME):latest'

docker-clean:
	for image in `docker images --format '{{ .ID }}' library/debian:10`; do docker rmi "$$image"; done
	for image in `docker images --format '{{ .ID }}' '$(IMAGE_NAME)'`; do docker rmi "$$image"; done

clean: docker-clean
	rm -rf ./ansible/venv

secrets.hcl:
	@echo "ERROR! Please configure secrets.hcl according to the README" 1>&2
	@exit 1

output-main/package.box:
	@echo "ERROR! Vagrant box is not yet built" 1>&2
	@exit 1

test:
	packer validate .
