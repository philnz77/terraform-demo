variable "environment" {
  type = string
}

locals {
  region          = "ap-southeast-2"
  cluster_name    = "my-cluster"
  fargate_log_group_name = "fargate_logs"
}



