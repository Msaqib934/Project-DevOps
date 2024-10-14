# Create an ECS Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]  # If you're using Fargate
  cpu                      = "256"        # CPU units (256 = 0.25 vCPU)
  memory                   = "512"        # Memory in MiB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role2.arn

  container_definitions = jsonencode([
    {
      name      = "frontend-container"
      image     = "824813378441.dkr.ecr.us-east-1.amazonaws.com/frontend"                 # Change this to your desired container image
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/frontend"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# Create a log group for ECS container logs
resource "aws_cloudwatch_log_group" "frontendecs" {
  name              = "/ecs/frontend"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false  # Allows recreation if needed, optional
    create_before_destroy = true  # Creates a new resource before deleting the old one
  }
}


# Create an ECS Service (optional, if you need to run the task)
resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.vpc-dev-private-subnet-1.id, aws_subnet.vpc-dev-private-subnet-2.id]
    security_groups = [aws_security_group.allow.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "frontend-container"
    container_port   = 80
  }
}

resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow.id]
  subnets            = [aws_subnet.vpc-dev-public-subnet-1.id, aws_subnet.vpc-dev-public-subnet-2.id]
}

# Target Group
resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-dev.id
  target_type = "ip"
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_security_group" "allow" {
  name        = "allow"
  description = "Security group that allows all inbound and outbound traffic"
  vpc_id      = aws_vpc.vpc-dev.id  # Replace with your VPC ID

  # Allow all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allows traffic from any IP address
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allows traffic to any IP address
  }

  tags = {
    Name = "allow_all_traffic"
  }
}

