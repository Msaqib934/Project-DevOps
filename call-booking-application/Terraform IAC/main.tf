module "vpc" {
    source = "./module/vpc"
    vpc_cidr="10.0.0.0/16"
    public_subnet_1="10.0.1.0/24"
    public_subnet_2="10.0.2.0/24"
    private_subnet_1="10.0.3.0/24"
    private_subnet_2="10.0.4.0/24"
    zone_1="us-east-1a"
    zone_2="us-east-1b"
    region="us-east-1"
}

module "eks" {
    source           = "./module/EKS_Cluster"
    name             = "demo"
    public_subnet_1  = module.vpc.vpc_dev_public_subnet_1 
    public_subnet_2  = module.vpc.vpc_dev_public_subnet_2
    private_subnet_1 = module.vpc.vpc_dev_private_subnet_1
    private_subnet_2 = module.vpc.vpc_dev_private_subnet_2  
}

module "csi_driver" {
  source            = "./module/csi_driver"
  name              = module.eks.eks_cluster_name
  eks_oidc_issuer   = module.eks.eks_oidc_issuer
#  eks_version      = module.eks.eks_version
  depends_on = [module.eks]
}


module "csi_secret" {
  source                          = "./module/csi_secret"  # Path to your CSI Secret module
  eks_oidc_provider_arn           = module.csi_driver.eks_oidc_provider_arn
  # other variables
  cluster_endpoint                = module.eks.cluster_endpoint
  cluster_certificate_authority   = module.eks.cluster_certificate_authority
  cluster_name                    = module.eks.eks_cluster_name
}

module "monitoring" {
  source                          = "./module/monitoring"  # Path to your CSI Secret module
  cluster_endpoint                = module.eks.cluster_endpoint
  cluster_certificate_authority   = module.eks.cluster_certificate_authority
  cluster_name                    = module.eks.eks_cluster_name
  eks_oidc_provider_arn           = module.csi_driver.eks_oidc_provider_arn
  vpc_id                          = module.vpc.vpc_id
  namespace                       = "monitoring"
}




#terraform apply -target="module.vpc" -target="module.EKS_Cluster" -target="module.csi_driver"

#terraform apply -target="module.csi_secret"