# Create an ECS Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]  # If you're using Fargate
  cpu                      = "256"        # CPU units (256 = 0.25 vCPU)
  memory                   = "512"        # Memory in MiB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role2.arn

  container_definitions = jsonencode([
    {
      name      = "backend-container"
      image     = "824813378441.dkr.ecr.us-east-1.amazonaws.com/backend"                 # Change this to your desired container image
      essential = true

      portMappings = [
        {
          containerPort = 10000
          hostPort      = 10000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "TODOTABLE_NAME"
          value = "todotable"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/backend"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# Create a log group for ECS container logs
resource "aws_cloudwatch_log_group" "backendecs" {
  name              = "/ecs/backend"
  retention_in_days = 7
}


# Create an ECS Service (optional, if you need to run the task)
resource "aws_ecs_service" "backend" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.vpc-dev-private-subnet-1.id, aws_subnet.vpc-dev-private-subnet-2.id]
    security_groups = [aws_security_group.allow.id]
    assign_public_ip = true
  }

  # Enable Service Discovery using your existing Cloud Map service
  service_registries {
    registry_arn = aws_service_discovery_service.example.arn  # Reference your Cloud Map service ARN
  }
}