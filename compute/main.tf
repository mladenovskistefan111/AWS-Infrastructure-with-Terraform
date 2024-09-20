# --- compute/main.tf ---

data "aws_autoscaling_group" "app_asg" {
  name = aws_autoscaling_group.app_asg.name
}

data "aws_instances" "app_instances" {
  instance_tags = {
    "aws:autoscaling:groupName" = aws_autoscaling_group.app_asg.name
  }
}

# Get the Database Credentials through AWS Secrets Manager

data "aws_secretsmanager_secret" "db_secret" {
  name = "DbSecrets"
}

data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

# Create Security Group for the EC2 Instances

resource "aws_security_group" "app_security_group" {
  name        = "app_security_group"
  description = "Security group for APP"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow access from the Loadbalancer Security Group

resource "aws_security_group_rule" "app_from_lb_listener_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_security_group.id
  source_security_group_id = var.lb_security_group_id
}

# Data block to retrieve the latest Amazon Linux 2023 AMI

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.5.*.0-kernel-6.1-x86_64"]
  }
}

# Create Launch Template for the Auto Scaling Group

resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-launch-template"
  image_id      = data.aws_ami.server_ami.id
  instance_type = var.instance_type
  iam_instance_profile {
    name = aws_iam_instance_profile.app_profile.name
  }
  vpc_security_group_ids = [aws_security_group.app_security_group.id]
  user_data = base64encode(templatefile(var.user_data_path,
    {
      dbname      = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)["db_name"]
      dbuser      = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)["db_user"]
      dbpassword  = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)["db_password"]
      db_endpoint = var.db_endpoint[0]
    }
  ))
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_vol_size
      volume_type           = var.vol_type
      delete_on_termination = true
    }
  }
}

# Create the Auto Scaling Group

resource "aws_autoscaling_group" "app_asg" {
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  name                      = "app"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = values(var.private_appsubnets)
  target_group_arns         = [var.lb_target_group_arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  lifecycle {
    create_before_destroy = true
  }
}

# Create a IAM Role for the EC2 Instances

resource "aws_iam_role" "app_role" {
  name = "app_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
          ]
        }
      }
    ]
  })
}

# Create Policies for CloudWatch

resource "aws_iam_policy_attachment" "cloudwatch_agent_policy_attachment" {
  name       = "cloudwatch-agent-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  roles      = [aws_iam_role.app_role.name]
}

resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
  name       = "ssm-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  roles      = [aws_iam_role.app_role.name]
}

# Role Policy for the Loadbalancer

resource "aws_iam_role_policy" "lb_app_policy" {
  name = "lb_app_policy"
  role = aws_iam_role.app_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
        ],
        Resource = "*"
      }
    ]
  })
}

# Create Profile to attach the Role to the EC2 Instances

resource "aws_iam_instance_profile" "app_profile" {
  name = "app_profile"
  role = aws_iam_role.app_role.name
}