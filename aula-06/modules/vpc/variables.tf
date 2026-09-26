variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado em tags e nomes de recursos)"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (dev, staging, prod)"
  type        = string
}

variable "subnets" {
  description = "Mapa de subnets a criar. Cada entrada deve ter cidr, az e type ('public' ou 'private')"
  type = map(object({
    cidr = string
    az   = string
    type = string # "public" ou "private"
  }))
}
