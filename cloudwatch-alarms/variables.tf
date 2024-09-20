# --- cloudwatch-alarms/variables.tf ---

variable "instance_ids" {}
variable "cpu_alarm_name" {}
variable "cpu_threshold" {}
variable "disk_alarm_name" {}
variable "disk_threshold" {}
variable "memory_alarm_name" {}
variable "memory_threshold" {}
variable "evaluation_periods" {}
variable "period" {}
variable "custom_namespace" {}
variable "notification_email" {}