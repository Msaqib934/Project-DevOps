terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
  }
}

# Configure the Kubernetes provider (EKS authentication)
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

# Configure the Helm provider to use the Kubernetes provider
provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}
