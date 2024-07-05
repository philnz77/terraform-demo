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
resource "aws_s3_bucket_public_access_block" "logging_block_public" {
  bucket = aws_s3_bucket.s3_logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket = aws_s3_bucket.s3_logging.id
  policy = data.aws_iam_policy_document.logging_bucket_policy.json
}
