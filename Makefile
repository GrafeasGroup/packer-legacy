.PHONY: linode docker clean-docker test clean all

IMAGE_NAME:=quay.io/thelonelyghost/grafeas-molecule-legacy
SSH_AUTH_SOCK=

all: linode docker

linode: secrets.hcl
	packer build -var-file=./secrets.hcl -only=linode.main .

docker:
	packer build -only=docker.main -var 'docker_image_name=$(IMAGE_NAME)' .

clean: clean-docker
	rm -rf ./ansible/venv

clean-docker:
	for image in `docker images --format '{{ .ID }}' library/debian:10`; do docker rmi "$$image"; done
	for image in `docker images --format '{{ .ID }}' $(IMAGE_NAME)`; do docker rmi "$$image"; done

secrets.hcl:
	@echo "ERROR! Please configure secrets.hcl according to the README" 1>&2
	@exit 1

test:
	packer validate .
