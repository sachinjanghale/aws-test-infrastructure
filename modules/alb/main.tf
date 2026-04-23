# ALB/NLB Module

# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.common_tags, { Name = "${var.project_name}-alb", Type = "ALB" })
}

# ALB Target Group
resource "aws_lb_target_group" "alb_http" {
  name     = "${var.project_name}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-alb-tg" })
}

# ALB Target Group Attachment
resource "aws_lb_target_group_attachment" "alb" {
  count            = var.enable_ec2_attachment ? 1 : 0
  target_group_arn = aws_lb_target_group.alb_http.arn
  target_id        = var.ec2_instance_id
  port             = 80
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_http.arn
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-alb-listener" })
}

# ALB Listener Rule
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_http.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-alb-rule" })
}

# Network Load Balancer
resource "aws_lb" "nlb" {
  name               = "${var.project_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.common_tags, { Name = "${var.project_name}-nlb", Type = "NLB" })
}

# NLB Target Group
resource "aws_lb_target_group" "nlb_tcp" {
  name     = "${var.project_name}-nlb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id

  tags = merge(var.common_tags, { Name = "${var.project_name}-nlb-tg" })
}

# NLB Listener
resource "aws_lb_listener" "nlb_tcp" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tcp.arn
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-nlb-listener" })
}
