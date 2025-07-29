#######################################
# Application Load Balancer (ALB)
#######################################
resource "aws_lb" "frontend_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_cluster_sg.id]
  subnets            = [for s in aws_subnet.public : s.id] # <-- Ensure you have public subnets!

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

#######################################
# Target Group for ALB
#######################################
resource "aws_lb_target_group" "frontend_tg" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

#######################################
# ALB Listener for HTTP
#######################################
resource "aws_lb_listener" "frontend_http_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}
