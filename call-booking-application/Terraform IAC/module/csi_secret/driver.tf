# CSI Driver
resource "helm_release" "secrets-store-csi-driver" {
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
#  version    = "1.3.4"
  namespace  = "kube-system"
  timeout    = 10 * 60

  values = [
    <<VALUES
    syncSecret:
      enabled: true   # Install RBAC roles and bindings required for K8S Secrets syncing if true (default: false)
VALUES
  ]
}


# CSI Provider
resource "helm_release" "aws_secrets_manager" {
  name       = "aws-secrets-manager"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"  # Or the specific chart name if different
  namespace  = "kube-system" # Or your desired namespace
}
