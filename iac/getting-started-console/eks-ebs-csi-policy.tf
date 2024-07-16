resource "aws_iam_role" "eks_ebs_csi" {
  name = "AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = data.aws_iam_policy_document.eks_ebs_csi.json
}

data "aws_iam_policy_document" "eks_ebs_csi" {
  statement {
    sid     = "EKSEBSCSIAssumeRole"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::335687180128:oidc-provider/oidc.eks.ap-southeast-2.amazonaws.com/id/20B1EDD5BFB616EE2189BBEB39B9D879"]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.ap-southeast-2.amazonaws.com/id/20B1EDD5BFB616EE2189BBEB39B9D879:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.ap-southeast-2.amazonaws.com/id/20B1EDD5BFB616EE2189BBEB39B9D879:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_ebs_csi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_ebs_csi.name
}