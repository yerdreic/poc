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
  region = var.aws_region
}

resource "aws_instance" "poc_instance" {
  ami           = var.image_id
  instance_type = var.ec2_type

  tags = {
    Name = "HelloWorldInstance"
  }
}
