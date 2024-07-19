resource "aws_eks_fargate_profile" "my-app" {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "my-app"
  pod_execution_role_arn = aws_iam_role.eks_fargate.arn
  subnet_ids             = local.private_subnet_ids
  selector {
    namespace = "my-app"
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_logging,
    aws_iam_role_policy_attachment.eks_fargate_pod_execution
  ]
}

#resource "aws_eks_fargate_profile" "default" {
#  cluster_name           = aws_eks_cluster.cluster.name
#  fargate_profile_name   = "default"
#  pod_execution_role_arn = aws_iam_role.eks_fargate.arn
#  subnet_ids             = local.private_subnet_ids
#  selector {
#    namespace = "default"
#  }
#  depends_on = [
#    aws_iam_role_policy_attachment.eks_fargate_logging,
#    aws_iam_role_policy_attachment.eks_fargate_pod_execution
#  ]
#}

resource "aws_eks_fargate_profile" "staging" {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "staging"
  pod_execution_role_arn = aws_iam_role.eks_fargate.arn
  subnet_ids             = local.private_subnet_ids
  selector {
    namespace = "staging"
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_logging,
    aws_iam_role_policy_attachment.eks_fargate_pod_execution
  ]
}


resource "aws_eks_fargate_profile" "kube-system" {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.eks_fargate_system.arn
  subnet_ids             = local.private_subnet_ids
  selector {
    namespace = "kube-system"
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_logging_system,
    aws_iam_role_policy_attachment.eks_fargate_pod_execution_system
  ]
}
\



