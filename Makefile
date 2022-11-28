.PHONY: build run logs rm

build:
	podman build -t consumer ./consumer

run:
	podman run -d --name=consumer -v ${HOME}/.aws:/root/.aws:Z consumer

logs:
	podman logs -f consumer

rm:
	podman stop consumer
	podman rm consumer
