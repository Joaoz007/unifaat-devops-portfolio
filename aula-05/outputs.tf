output "vpc_id" {
  description = "ID da VPC da TechNova"
  value       = aws_vpc.main.id
}

output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.api.public_ip
}

output "ec2_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.api.public_dns
}

output "rds_endpoint" {
  description = "Endpoint do PostgreSQL RDS"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "Porta do PostgreSQL RDS"
  value       = aws_db_instance.postgres.port
}

output "rds_database" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.postgres.db_name
}

output "s3_state_bucket" {
  description = "Bucket S3 utilizado pelo Remote State"
  value       = "technova-terraform-state-6325175"
}

output "dynamodb_lock_table" {
  description = "Tabela DynamoDB utilizada para locking"
  value       = aws_dynamodb_table.terraform_lock.name
}