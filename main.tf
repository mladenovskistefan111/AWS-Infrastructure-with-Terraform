# --- root/main.tf ---

module "networking" {
  source             = "./networking"
  vpc_cidr           = var.vpc_cidr
  vpc_name           = var.vpc_name
  public_subnets     = var.public_subnets
  private_appsubnets = var.private_appsubnets
  private_dbsubnets  = var.private_dbsubnets
  db_subnet_group    = true
}

module "loadbalancing" {
  source                 = "./loadbalancing"
  vpc_id                 = module.networking.vpc_id
  app_security_group_id  = module.compute.app_security_group_id
  public_subnets         = module.networking.public_subnets
  tg_port                = var.tg_port
  tg_protocol            = var.tg_protocol
  lb_healthy_threshold   = var.lb_healthy_threshold
  lb_unhealthy_threshold = var.lb_unhealthy_threshold
  lb_timeout             = var.lb_timeout
  lb_interval            = var.lb_interval
  listener_port          = var.listener_port
  listener_protocol      = var.listener_protocol
}

module "database" {
  source                = "./database"
  vpc_id                = module.networking.vpc_id
  app_security_group_id = module.compute.app_security_group_id
  db_instance_count     = var.db_instance_count
  db_storage            = var.db_storage
  engine                = var.engine
  db_engine_version     = var.db_engine_version
  db_instance_class     = var.db_instance_class
  db_subnet_group_name  = module.networking.db_subnet_group_names[0]
  db_identifier         = var.db_identifier
  multi_az              = false
  skip_db_snapshot      = true
}

module "compute" {
  source               = "./compute"
  vpc_id               = module.networking.vpc_id
  lb_security_group_id = module.loadbalancing.lb_security_group_id
  private_appsubnets   = module.networking.private_appsubnets
  instance_type        = var.instance_type
  root_vol_size        = var.root_vol_size
  vol_type             = var.vol_type
  user_data_path       = "${path.root}/userdata.tpl"
  db_endpoint          = module.database.db_endpoint
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  lb_target_group_arn  = module.loadbalancing.lb_target_group_arn
  tg_port              = var.tg_port
}

module "cloudwatch-alarms" {
  source             = "./cloudwatch-alarms"
  instance_ids       = module.compute.instance_ids
  cpu_alarm_name     = var.cpu_alarm_name
  cpu_threshold      = var.cpu_threshold
  disk_alarm_name    = var.disk_alarm_name
  disk_threshold     = var.disk_threshold
  memory_alarm_name  = var.memory_alarm_name
  memory_threshold   = var.memory_threshold
  custom_namespace   = var.custom_namespace
  evaluation_periods = var.evaluation_periods
  period             = var.period
  notification_email = var.my_email
  depends_on = [module.compute]
}