# --- database/main.tf ---

# Get the Database Credentials through AWS Secrets Manager

data "aws_secretsmanager_secret" "db_secret" {
  name = "DbSecrets"
}

data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

# Create Security Group for the Database

resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "Security group for DB"
  vpc_id      = var.vpc_id
}

# Allow Inbound traffic on port 3306 from the App Security Group

resource "aws_security_group_rule" "rds_ingress_from_app" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id
  source_security_group_id = var.app_security_group_id
}

# Create the Database

resource "aws_db_instance" "db" {
  count                  = var.db_instance_count
  allocated_storage      = var.db_storage
  engine                 = var.engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)["db_name"]
  username               = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)["db_user"]
  password               = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)["db_password"]
  db_subnet_group_name   = var.db_subnet_group_name
  identifier             = "${var.db_identifier}-${count.index}"
  multi_az               = var.multi_az
  skip_final_snapshot    = var.skip_db_snapshot
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  tags = {
    Name = "db"
  }
}
