resource "aws_eks_node_group" "mongo_nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "mongo-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    var.private_subnet_1,
    var.private_subnet_2
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    module = "database"
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes_amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.nodes_amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.nodes_amazon_ec2_container_registry_read_only,
  ]
}
