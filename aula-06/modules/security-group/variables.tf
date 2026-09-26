variable "name" {
  description = "Nome base do Security Group"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o Security Group sera criado"
  type        = string
}

variable "ingress_rules" {
  description = "Lista de regras de entrada do Security Group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "environment" {
  description = "Nome do ambiente (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado em tags)"
  type        = string
}
