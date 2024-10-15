resource "aws_launch_configuration" "as_conf1" {
  name          = "web_config1"
  image_id      = "ami-053b0d53c279acc90"           #"ami-04cb4ca688797756f"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.ASG2.id]
  user_data       = file("userdata.sh")
}

resource "aws_autoscaling_group" "bar1" {
  name                      = "foobar3-terraform-test1"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.as_conf1.name
  vpc_zone_identifier       = [aws_subnet.vpc-dev-private-subnet-1.id, aws_subnet.vpc-dev-private-subnet-2.id]

  tag {
    key                 = "AutoScale"
    value               = "ASG2"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_elb1" {
  autoscaling_group_name = aws_autoscaling_group.bar1.id
  alb_target_group_arn = aws_lb_target_group.alb_target_group1.arn
}


#Policy of AutoScaling

resource "aws_autoscaling_policy" "web_policy_up" {
  name = "web_policy_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.bar1.name
}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "70"
dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bar1.name
  }
alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [aws_autoscaling_policy.web_policy_up.arn]
}
resource "aws_autoscaling_policy" "web_policy_down" {
  name = "web_policy_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.bar1.name
}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "30"
dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bar1.name
  }
alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [aws_autoscaling_policy.web_policy_down.arn]
}