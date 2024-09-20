# --- loadbalancing/main.tf ---

# Security Group for the Application Loadbalancer - allows inbound access on port 80

resource "aws_security_group" "lb_security_group" {
  name        = "lb_security_group"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group rule that allows the Application Loadbalancer outbound traffic to the Compute Security group

resource "aws_security_group_rule" "lb_to_app_listener_egress" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_security_group.id
  source_security_group_id = var.app_security_group_id
}

# Create Loadbalancer in Public Subnets

resource "aws_lb" "loadbalancer" {
  name            = "loadbalancer"
  subnets         = values(var.public_subnets)
  security_groups = [aws_security_group.lb_security_group.id]
  idle_timeout    = 400
}

# Configure the Loadbalancer to listen on given port and protocol

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# Create Target Group to forward traffic to the EC2 Instances and do Health Checks

resource "aws_lb_target_group" "lb_target_group" {
  name     = "lbtargetgroup"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval
    protocol            = "HTTP"
    port                = 80
    path                = "/health/"
  }
}

