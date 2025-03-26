resource "aws_eks_cluster" "demo" {
  name     = var.name
  role_arn = aws_iam_role.demo.arn

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"  # Options: CONFIG_MAP, API, API_AND_CONFIG_MAP (if it is not set then aws_auth will not show in kubectl)
    bootstrap_cluster_creator_admin_permissions = true  # Allows cluster creator admin permissions
  }

  vpc_config {
    subnet_ids = [
      var.public_subnet_1,
      var.public_subnet_2,
      var.private_subnet_1,
      var.private_subnet_2
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.demo_amazon_eks_cluster_policy]
}