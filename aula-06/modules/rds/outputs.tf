output "db_endpoint" {
  description = "Endpoint de conexao do banco de dados RDS"
  value       = aws_db_instance.this.endpoint
}

output "db_name" {
  description = "Nome do banco de dados criado"
  value       = aws_db_instance.this.db_name
}

output "db_port" {
  description = "Porta de conexao do banco de dados RDS"
  value       = aws_db_instance.this.port
}
