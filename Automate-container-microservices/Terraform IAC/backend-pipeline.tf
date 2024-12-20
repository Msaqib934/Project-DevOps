resource "aws_codepipeline" "backendcodepipeline" {
  name     = "backend-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = aws_s3_bucket.backendpipeline.id
    type     = "S3"
  }
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "Msaqib934"
        Repo       = "automate-container-microservices-aws-copilot"
        Branch           = "main"
        OAuthToken       = "Enter Token Here"
      }
    }
  }
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.backend.name
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      name             = "DeployAction"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      version          = "1"
      input_artifacts  = ["build_output"]

      configuration = {
        ClusterName          = aws_ecs_cluster.example.name
        ServiceName          = aws_ecs_service.backend.name
        FileName             = "imagedefinitions.json"  # Required if ECS service is set up to use image definitions
      }
    }
  }
}
