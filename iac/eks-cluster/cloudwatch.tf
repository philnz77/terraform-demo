resource "aws_cloudwatch_log_group" "eks_fargate" {
  name              = "eks-fargate-myapp"
  retention_in_days = 1
  //kms_key_id ?
}

resource "aws_cloudwatch_log_group" "eks_fargate_system" {
  name              = "eks-fargate-myapp-system"
  retention_in_days = 1
  //kms_key_id ?
}

locals {
  cloudwatch_logging_actions = [
    "logs:CreateLogStream",
    "logs:DescribeLogStreams",
    "logs:PutLogEvents"
  ]
}

data "aws_iam_policy_document" "eks_fargate_logging" {
  statement {
    resources = [
      aws_cloudwatch_log_group.eks_fargate.arn,
      "${aws_cloudwatch_log_group.eks_fargate.arn}:*"
    ]
    actions = local.cloudwatch_logging_actions
  }
}

data "aws_iam_policy_document" "eks_fargate_logging_system" {
  statement {
    resources = [
      aws_cloudwatch_log_group.eks_fargate_system.arn,
      "${aws_cloudwatch_log_group.eks_fargate_system.arn}:*"
    ]
    actions = local.cloudwatch_logging_actions
  }
}

resource "aws_iam_policy" "eks_fargate_logging" {
  name        = "eks-fargate-logging-policy"
  description = "Allow fargate running in eks to log to its dedicated cloudwatch log group for application profile"
  policy      = data.aws_iam_policy_document.eks_fargate_logging.json
}

resource "aws_iam_policy" "eks_fargate_logging_system" {
  name        = "eks-fargate-logging-policy-system"
  description = "Allow fargate running in eks to log to its dedicated cloudwatch log group for the system profiles"
  policy      = data.aws_iam_policy_document.eks_fargate_logging_system.json
}
