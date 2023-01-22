.PHONY: init plan bootstrap provision up down

AWS_REGION := $(shell aws configure get region)

init:
	terragrunt init

plan:
	terragrunt plan -var "user=${USER}" -var "aws_region=${AWS_REGION}"

bootstrap:
	-terragrunt apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

up: bootstrap provision

down:
	terragrunt destroy -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

provision:
	ansible-galaxy install -r ./provision/requirements.yml
	ANSIBLE_CONFIG="./provision/ansible.cfg" ansible-playbook -e REGION=${AWS_REGION} ./provision/main.yml
