# Namespace
#resource "kubernetes_namespace" "my-namespace" {
#  metadata {
#    name = "my-namespace"
#  }
#}

data "kubernetes_namespace" "default" {
  metadata {
    name = "default"
  }
  depends_on = [var.eks_oidc_provider_arn]
}

# Trusted entities
data "aws_iam_policy_document" "secrets_csi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_arn, "https://", "")}:sub"
      values   = ["system:serviceaccount:${data.kubernetes_namespace.default.metadata[0].name}:${var.service_account_name}"]
    }

    principals {
      identifiers = [var.eks_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

# Role
resource "aws_iam_role" "secrets_csi" {
  assume_role_policy = data.aws_iam_policy_document.secrets_csi_assume_role_policy.json
  name               = "secrets-csi-role"
}

# Policy
resource "aws_iam_policy" "secrets_csi" {
  name = "secrets-csi-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = "*"
    }]
  })
}

#data "aws_secretsmanager_secret" "secrets_csi" {
#  name = "git2"
#}

# Policy Attachment
resource "aws_iam_role_policy_attachment" "secrets_csi" {
  policy_arn = aws_iam_policy.secrets_csi.arn
  role       = aws_iam_role.secrets_csi.name
}

# Service Account
resource "kubectl_manifest" "secrets_csi_sa" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${var.service_account_name}
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.secrets_csi.arn}
YAML

  depends_on = [data.kubernetes_namespace.default]
}