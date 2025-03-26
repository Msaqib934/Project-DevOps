# Define the trust relationship
data "aws_iam_policy_document" "eks_trust_relationship" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_arn, "https://", "")}:sub"
      values   = ["system:serviceaccount:loki:loki"]
    }

    principals {
      identifiers = [var.eks_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

# Create the IAM role
resource "aws_iam_role" "eks_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_trust_relationship.json
  name               = "loki-role"
}

# Attach Administrator Access policy to the role
resource "aws_iam_role_policy_attachment" "admin_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}