# ==========================================
# Bootstrap - Remote State
# ==========================================
#
# O bucket S3 e a tabela DynamoDB são criados
# previamente via AWS CLI porque o backend do
# Terraform precisa existir antes do terraform init.
#
# S3:
# technova-terraform-state-6325175-2026
#
# DynamoDB:
# technova-terraform-lock-6325175-2026
#
# Região:
# us-east-1
#
# O Terraform utiliza esses recursos por meio
# do backend definido em backend.tf.