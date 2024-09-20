# --- networking/main.tf ---

# Create VPC

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create Public and Private subnets

resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.value.name
  }
}

resource "aws_subnet" "private_appsubnets" {
  for_each                = var.private_appsubnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = each.value.name
  }
}

resource "aws_subnet" "private_dbsubnets" {
  for_each                = var.private_dbsubnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = each.value.name
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "project_igw"
  }
}

# Create Route Table for Public Subnets

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public_rt"
  }
}

# Route the Route Table for Public Subnets to the Internet Gateway

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Associate the Route table for the Public Subnets with the Public Subnets

resource "aws_route_table_association" "public_rt_assoc" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

# Create NAT Gateway in a Public Subnet and give it EIP

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[element(keys(aws_subnet.public_subnets), 0)].id
  tags = {
    Name = "nat_gw"
  }
}

# Create App Route Table for Private App Subnets

resource "aws_route_table" "app_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "app_rt"
  }
}

# Route the App Route Table for Private App Subnets to the NAT Gateway

resource "aws_route" "natgw_route" {
  route_table_id         = aws_route_table.app_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  lifecycle {
    create_before_destroy = true
  }
}

# Associate the App Route table with the Private App Subnets

resource "aws_route_table_association" "app_rt_assoc" {
  for_each       = aws_subnet.private_appsubnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app_rt.id
}

# Create DB Route Table for Private DB Subnets

resource "aws_route_table" "db_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "db_rt"
  }
}

# Associate the DB Route table with the Private DB Subnets

resource "aws_route_table_association" "db_rt_assoc" {
  for_each       = aws_subnet.private_dbsubnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.db_rt.id
}

# Create a Subnet Group for the Database

resource "aws_db_subnet_group" "rds_subnet_group" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "rds_subnet_group"
  subnet_ids = [for subnet in aws_subnet.private_dbsubnets : subnet.id]
  tags = {
    Name = "rds_subnet_group"
  }
}
