# create application load balancer
resource "aws_lb" "application_load_balancer" {
  name               = "ELB-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ELB1.id]
  subnets            = [aws_subnet.vpc-dev-public-subnet-1.id, aws_subnet.vpc-dev-public-subnet-2.id]
  enable_deletion_protection = false

  tags   = {
    Name = "elb1"
  }
}

# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "targetgroup"
  target_type = "instance"
  port        = 80 
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-dev.id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    type = "forward"
  }
}