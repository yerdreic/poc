locals {
  PROJECT_NAME          = "poc"
  SSH_KEY_NAME          = "poc-aws-key"
  SSH_PRIVATE_FILE_NAME = "poc-aws-key.pem"
  SG_NAME               = "poc-aws"
  SG_TAG_KEY            = "Name"
  SG_TAG_VAL            = "poc-aws"
  SG_ID                 = ""
  IMAGE_ID              = "ami-0caef02b518350c8b"
  EC2_TYPE              = "t2.micro"
  EC2_TAG_KEY           = "Name"
  EC2_TAG_VAL           = "poc-aws-server"
  SG_DESCRIPTION        = "AWS SG for poc-aws"
  AWS_REGION            = "eu-central-1"
  IAM_ROLE_NAME         = "PocRole"
  POLICY_NAME           = "PocPolicy"
  PROFILE_NAME          = "PocProfile"

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.41"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "poc_instance" {
  ami           = locals.IMAGE_ID
  instance_type = locals.EC2_TYPE

  tags = {
    Name = "HelloWorldInstance"
  }
}
