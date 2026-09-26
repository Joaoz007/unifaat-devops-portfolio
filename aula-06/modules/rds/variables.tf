variable "db_name" {
  description = "Nome do banco de dados PostgreSQL a criar"
  type        = string
}

variable "db_username" {
  description = "Nome do usuario administrador do banco de dados"
  type        = string
}

variable "db_password" {
  description = "Senha do usuario administrador do banco de dados"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "Lista de IDs das subnets privadas para o DB Subnet Group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Lista de IDs dos Security Groups a associar ao RDS"
  type        = list(string)
}

variable "instance_class" {
  description = "Classe da instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "environment" {
  description = "Nome do ambiente (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado em tags e nomes de recursos)"
  type        = string
}
