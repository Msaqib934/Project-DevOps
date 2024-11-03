resource "aws_codepipeline" "backendcodepipeline" {
  name     = "backend-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = aws_s3_bucket.ekspipeline.id
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
    name = "Build_secscan"

    action {
      name             = "Build_secscan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["secscan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.secscan.name
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
      input_artifacts  = ["secscan_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }
  stage {
    name = "Build_deploy"

    action {
      name             = "Build_deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["build_output"]
      output_artifacts = ["deploy_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.builddeploy.name
      }
    }
  }
}