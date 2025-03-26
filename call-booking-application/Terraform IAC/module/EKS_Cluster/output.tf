output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.demo.name
}

output "eks_oidc_issuer" {
  value = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

#output "eks_version" {
#  description = "The Kubernetes version of the EKS cluster"
#  value       = aws_eks_cluster.check.version
#}


#these are for csi secret driver

output "cluster_endpoint" {
  value = aws_eks_cluster.demo.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.demo.certificate_authority[0].data
}