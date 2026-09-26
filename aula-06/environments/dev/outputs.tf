output "vpc_id" {
  description = "ID da VPC do ambiente dev"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets publicas do ambiente dev"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas do ambiente dev"
  value       = module.vpc.private_subnet_ids
}

output "api_sg_id" {
  description = "ID do Security Group da API"
  value       = module.api_sg.sg_id
}

output "rds_sg_id" {
  description = "ID do Security Group do RDS"
  value       = module.rds_sg.sg_id
}

output "ec2_instance_id" {
  description = "ID da instancia EC2 do ambiente dev"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "IP publico da instancia EC2 do ambiente dev"
  value       = module.ec2.public_ip
}

output "db_endpoint" {
  description = "Endpoint de conexao do banco de dados dev"
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "Porta do banco de dados dev"
  value       = module.rds.db_port
}
