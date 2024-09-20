# --- cloudwatch-alarms/outputs.tf ---

output "cpu_alarm_names" {
  value = [for alarm in aws_cloudwatch_metric_alarm.cpu_alarm : alarm.alarm_name]
}

output "disk_alarm_names" {
  value = [for alarm in aws_cloudwatch_metric_alarm.disk_alarm : alarm.alarm_name]
}

output "memory_alarm_names" {
  value = [for alarm in aws_cloudwatch_metric_alarm.memory_alarm : alarm.alarm_name]
}