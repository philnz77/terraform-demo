variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

terraform {
  backend "s3" {
    key            = "main/terraform.tfstate"
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
      Module      = "main"
    }
  }
}

resource "aws_security_group" "cache_security_group" {
  name        = "cache-security-group"
  description = "Allow inbound traffic to elasticache"
  vpc_id      = var.vpc_id
}

resource "aws_elasticache_subnet_group" "cache_subnet_group" {
  subnet_ids  = var.subnet_ids
  name        = "cache-subnet-group"
  description = "The only subnet for elasticache"
}

resource "aws_elasticache_replication_group" "cache_replication_group" {
  replication_group_id       = "elasticache-replication-group"
  description                = "Replication group for elasticache"
  engine                     = "redis"
  node_type                  = "cache.t4g.micro"
  parameter_group_name       = "default.redis7.cluster.on"
  engine_version             = "7.1"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.cache_subnet_group.name
  security_group_ids         = [aws_security_group.cache_security_group.id]
  automatic_failover_enabled = true
  num_node_groups            = 2
  replicas_per_node_group    = 1
  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  snapshot_retention_limit   = 5
  snapshot_window            = "00:00-03:00"
  multi_az_enabled           = true
  timeouts {
    create = "30m"
  }
}
