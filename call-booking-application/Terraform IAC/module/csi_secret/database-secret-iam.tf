# Namespace
resource "kubernetes_namespace" "database" {
  metadata {
    name = "database"
  }
}

# Trusted entities
data "aws_iam_policy_document" "database_secrets_csi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_arn, "https://", "")}:sub"
      values   = ["system:serviceaccount:${kubernetes_namespace.database.metadata[0].name}:${var.service_account_database}"]
    }

    principals {
      identifiers = [var.eks_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

# Role
resource "aws_iam_role" "database_secrets_csi" {
  assume_role_policy = data.aws_iam_policy_document.database_secrets_csi_assume_role_policy.json
  name               = "database-secrets-csi-role"
}

data "aws_secretsmanager_secret" "database_secret" {
  name = "mongo-db-secrets"
}

# Policy Attachment
resource "aws_iam_role_policy_attachment" "database_secrets_csi" {
  policy_arn = aws_iam_policy.secrets_csi.arn
  role       = aws_iam_role.database_secrets_csi.name
}

# Service Account
resource "kubectl_manifest" "database_secrets_csi_sa" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${var.service_account_database}
  namespace: database
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.database_secrets_csi.arn}
YAML

  depends_on = [kubernetes_namespace.database]
}