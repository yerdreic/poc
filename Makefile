.PHONY: build run logs rm infra-plan infra-apply provision up down

AWS_REGION := $(shell aws configure get region)

build:
	podman build -t consumer ./consumer

run:
	podman run -d --name=consumer -v ${HOME}/.aws:/root/.aws:Z consumer

logs:
	podman logs -f consumer

rm:
	podman stop consumer
	podman rm consumer

infra-plan:
	terraform -chdir=infra init
	terraform -chdir=infra plan -var "user=${USER}" -var "aws_region=${AWS_REGION}"

infra-apply:
	-terraform -chdir=infra apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

up: infra-apply provision

down:
	terraform -chdir=infra destroy -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

provision:
	ansible-galaxy install -r ./provision/requirements.yml
	ANSIBLE_CONFIG="./provision/ansible.cfg" ansible-playbook -e REGION=${AWS_REGION} ./provision/main.yml
