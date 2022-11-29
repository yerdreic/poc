.PHONY: build run logs rm infra-plan infra-apply infra-destroy provision

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
	terraform -chdir=infra apply

infra-destroy:
	terraform -chdir=infra destroy

provision:
	ansible-playbook ./provision/main.yml
