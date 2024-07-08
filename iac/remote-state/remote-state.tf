variable "environment" {
  type = string
}

variable "backend_bucket" {
  type = string
}

variable "s3_logging_bucket" {
  type = string
}



terraform {
  backend "s3" {
    key            = "remote-state/terraform.tfstate"
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
      Module      = "remote-state"
    }
  }
}

data "aws_caller_identity" "current" {}

//====================== TERRAFORM STATE BUCKET ==============

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.backend_bucket
  force_destroy = true
}


resource "aws_s3_bucket_logging" "terraform_bucket_logging" {
  bucket        = aws_s3_bucket.terraform_state.id
  target_bucket = aws_s3_bucket.s3_logging.id
  target_prefix = "s3-logs-terraform-state-"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# this rule should be redundant as of jan 5 2023
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_bucket_encryption_rule" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# should be redundant as of apr 2023
resource "aws_s3_bucket_public_access_block" "terraform_block_public" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        false
      ]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}
