resource "aws_codepipeline" "frontcodepipeline" {
  name     = "front-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = aws_s3_bucket.frontpipeline.id
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
        OAuthToken       = "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"
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
        ProjectName = aws_codebuild_project.frontend.name
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
        ServiceName          = aws_ecs_service.frontend.name
        FileName             = "imagedefinitions.json"  # Required if ECS service is set up to use image definitions
      }
    }
  }
}
