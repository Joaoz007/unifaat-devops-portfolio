# Variaveis do ambiente Staging
# ATENCAO: nao commitar este arquivo se contiver db_password real.
# Use TF_VAR_db_password para passar a senha via variavel de ambiente.

aws_region   = "us-east-1"
project_name = "technova"
environment  = "staging"
vpc_cidr     = "10.1.0.0/16"

# Substitua pelo ID da AMI Amazon Linux 2023 atual na sua regiao
ami_id = "ami-0c02fb55956c7d316"

# Nome do Key Pair criado previamente no console AWS
key_name = "technova-key"

db_username = "technova_admin"

# NUNCA commite a senha real — use TF_VAR_db_password=suasenha ou
# preencha apenas localmente
db_password = "TROQUE_ANTES_DE_APLICAR"
