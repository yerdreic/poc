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

resource "aws_security_group" "allow_ssh" {
  name        = "host_instance"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_instance" "poc_instance" {
  ami                    = var.image_id
  instance_type          = var.ec2_type
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = var.tags
}
