variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

#locals {
#  region = "ap-southeast-2"
#  zoneA = "ap-southeast-2a"
#  zoneB = "ap-southeast-2b"
#  cluster_name = "my-cluster"
#  cluster_version = "1.30"
#}
