variable "ssh_key_name" {
  type    = string
  default = "poc-aws-key"
}

variable "ssh_private_file_name" {
  type    = string
  default = "poc-aws-key.pem"
}

variable "sg_name" {
  type    = string
  default = "poc-aws"
}

variable "image_id" {
  type    = string
  default = "ami-0b79da023fb461a12"
}

variable "ec2_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_name" {
  type    = string
  default = "poc-aws-server"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "iam_role_name" {
  type    = string
  default = "PocRole"
}

variable "policy_name" {
  type    = string
  default = "PocPolicy"
}

variable "profile_name" {
  type    = string
  default = "PocProfile"
}

variable "user" {
  type    = string
  default = ""
}

variable "tags" {
  type        = map(string)
  default     = { "project" = "POC" }
  description = "Resource tags"
}

variable "secret_name" {
  type    = string
  default = "poc"
}

variable "secret" {
  type        = map(string)
  description = "secret creds"
  default = {
    user     = "yael"
    password = "EXAMPLE-PASSWORD"
  }
}
