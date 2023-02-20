.PHONY: init reconfigure upgrade plan bootstrap provision up down \
		init-in-container reconfigure-in-container upgrade-in-container \
		plan-in-container bootstrap-in-container provision-in-container \
		down-in-container dev-up dev-down

ENV := dev

ifndef OS_ENV
    ifneq ($(shell command -v docker),)
        ENGINE := docker
    else ifneq ($(shell command -v podman),)
        ENGINE := podman
    else
        $(error Container engine can't be found)
    endif
endif

ifeq ($(ENV), dev)
	ifndef AWS_REGION
		AWS_REGION := $(shell aws configure get region)
		AWS_ACCESS_KEY_ID := $(shell aws configure get default.aws_access_key_id)
		AWS_SECRET_ACCESS_KEY := $(shell aws configure get default.aws_secret_access_key)
		PULL_SECRET_ABS_PATH := ~/Downloads/pull-secret.txt
	endif
else ifeq ($(ENV), ci)
	AWS_REGION := ${AWS_REGION}
else ifeq ($(ENV), stage)
	AWS_REGION := ${AWS_REGION}
endif

HELPER_IMAGE := ghcr.io/platform-engineering-org/helper:latest
in_container = ${ENGINE} run --rm --name helper -v $(PWD):/workspace:rw -v ~/.aws:/root/.aws:ro -w /workspace --security-opt label=disable --env USER=${USER} --env AWS_REGION=${AWS_REGION} --env OS_ENV=container ${HELPER_IMAGE} echo ${ENV} && make $1
TERRAGRUNT_CMD = cd infra/live/${ENV} && terragrunt run-all --terragrunt-non-interactive

init-in-container:
	${TERRAGRUNT_CMD} init

reconfigure-in-container:
	${TERRAGRUNT_CMD} init --reconfigure

upgrade-in-container:
	${TERRAGRUNT_CMD} init --upgrade

plan-in-container:
	${TERRAGRUNT_CMD} plan -var "user=${USER}" -var "aws_region=${AWS_REGION}"

bootstrap-in-container:
	${TERRAGRUNT_CMD} apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

provision-in-container:
	ansible-galaxy install -r ./provision/requirements.yml
	ANSIBLE_CONFIG="./provision/ansible.cfg" ansible-playbook -e ENV=${ENV} -e AWS_REGION=${AWS_REGION} ./provision/main.yml

down-in-container:
	${TERRAGRUNT_CMD} destroy -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

init:
	$(call in_container,init-in-container)

reconfigure:
	$(call in_container,reconfigure-in-container)

upgrade:
	$(call in_container,upgrade-in-container)

plan:
	$(call in_container,plan-in-container)

bootstrap:
	$(call in_container,bootstrap-in-container)

up:
	$(call in_container,bootstrap-in-container provision-in-container)

down:
	$(call in_container,down-in-container)

provision:
	$(call in_container,provision-in-container)

dev-up:
	podman run --rm \
    -v ${PWD}:/workspace:z \
	-v ${PULL_SECRET_ABS_PATH}:/pullsecret/pull-secret.txt:z \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_REGION=${AWS_REGION} \
    quay.io/crcont/crc-cloud:v0.0.2 \
	create aws \
        --project-name "crc-ocp412" \
        --backed-url "file:///workspace" \
        --output "/workspace" \
        --aws-ami-id "ami-019669c0960dbcf14" \
        --pullsecret-filepath "/pullsecret/pull-secret.txt" \
        --key-filepath "/workspace/id_ecdsa"

dev-down:
	podman run -d --rm \
    -v ${PWD}:/workspace:z \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_REGION=${AWS_REGION} \
    quay.io/crcont/crc-cloud:v0.0.2 destroy \
        --project-name "crc-ocp412" \
        --backed-url "file:///workspace" \
        --provider "aws"
