resource "aws_iam_role" "eks_fargate" {
  name               = "eks-fargate"
  assume_role_policy = data.aws_iam_policy_document.eks_fargate.json
}

resource "aws_iam_role" "eks_fargate_system" {
  name               = "eks-fargate-system"
  assume_role_policy = data.aws_iam_policy_document.eks_fargate.json
}

data "aws_iam_policy_document" "eks_fargate" {
  statement {
    sid     = "EKSFargateAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate.name
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution_system" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_system.name
}

resource "aws_iam_role_policy_attachment" "eks_fargate_logging" {
  policy_arn = aws_iam_policy.eks_fargate_logging.arn
  role       = aws_iam_role.eks_fargate.name
}

resource "aws_iam_role_policy_attachment" "eks_fargate_logging_system" {
  policy_arn = aws_iam_policy.eks_fargate_logging.arn
  role       = aws_iam_role.eks_fargate_system.name
}

