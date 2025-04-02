resource "aws_autoscaling_group" "asg" {
  name             = "csye6225_asg"
  min_size         = 3
  max_size         = 5
  desired_capacity = 3
  default_cooldown = 60

  launch_template {
    id      = aws_launch_template.csye6225_asg.id
    version = "$Latest"
  }

  # Distribute instances across all public subnets; adjust if necessary.
  vpc_zone_identifier = aws_subnet.public_subnet[*].id

  # Associate the target group with the ASG so that instances register with the ALB
  target_group_arns = [
    aws_lb_target_group.app_target_group.arn
  ]

  tag {
    key                 = "AutoScalingGroup TagPropertyLinks"
    value               = "csye6225"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale_up"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale_down"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 7

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Alarm when CPU exceeds 7%"
  alarm_actions     = [aws_autoscaling_policy.scale_up_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low_alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 3

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Alarm when CPU is below 3%"
  alarm_actions     = [aws_autoscaling_policy.scale_down_policy.arn]
}
