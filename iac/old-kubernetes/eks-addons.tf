resource "aws_eks_addon" "vpc_cni" {
  addon_name = "vpc-cni"
  cluster_name = aws_eks_cluster.cluster.name
  addon_version = data.aws_eks_addon_version.vpc_cni.version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  addon_name = "kube-proxy"
  cluster_name = aws_eks_cluster.cluster.name
  addon_version = data.aws_eks_addon_version.kube_proxy.version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  addon_name = "coredns"
  cluster_name = aws_eks_cluster.cluster.name
  addon_version = data.aws_eks_addon_version.coredns.version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  addon_name = "eks-pod-identity-agent"
  cluster_name = aws_eks_cluster.cluster.name
  addon_version = data.aws_eks_addon_version.eks_pod_identity_agent.version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
}

