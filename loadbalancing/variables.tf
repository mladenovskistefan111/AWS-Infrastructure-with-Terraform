# --- loadbalancing/loadbalancing.tf ---

variable "vpc_id" {}
variable "app_security_group_id" {}
variable "public_subnets" {}
variable "tg_port" {}
variable "tg_protocol" {}
variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}
variable "listener_port" {}
variable "listener_protocol" {}
