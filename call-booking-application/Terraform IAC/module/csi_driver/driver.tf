#data "aws_eks_addon_version" "latest" {
#  addon_name         = "aws-ebs-csi-driver"
#  kubernetes_version = var.eks_version
#  most_recent        = true
#}

# aws eks describe-addon-versions --addon-name aws-ebs-csi-driver

resource "aws_eks_addon" "csi_driver" {
  cluster_name             = var.name
  addon_name               = "aws-ebs-csi-driver"
#  addon_version           = data.aws_eks_addon_version.latest.version
  addon_version            = "v1.37.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}

#output "latest" {
#  value = data.aws_eks_addon_version.latest.version
#}


# Metric Server, AWS VPC CNI, node_monitoring_agent, CoreDns Addon, Kube Proxy

#resource "aws_eks_addon" "metrics_server" {
#  cluster_name      = var.name
#  addon_name        = "eks-metrics-server"
#  resolve_conflicts_on_create = "OVERWRITE"
#  depends_on = [aws_eks_cluster.demo]
#}

resource "aws_eks_addon" "node_monitoring_agent" {
  cluster_name             = var.name
  addon_name               = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"
#  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name = "eks-node-monitoring"
  }

#  depends_on = [aws_eks_cluster.demo]
}

resource "aws_eks_addon" "coredns" {
  cluster_name             = var.name
  addon_name               = "coredns"
#  addon_version            = "v1.10.1-eksbuild.2"  # Check latest version on AWS
  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Name = "eks-coredns"
  }

#  depends_on = [aws_eks_cluster.demo]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                 = var.name
  addon_name                   = "vpc-cni"
#  addon_version                = "v1.14.1-eksbuild.1"  # Use the latest version available
  resolve_conflicts_on_create  = "OVERWRITE"
#  resolve_conflicts_on_update  = "PRESERVE"

  tags = {
    Name = "eks-vpc-cni"
  }

#  depends_on = [aws_eks_cluster.demo]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                 = var.name
  addon_name                   = "kube-proxy"
#  addon_version                = "v1.28.1-eksbuild.1"  # Use the latest version available
  resolve_conflicts_on_create  = "OVERWRITE"
#  resolve_conflicts_on_update  = "PRESERVE"

  tags = {
    Name = "eks-kube-proxy"
  }

#  depends_on = [aws_eks_cluster.demo]
}
