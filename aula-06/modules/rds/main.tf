# --------------------------------------------------------------------------
# DB Subnet Group
# --------------------------------------------------------------------------
resource "aws_db_subnet_group" "this" {
  name        = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "DB Subnet Group para ${var.project_name} - ${var.environment}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------------------------------
# RDS PostgreSQL
# --------------------------------------------------------------------------
resource "aws_db_instance" "this" {
  identifier             = "${var.project_name}-${var.environment}-postgres"
  engine                 = "postgres"
  engine_version         = "15.7"
  instance_class         = var.instance_class
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
