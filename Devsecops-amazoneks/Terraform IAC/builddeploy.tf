resource "aws_codebuild_source_credential" "builddeploy" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "Enter Token Here"
}

resource "aws_codebuild_project" "builddeploy" {
  name          = "builddeploy-project"
  build_timeout = 30

  source {
    type            = "GITHUB"
    location        = "https://github.com/build-on-aws/automate-container-microservices-aws-copilot.git"
    buildspec       = "buildspec/buildspec_deploy.yml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  artifacts {
  type = "NO_ARTIFACTS"
  }

  depends_on = [
    aws_eks_cluster.check,
    aws_eks_node_group.example
  ]

  service_role = aws_iam_role.codebuild_service_role.arn
}