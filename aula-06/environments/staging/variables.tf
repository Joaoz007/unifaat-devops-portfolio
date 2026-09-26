variable "aws_region" {
  description = "Regiao AWS onde os recursos serao criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto TechNova"
  type        = string
  default     = "technova"
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "staging"
}

variable "vpc_cidr" {
  description = "Bloco CIDR principal da VPC de staging"
  type        = string
  default     = "10.1.0.0/16"
}

variable "ami_id" {
  description = "ID da AMI Amazon Linux 2023 para us-east-1"
  type        = string
}

variable "key_name" {
  description = "Nome do Key Pair AWS criado previamente na conta"
  type        = string
}

variable "db_username" {
  description = "Usuario administrador do banco PostgreSQL"
  type        = string
  default     = "technova_admin"
}

variable "db_password" {
  description = "Senha do usuario administrador do banco PostgreSQL"
  type        = string
  sensitive   = true
}
