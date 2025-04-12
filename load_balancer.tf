resource "aws_lb" "app_alb" {
  name               = "csye6225-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_security_group.id]
  subnets            = aws_subnet.public_subnet[*].id
}

resource "aws_lb_target_group" "app_target_group" {
  name     = "csye6225-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.csye6225_vpc.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    protocol            = "HTTP"
    path                = "/healthz"
    matcher             = "200-399"
  }
}

# resource "aws_lb_listener" "app_listener" {
#   load_balancer_arn = aws_lb.app_alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_target_group.arn
#   }
# }


resource "aws_lb_listener" "app_listener_https" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  # Use the dev certificate ARN if profile is "dev", otherwise use the demo certificate ARN.
  certificate_arn = var.Profile == "dev" ? var.dev_certificate_arn : var.demo_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
