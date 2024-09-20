vpc_cidr = "10.10.0.0/16"
vpc_name = "project_vpc"
public_subnets = {
  subnet_a = {
    cidr_block        = "10.10.2.0/24"
    availability_zone = "us-east-1a"
    name              = "public_subnet_a"
  }
  subnet_b = {
    cidr_block        = "10.10.4.0/24"
    availability_zone = "us-east-1b"
    name              = "public_subnet_b"
  }
}
private_appsubnets = {
  subnet_a = {
    cidr_block        = "10.10.1.0/24"
    availability_zone = "us-east-1a"
    name              = "app_subnet_a"
  }
  subnet_b = {
    cidr_block        = "10.10.3.0/24"
    availability_zone = "us-east-1b"
    name              = "app_subnet_b"
  }
}
private_dbsubnets = {
  subnet_a = {
    cidr_block        = "10.10.5.0/24"
    availability_zone = "us-east-1a"
    name              = "db_subnet_a"
  }
  subnet_b = {
    cidr_block        = "10.10.7.0/24"
    availability_zone = "us-east-1b"
    name              = "db_subnet_b"
  }
}

tg_port                = 80
tg_protocol            = "HTTP"
lb_healthy_threshold   = 2
lb_unhealthy_threshold = 2
lb_timeout             = 5
lb_interval            = 30
listener_port          = 80
listener_protocol      = "HTTP"

db_instance_count = 1
db_storage        = 10
engine            = "mysql"
db_engine_version = "8.0.35"
db_instance_class = "db.t3.micro"
db_identifier     = "db"

instance_type     = "t2.micro"
root_vol_size     = 20
vol_type          = "gp2"
min_size          = 2
max_size          = 2
desired_capacity  = 2

cpu_alarm_name     = "cpu_usage_above_80"
cpu_threshold      = 80
disk_alarm_name    = "disk_usage_above_80"
disk_threshold     = 80
memory_alarm_name  = "memory_usage_above_80"
memory_threshold   = 80
custom_namespace   = "Disk/Memory"
evaluation_periods = 1
period             = 300
my_email           = "mladenovskistefan111@gmail.com"

