# For Codebuild Roles

resource "aws_iam_role" "codebuild_service_role" {
  name = "codebuild_service_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "codebuild.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attach" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # Attach necessary policies here
}

# For Codepipeline


resource "aws_iam_role" "pipeline" {
  name = "pipeline"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"  # Allow CodePipeline
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"  # Allow CodeBuild
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "codebuild_service_role_policy" {
  role       = aws_iam_role.pipeline.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


# For ECS task_definition

resource "aws_iam_role" "ecs_task_execution_role2" {
  name = "ecs_task_execution_role2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Attach the Amazon ECS Task Execution Role Policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach the Amazon DynamoDB Full Access Policy
resource "aws_iam_role_policy_attachment" "dynamodb_full_access_policy" {
  role       = aws_iam_role.ecs_task_execution_role2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
