.PHONY: build run logs rm infra-plan infra-apply provision

build:
	podman build -t consumer ./consumer

run:
	podman run -d --name=consumer -v ${HOME}/.aws:/root/.aws:Z consumer

logs:
	podman logs -f consumer

rm:
	podman stop consumer
	podman rm consumer

infra-format:
	terraform -chdir=infra fmt

infra-plan:
	terraform -chdir=infra init
	terraform -chdir=infra plan

infra-apply:
	terraform -chdir=infra apply

provision:
	ansible-playbook ./provision/main.yml
