# Variables
variable "namespace" {
  description = "namespace for monitoring"
}

variable "cluster_endpoint" {}
variable "cluster_certificate_authority" {}
variable "cluster_name" {}
variable "vpc_id" {}

variable "eks_oidc_provider_arn" {
  description = "oidc"
}


variable "service_account_loadbalancer" {
  type = string
  default = "aws-load-balancer-controller"
}

