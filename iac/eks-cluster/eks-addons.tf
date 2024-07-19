resource "aws_eks_addon" "vpc_cni" {
  addon_name                  = "vpc-cni"
  cluster_name                = aws_eks_cluster.cluster.name
  addon_version               = data.aws_eks_addon_version.vpc_cni.version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  addon_name                  = "kube-proxy"
  cluster_name                = aws_eks_cluster.cluster.name
  addon_version               = data.aws_eks_addon_version.kube_proxy.version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  addon_name                  = "coredns"
  cluster_name                = aws_eks_cluster.cluster.name
  addon_version               = data.aws_eks_addon_version.coredns.version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [
    aws_eks_fargate_profile.kube-system
  ]
#  configuration_values = jsonencode({
#    replicaCount = 2
#    resources = {
#      limits = {
#        cpu    = "100m"
#        memory = "150Mi"
#      }
#      requests = {
#        cpu    = "100m"
#        memory = "150Mi"
#      }
#    }
#  })
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  addon_name                  = "eks-pod-identity-agent"
  cluster_name                = aws_eks_cluster.cluster.name
  addon_version               = data.aws_eks_addon_version.eks_pod_identity_agent.version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
}

