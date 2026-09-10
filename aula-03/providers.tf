terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project    = "TechNova"
      ManagedBy  = "Terraform"
      Aluno      = var.aluno
      RA         = var.ra
      Disciplina = "DevOps - UniFAAT 2026-2"
      Aula       = "03"
    }
  }
}