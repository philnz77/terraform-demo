resource "aws_cloudwatch_log_group" "eks_fargate" {
  name              = local.fargate_log_group_name
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


resource "aws_iam_policy" "eks_fargate_logging" {
  name        = "eks-fargate-logging-policy"
  description = "Allow fargate running in eks to log to its dedicated cloudwatch log group for application profile"
  policy      = data.aws_iam_policy_document.eks_fargate_logging.json
}
