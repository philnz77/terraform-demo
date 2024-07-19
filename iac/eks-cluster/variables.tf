variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

locals {
  region          = "ap-southeast-2"
  zoneA           = "ap-southeast-2a"
  zoneB           = "ap-southeast-2b"
  cluster_name    = "my-cluster"
  cluster_version = "1.30"

  subnet_ids = [
    # fargate can only use private subnets (with nat gateway) to deploy your pods
    aws_subnet.private-zone-a.id,
    aws_subnet.private-zone-b.id,
    # public subnets can be used for load balancers to expose your app to the internet
    aws_subnet.public-zone-a.id,
    aws_subnet.public-zone-b.id
  ]
  private_subnet_ids = [
    # fargate can only use private subnets (with nat gateway) to deploy your pods
    aws_subnet.private-zone-a.id,
    aws_subnet.private-zone-b.id,
  ]
}


