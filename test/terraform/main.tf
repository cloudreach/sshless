variable "region" {
  description = "aws region"
  default     = "eu-central-1"
}

provider "aws" {
  region = "${var.region}"
  version = "~> 1.9"
}


variable "name" {
  description = "project name"
  default     = "sshless"
}
