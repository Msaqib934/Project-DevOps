data "kubernetes_namespace" "kube-system" {
  metadata {
    name = "kube-system"
  }
  depends_on = [var.eks_oidc_provider_arn]
}

# Trusted entities
data "aws_iam_policy_document" "loadbalancer_secrets_csi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_arn, "https://", "")}:sub"
      values   = ["system:serviceaccount:${data.kubernetes_namespace.kube-system.metadata[0].name}:${var.service_account_loadbalancer}"]
    }

    principals {
      identifiers = [var.eks_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

# Role
resource "aws_iam_role" "loadbalancer_secrets_csi" {
  assume_role_policy = data.aws_iam_policy_document.loadbalancer_secrets_csi_assume_role_policy.json
  name               = "database-secrets-csi-role"
}

# Policy Attachment
resource "aws_iam_role_policy_attachment" "loadbalancer_secrets_csi" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.loadbalancer_secrets_csi.name
}

# Service Account
resource "kubectl_manifest" "loadbalancer_secrets_csi_sa" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${var.service_account_loadbalancer}
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.loadbalancer_secrets_csi.arn}
YAML

  depends_on = [data.kubernetes_namespace.kube-system]
}


resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_loadbalancer
  }
}
