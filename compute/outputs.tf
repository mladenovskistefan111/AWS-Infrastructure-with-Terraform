# --- compute/outputs.tf ---

output "app_security_group_id" {
  value = aws_security_group.app_security_group.id
}

output "instance_ids" {
  value = data.aws_instances.app_instances.ids
}