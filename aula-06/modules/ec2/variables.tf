variable "instance_name" {
  description = "Nome da instancia EC2 (usado na tag Name)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID da AMI a usar para a instancia"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet onde a instancia sera lancada"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de IDs dos Security Groups a associar a instancia"
  type        = list(string)
}

variable "key_name" {
  description = "Nome do Key Pair AWS para acesso SSH"
  type        = string
}

variable "user_data" {
  description = "Script user_data a executar na inicializacao da instancia (opcional)"
  type        = string
  default     = null
}

variable "environment" {
  description = "Nome do ambiente (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado em tags)"
  type        = string
}
