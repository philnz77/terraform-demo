variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

terraform {
  backend "s3" {
    key            = "kubernetes/terraform.tfstate"
    encrypt        = true
    region         = "ap-southeast-2"
    dynamodb_table = "remote-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.57"
    }
  }

  required_version = ">= 1.9.0"
}

provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = {
      Environment = var.environment
      Module      = "kubernetes"
    }
  }
}

data "aws_subnets" "for_vpc" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}


