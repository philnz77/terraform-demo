resource "aws_cloudwatch_log_group" "elasticache" {
  name              = "elasticache_logs"
  retention_in_days = 1
  //kms_key_id ?
}