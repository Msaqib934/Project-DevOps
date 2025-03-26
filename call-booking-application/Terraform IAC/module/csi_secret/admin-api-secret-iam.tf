# Namespace
resource "kubernetes_namespace" "admin" {
  metadata {
    name = "admin"
  }
}

# Trusted entities
data "aws_iam_policy_document" "admin_secrets_csi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_arn, "https://", "")}:sub"
      values   = ["system:serviceaccount:${kubernetes_namespace.admin.metadata[0].name}:${var.service_account_admin}"]
    }

    principals {
      identifiers = [var.eks_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

# Role
resource "aws_iam_role" "admin_secrets_csi" {
  assume_role_policy = data.aws_iam_policy_document.admin_secrets_csi_assume_role_policy.json
  name               = "admin-secrets-csi-role"
}

data "aws_secretsmanager_secret" "admin_secret" {
  name = "admin-api-secrets"
}

# Policy Attachment
resource "aws_iam_role_policy_attachment" "admin_secrets_csi" {
  policy_arn = aws_iam_policy.secrets_csi.arn
  role       = aws_iam_role.admin_secrets_csi.name
}

# Service Account
resource "kubectl_manifest" "admin_secrets_csi_sa" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${var.service_account_admin}
  namespace: admin
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.admin_secrets_csi.arn}
YAML

  depends_on = [kubernetes_namespace.admin]
}