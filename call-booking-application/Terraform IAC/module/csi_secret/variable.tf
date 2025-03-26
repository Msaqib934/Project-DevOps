variable "eks_oidc_provider_arn" {
  description = "oidc"
} 


variable "cluster_endpoint" {
  description = "cluster endpoint"
}

variable "cluster_certificate_authority" {
  description = "certificate"
}

variable "cluster_name" {
  description = "cluster name"
}

variable "service_account_name" {
  type = string
  default = "my-service-account"
}

variable "service_account_database" {
  type = string
  default = "database-service-account"
}

variable "service_account_admin" {
  type = string
  default = "admin-service-account"
}

variable "service_account_user" {
  type = string
  default = "user-service-account"
}


