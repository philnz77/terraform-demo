module "elasticache" {
  source = "./elasticache"
  vpc_id = var.vpc_id
  environment = var.environment
  subnet_ids = var.subnet_ids
}

module "eks-cluster" {
  source = "./eks-cluster"
  vpc_id = var.vpc_id
  environment = var.environment
}