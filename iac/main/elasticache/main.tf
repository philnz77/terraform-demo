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
  log_delivery_configuration {
    destination = aws_cloudwatch_log_group.elasticache.name
    destination_type = "cloudwatch-logs"
    log_format = "json"
    log_type = "slow-log"
  }
  log_delivery_configuration {
    destination = aws_cloudwatch_log_group.elasticache.name
    destination_type = "cloudwatch-logs"
    log_format = "json"
    log_type = "engine-log"
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
