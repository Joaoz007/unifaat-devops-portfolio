# --------------------------------------------------------------------------
# VPC
# --------------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------------------------------
# Subnets (criadas dinamicamente via for_each)
# --------------------------------------------------------------------------
resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.type == "public" ? true : false

  tags = {
    Name        = "${var.project_name}-${var.environment}-${each.key}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Type        = each.value.type
  }
}

# --------------------------------------------------------------------------
# Internet Gateway (para subnets publicas)
# --------------------------------------------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------------------------------
# Route Table publica + associacoes
# --------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rt-public"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in var.subnets : k => v if v.type == "public"
  }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}
