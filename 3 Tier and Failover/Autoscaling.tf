resource "aws_launch_configuration" "as_conf" {
  name          = "web_config"
  image_id      = "ami-05056c4be032dc15b"      # bitnami"ami-05056c4be032dc15b"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.ASG1.id]
}

resource "aws_autoscaling_group" "bar" {
  name                      = "foobar3-terraform-test"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [aws_subnet.vpc-dev-private-subnet-1.id, aws_subnet.vpc-dev-private-subnet-2.id]

  tag {
    key                 = "ASG"
    value               = "ASG1"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name = aws_autoscaling_group.bar.id
  alb_target_group_arn = aws_lb_target_group.alb_target_group.arn
}

#Policy of AutoScaling

resource "aws_autoscaling_policy" "web_policy_up1" {
  name = "web_policy_up1"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.bar.name
}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up1" {
  alarm_name = "web_cpu_alarm_up1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "70"
dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bar.name
  }
alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [aws_autoscaling_policy.web_policy_up1.arn]
}
resource "aws_autoscaling_policy" "web_policy_down1" {
  name = "web_policy_down1"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.bar.name
}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down1" {
  alarm_name = "web_cpu_alarm_down1"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "30"
dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bar.name
  }
alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [aws_autoscaling_policy.web_policy_down1.arn]
}