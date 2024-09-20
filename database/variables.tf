# --- database/variables.tf ---

variable "vpc_id" {}
variable "app_security_group_id" {}
variable "db_instance_count" {}
variable "db_storage" {}
variable "engine" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "db_subnet_group_name" {}
variable "db_identifier" {}
variable "multi_az" {}
variable "skip_db_snapshot" {}