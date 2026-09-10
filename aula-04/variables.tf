
# variables.tf - Variáveis do projeto

variable "aws_region" {
  description = "Região AWS para criar os recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "technova"
}

variable "owner" {
  description = "RA do aluno responsável pela infraestrutura"
  type        = string
  default     = "6325175"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR da primeira subnet pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR da primeira subnet privada"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_cidr_2" {
  description = "CIDR da segunda subnet pública"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr_2" {
  description = "CIDR da segunda subnet privada"
  type        = string
  default     = "10.0.4.0/24"
}

variable "availability_zone" {
  description = "Primeira Availability Zone"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "Segunda Availability Zone"
  type        = string
  default     = "us-east-1b"
}

