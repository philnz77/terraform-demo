terraform {
  backend "s3" {
    key            = "eks-cluster/terraform.tfstate"
    encrypt        = true
    region         = "ap-southeast-2"
    dynamodb_table = "remote-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.57"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }

  required_version = ">= 1.9.0"
}

provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = {
      Environment = var.environment
      Module      = "eks-cluster"
    }
  }
}


