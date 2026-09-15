# ==========================================
# Remote State - S3 + DynamoDB
# ==========================================

terraform {
  backend "s3" {
    bucket         = "technova-terraform-state-6325175"
    key            = "aula-05/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "technova-terraform-lock-6325175"
  }
}