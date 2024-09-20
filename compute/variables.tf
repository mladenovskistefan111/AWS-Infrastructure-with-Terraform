# --- compute/variables.tf ---

variable "vpc_id" {}
variable "lb_security_group_id" {}
variable "private_appsubnets" {}
variable "instance_type" {}
variable "root_vol_size" {}
variable "vol_type" {}
variable "user_data_path" {}
variable "db_endpoint" {}
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}
variable "lb_target_group_arn" {}
variable "tg_port" {}
