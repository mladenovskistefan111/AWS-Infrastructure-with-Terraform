# --- root/variables.tf ---

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {}
variable "vpc_name" {}
variable "public_subnets" {}
variable "private_appsubnets" {}
variable "private_dbsubnets" {}

variable "tg_port" {}
variable "tg_protocol" {}
variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}
variable "listener_port" {}
variable "listener_protocol" {}

variable "db_instance_count" {}
variable "db_storage" {}
variable "engine" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "db_identifier" {}

variable "instance_type" {}
variable "root_vol_size" {}
variable "vol_type" {}
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}

variable "cpu_alarm_name" {}
variable "cpu_threshold" {}
variable "disk_alarm_name" {}
variable "disk_threshold" {}
variable "memory_alarm_name" {}
variable "memory_threshold" {}
variable "custom_namespace" {}
variable "evaluation_periods" {}
variable "period" {}
variable "my_email" {}