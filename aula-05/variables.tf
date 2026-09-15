variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "TechNova"
}

variable "environment" {
  description = "Ambiente da infraestrutura"
  type        = string
  default     = "development"
}

variable "owner" {
  description = "RA do responsável"
  type        = string
  default     = "6325175"
}

variable "db_username" {
  description = "Usuário administrador do PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha administrador do PostgreSQL"
  type        = string
  sensitive   = true
}