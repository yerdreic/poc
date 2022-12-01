#!/usr/bin/env bash

#variables
PROJECT_NAME="poc"
SSH_KEY_NAME="poc-aws-key"
SSH_PRIVATE_FILE_NAME="poc-aws-key.pem"
SG_NAME="poc-aws"
SG_TAG_KEY="Name"
SG_TAG_VAL="poc-aws"
SG_ID=""
UBUNTU_X86_ID="ami-0caef02b518350c8b"
EC2_TYPE="t2.micro"
EC2_TAG_KEY="Name"
EC2_TAG_VAL="poc-aws-server"
SG_DESCRIPTION="AWS SG for poc-aws"
AWS_REGION="eu-central-1"
IAM_ROLE_NAME="PocRole"
POLICY_NAME="PocPolicy"
PROFILE_NAME="PocProfile"
