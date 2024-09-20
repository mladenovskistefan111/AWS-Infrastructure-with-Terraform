# --- loadbalancing/outputs.tf ---

output "lb_target_group_arn" {
  value = aws_lb_target_group.lb_target_group.arn
}

output "lb_endpoint" {
  value = aws_lb.loadbalancer.dns_name
}

output "lb_security_group_id" {
  value = aws_security_group.lb_security_group.id
}

