resource "aws_eks_cluster" "cluster" {
  name     = local.cluster_name
  version  = local.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    #todo this may need to be set to true
    #something to do with private route 53 hosted zones, openvpn on ubuntu?
    endpoint_private_access = true
    #if we still need to use a public endpoint we can restrict access with cidr blocks
    endpoint_public_access = true
    public_access_cidrs    = ["0.0.0.0/0"]

    subnet_ids = local.subnet_ids
  }


  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
    #    aws_security_group_rule.cluster,
    #    aws_security_group_rule.node,
    #    aws_cloudwatch_log_group.this,
    #    aws_iam_policy.cni_ipv6_policy,
  ]
}
