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
  default_tags {
    tags = merge(var.tags, { User = var.user })
  }
}

data "aws_ami" "centos_stream_8" {
  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "name"
    values = ["CentOS Stream 8 *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "poc_allow_ssh" {
  name        = var.sg_name
  description = "Allow ssh inbound and outbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy" "poc_ec2_policy" {
  name        = var.policy_name
  description = "Policy to provide permissions to poc-ec2 instance"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:ListSecrets"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "poc_ec2_role" {
  name = var.iam_role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "poc_attach_policy_to_role" {
  name       = "ec2Attachment"
  roles      = [aws_iam_role.poc_ec2_role.name]
  policy_arn = aws_iam_policy.poc_ec2_policy.arn
}

resource "aws_iam_instance_profile" "poc_ec2_profile" {
  name = var.profile_name
  role = aws_iam_role.poc_ec2_role.name
}
resource "tls_private_key" "poc_rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "poc_key_pair" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.poc_rsa.public_key_openssh

  provisioner "local-exec" {
    when    = create
    command = "echo '${tls_private_key.poc_rsa.private_key_openssh}' > ~/.ssh/${var.ssh_private_file_name}; chmod 400 ~/.ssh/${var.ssh_private_file_name}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ~/.ssh/${self.id}.pem"
  }
}

resource "aws_instance" "poc_instance" {
  depends_on = [
    tls_private_key.poc_rsa
  ]
  ami                    = data.aws_ami.centos_stream_8.id
  instance_type          = var.ec2_type
  vpc_security_group_ids = [aws_security_group.poc_allow_ssh.id]
  iam_instance_profile   = aws_iam_instance_profile.poc_ec2_profile.name
  key_name               = aws_key_pair.poc_key_pair.key_name
  tags                   = merge(var.tags, { Name = var.ec2_name })
}

resource "aws_secretsmanager_secret" "poc_secret" {
  name        = var.secret_name
  description = "secret to store the credentials"
}

resource "aws_secretsmanager_secret_version" "poc_secret" {
  secret_id     = aws_secretsmanager_secret.poc_secret.id
  secret_string = jsonencode(var.secret)
  # Terraform should no longer attempt to apply a new password.
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}
