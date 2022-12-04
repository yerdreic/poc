.PHONY: build run logs rm infra-plan infra-apply provision up down

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
	terraform -chdir=infra plan

infra-apply:
	-terraform -chdir=infra apply -auto-approve

up: infra-apply provision

down:
	terraform -chdir=infra destroy -auto-approve

provision:
	ansible-galaxy install -r ./provision/requirements.yml
	ANSIBLE_CONFIG="./provision/ansible.cfg" ansible-playbook ./provision/main.yml
