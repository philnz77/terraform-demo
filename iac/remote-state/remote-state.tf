variable "data_encryption_key_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "backend_bucket" {
  type = string
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = {
      Environment = var.environment
      Module      = "remote-state"
    }
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.backend_bucket
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "remote_state_lock" {
  name           = "remote-state-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption_rule" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.data_encryption_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}
