variable "project_name" {
  type    = string
  default = "poc"
}

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

variable "sg_tag_key" {
  type    = string
  default = "Name"
}

variable "sg_tag_val" {
  type    = string
  default = "poc-aws"
}

variable "sg_id" {
  type    = string
  default = ""
}

variable "image_id" {
  type    = string
  default = "ami-0caef02b518350c8b"
}

variable "ec2_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_tag_key" {
  type    = string
  default = "Name"
}

variable "ec2_tag_val" {
  type    = string
  default = "poc-aws-server"
}

variable "sg_description" {
  type    = string
  default = "AWS SG for poc-aws"
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

variable "tags" {
  type        = map(string)
  default     = { "name" : "POC" }
  description = "Resource tags"
}
