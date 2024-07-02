variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "zipfile" {
  type = string
}

terraform {
  backend "s3" {
    key            = "demo-lambda/terraform.tfstate"
    encrypt        = true
    region         = "ap-southeast-2"
    dynamodb_table = "remote-state-lock"
  }

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
      Module      = "demo-lambda"
    }
  }
}

data "aws_subnets" "for_vpc" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_security_group" "cache_security_group" {
  name = "cache-security-group"
}

data "aws_elasticache_replication_group" "cache_replication_group" {
  replication_group_id = "elasticache-replication-group"
}


resource "aws_security_group" "lambda_security_group" {
  name        = "myapp-test1-security-group-lambda"
  description = "Security group for lambda"
  vpc_id      = var.vpc_id
}

resource "aws_iam_role" "lambda_role" {
  name                = "myapp-test1-lambda-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_function" "demo_lambda" {
  filename      = var.zipfile
  function_name = "demo-lambda-function"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.lambda_role.arn
  vpc_config {
    subnet_ids         = toset(data.aws_subnets.for_vpc.ids)
    security_group_ids = [aws_security_group.lambda_security_group.id]
  }
  environment {
    variables = {
      CACHE_CONFIG_ENDPOINT = data.aws_elasticache_replication_group.cache_replication_group.configuration_endpoint_address
      CACHE_PORT = data.aws_elasticache_replication_group.cache_replication_group.port
    }
  }
}

resource "aws_security_group_rule" "security_rule_cache_allow_lambda" {
  type                     = "ingress"
  from_port                = data.aws_elasticache_replication_group.cache_replication_group.port
  to_port                  = data.aws_elasticache_replication_group.cache_replication_group.port
  protocol                 = "tcp"
  security_group_id        = data.aws_security_group.cache_security_group.id
  description              = "Allow redis port tcp traffic into elasticache if it comes from lambda"
  source_security_group_id = aws_security_group.lambda_security_group.id
}

resource "aws_security_group_rule" "security_rule_lambda_call_out_to_cache" {
  type                     = "egress"
  from_port                = data.aws_elasticache_replication_group.cache_replication_group.port
  to_port                  = data.aws_elasticache_replication_group.cache_replication_group.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_security_group.id
  description              = "Allow redis port tcp traffic from lambda out to elasticache"
  source_security_group_id = data.aws_security_group.cache_security_group.id
}