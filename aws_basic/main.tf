terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.42"
    }
  }

  required_version = ">= 0.13.5"
}

provider "aws" {
  profile = "sales"
  region  = "us-west-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t1.micro"

  tags = {
    Name = var.instance_name
  }
}
