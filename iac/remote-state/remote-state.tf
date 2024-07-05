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
  # backend "s3" {
  #   key            = "remote-state/terraform.tfstate"
  #   encrypt        = true
  #   region         = "ap-southeast-2"
  #   dynamodb_table = "remote-state-lock"
  # }

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

data "aws_caller_identity" "current" {}

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

data "aws_iam_policy_document" "logging_bucket_policy" {
  statement {
    sid    = "S3ServerAccessLogsPolicy"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.s3_logging.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
    
  }
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = var.backend_bucket
  force_destroy = true
}


resource "aws_s3_bucket" "s3_logging" {
  bucket = var.s3_logging_bucket
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "s3_logging_versioning" {
  bucket = aws_s3_bucket.s3_logging.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_logging_lifecycle" {
  bucket = aws_s3_bucket.s3_logging.id

  rule {
    id      = "LogRetentionRule"
    # Transition rule: Move logs to STANDARD_IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    # Transition rule: Move logs to GLACIER after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    
    # Expiration rule: Delete logs after 365 days
    expiration {
      days = 365
    }

    status = "Enabled"
  }
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

# this rule should be redundant as of jan 5 2023
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_bucket_encryption_rule" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# this rule should be redundant as of jan 5 2023
resource "aws_s3_bucket_server_side_encryption_configuration" "logging_bucket_encryption_rule" {
  bucket = aws_s3_bucket.s3_logging.id

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

# should be redundant as of apr 2023
resource "aws_s3_bucket_public_access_block" "logging_block_public" {
  bucket = aws_s3_bucket.s3_logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket = aws_s3_bucket.s3_logging.id
  policy = data.aws_iam_policy_document.logging_bucket_policy.json
}
