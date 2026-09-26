# --------------------------------------------------------------------------
# VPC
# --------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment

  subnets = {
    "public-1a" = {
      cidr = "10.0.1.0/24"
      az   = "${var.aws_region}a"
      type = "public"
    }
    "public-1b" = {
      cidr = "10.0.2.0/24"
      az   = "${var.aws_region}b"
      type = "public"
    }
    "private-1a" = {
      cidr = "10.0.3.0/24"
      az   = "${var.aws_region}a"
      type = "private"
    }
    "private-1b" = {
      cidr = "10.0.4.0/24"
      az   = "${var.aws_region}b"
      type = "private"
    }
  }
}

# --------------------------------------------------------------------------
# Security Group — API (EC2)
# --------------------------------------------------------------------------
module "api_sg" {
  source = "../../modules/security-group"

  name         = "api-sg"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment  = var.environment

  ingress_rules = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# --------------------------------------------------------------------------
# Security Group — RDS (PostgreSQL)
# --------------------------------------------------------------------------
module "rds_sg" {
  source = "../../modules/security-group"

  name         = "rds-sg"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment  = var.environment

  ingress_rules = [
    {
      description = "PostgreSQL a partir do SG da API"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
}

# --------------------------------------------------------------------------
# EC2 — Servidor da API
# --------------------------------------------------------------------------
module "ec2" {
  source = "../../modules/ec2"

  instance_name      = "${var.project_name}-${var.environment}-api"
  instance_type      = "t2.micro"
  ami_id             = var.ami_id
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.api_sg.sg_id]
  key_name           = var.key_name
  environment        = var.environment
  project_name       = var.project_name
}

# --------------------------------------------------------------------------
# RDS — PostgreSQL
# --------------------------------------------------------------------------
module "rds" {
  source = "../../modules/rds"

  db_name            = "technova_dev"
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.rds_sg.sg_id]
  instance_class     = "db.t3.micro"
  environment        = var.environment
  project_name       = var.project_name
}
