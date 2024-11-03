resource "aws_eks_cluster" "check" {
  name     = "check"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = [aws_subnet.vpc-dev-public-subnet-1.id, aws_subnet.vpc-dev-public-subnet-2.id]
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"  # Options: CONFIG_MAP, API, API_AND_CONFIG_MAP
    bootstrap_cluster_creator_admin_permissions = true  # Allows cluster creator admin permissions
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
  ]
}

# EKS node aws_eks_node_group

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.check.name
  node_group_name = "example"
  node_role_arn   = aws_iam_role.example.arn
  subnet_ids      = [aws_subnet.vpc-dev-public-subnet-1.id, aws_subnet.vpc-dev-public-subnet-2.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  instance_types = [ "t2.micro" ]

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}
