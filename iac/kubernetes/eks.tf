resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster-${local.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_eks_cluster" "cluster" {
  name     = local.cluster_name
  version  = local.cluster_version
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {
    #todo this may need to be set to true
    #something to do with private route 53 hosted zones, openvpn on ubuntu?
    endpoint_private_access = false
    #if we still need to use a public endpoint we can restrict access with cidr blocks
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]

    subnet_ids = [
      # fargate can only use private subnets (with nat gateway) to deploy your pods
      aws_subnet.private-zone-a.id,
      aws_subnet.private-zone-b.id,
      # public subnets can be used for load balancers to expose your app to the internet
      aws_subnet.public-zone-a.id,
      aws_subnet.public-zone-b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.amazon-eks-cluster-policy]
}
