output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Lista de IDs das subnets publicas"
  value = [
    for k, v in aws_subnet.this : v.id if var.subnets[k].type == "public"
  ]
}

output "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas"
  value = [
    for k, v in aws_subnet.this : v.id if var.subnets[k].type == "private"
  ]
}
