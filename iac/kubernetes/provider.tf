variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

locals {
  region = "ap-southeast-2"
  zoneA = "ap-southeast-2a"
  zoneB = "ap-southeast-2b"
  cluster_name = "my-cluster"
  cluster_version = "1.30"
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


