# Aula 06 — Biblioteca de Módulos Terraform TechNova

Biblioteca de módulos Terraform reutilizáveis para provisionamento de infraestrutura AWS da empresa fictícia **TechNova**. Organizada em dois ambientes isolados (**dev** e **staging**), cada um com VPC, Security Groups, EC2 e RDS compostos a partir dos mesmos módulos base.

---

## Visão Geral

```
aula-06/
├── .aws-credentials.example   # Template de credenciais (versionado)
├── .gitignore
├── README.md
├── environments/
│   ├── dev/                   # Ambiente de desenvolvimento
│   └── staging/               # Ambiente de homologação
└── modules/
    ├── vpc/                   # VPC, Subnets, IGW, Route Tables
    ├── security-group/        # Security Groups genéricos
    ├── ec2/                   # Instâncias EC2
    └── rds/                   # RDS PostgreSQL
```

---

## Diagrama de Dependências

```mermaid
graph TD
    VPC["módulo vpc<br/>(VPC · Subnets · IGW · RT)"]
    SG_API["módulo security-group<br/>(api-sg)"]
    SG_RDS["módulo security-group<br/>(rds-sg)"]
    EC2["módulo ec2<br/>(API Server)"]
    RDS["módulo rds<br/>(PostgreSQL)"]

    VPC -->|vpc_id| SG_API
    VPC -->|vpc_id| SG_RDS
    VPC -->|public_subnet_ids[0]| EC2
    VPC -->|private_subnet_ids| RDS
    SG_API -->|sg_id| EC2
    SG_RDS -->|sg_id| RDS
```

> **Legenda:** as setas representam outputs de um módulo usados como inputs do próximo.

---

## Referência dos Módulos

### `modules/vpc`

Cria a VPC base com subnets dinâmicas (via `for_each`), Internet Gateway e Route Table pública.

| # | Input | Tipo | Descrição |
|---|-------|------|-----------|
| 1 | `vpc_cidr` | `string` | Bloco CIDR da VPC |
| 2 | `project_name` | `string` | Nome do projeto (usado em tags) |
| 3 | `environment` | `string` | Nome do ambiente (dev, staging, prod) |
| 4 | `subnets` | `map(object({cidr, az, type}))` | Mapa de subnets a criar (`type` = "public" ou "private") |

| # | Output | Tipo | Descrição |
|---|--------|------|-----------|
| 1 | `vpc_id` | `string` | ID da VPC criada |
| 2 | `public_subnet_ids` | `list(string)` | IDs das subnets públicas |
| 3 | `private_subnet_ids` | `list(string)` | IDs das subnets privadas |

---

### `modules/security-group`

Módulo genérico e reutilizável para qualquer Security Group. Regras de ingresso via bloco `dynamic`.

| # | Input | Tipo | Descrição |
|---|-------|------|-----------|
| 1 | `name` | `string` | Nome base do Security Group |
| 2 | `vpc_id` | `string` | ID da VPC |
| 3 | `ingress_rules` | `list(object)` | Lista de regras de entrada |
| 4 | `environment` | `string` | Nome do ambiente |
| 5 | `project_name` | `string` | Nome do projeto |

| # | Output | Tipo | Descrição |
|---|--------|------|-----------|
| 1 | `sg_id` | `string` | ID do Security Group criado |

---

### `modules/ec2`

Instância EC2 com AMI, tipo, subnet e Security Groups configuráveis.

| # | Input | Tipo | Padrão | Descrição |
|---|-------|------|--------|-----------|
| 1 | `instance_name` | `string` | — | Nome da instância (tag Name) |
| 2 | `instance_type` | `string` | `t2.micro` | Tipo da instância EC2 |
| 3 | `ami_id` | `string` | — | ID da AMI |
| 4 | `subnet_id` | `string` | — | ID da subnet |
| 5 | `security_group_ids` | `list(string)` | — | IDs dos Security Groups |
| 6 | `key_name` | `string` | — | Nome do Key Pair para SSH |
| 7 | `user_data` | `string` | `null` | Script de inicialização (opcional) |
| 8 | `environment` | `string` | — | Nome do ambiente |
| 9 | `project_name` | `string` | — | Nome do projeto |

| # | Output | Tipo | Descrição |
|---|--------|------|-----------|
| 1 | `instance_id` | `string` | ID da instância EC2 |
| 2 | `public_ip` | `string` | IP público |
| 3 | `private_ip` | `string` | IP privado |

---

### `modules/rds`

Instância RDS PostgreSQL com DB Subnet Group em subnets privadas.

| # | Input | Tipo | Padrão | Descrição |
|---|-------|------|--------|-----------|
| 1 | `db_name` | `string` | — | Nome do banco de dados |
| 2 | `db_username` | `string` | — | Usuário administrador |
| 3 | `db_password` | `string` (sensitive) | — | Senha do administrador |
| 4 | `subnet_ids` | `list(string)` | — | Subnets privadas para o Subnet Group |
| 5 | `security_group_ids` | `list(string)` | — | IDs dos Security Groups |
| 6 | `instance_class` | `string` | `db.t3.micro` | Classe da instância RDS |
| 7 | `environment` | `string` | — | Nome do ambiente |
| 8 | `project_name` | `string` | — | Nome do projeto |

| # | Output | Tipo | Descrição |
|---|--------|------|-----------|
| 1 | `db_endpoint` | `string` | Endpoint de conexão |
| 2 | `db_name` | `string` | Nome do banco criado |
| 3 | `db_port` | `number` | Porta de conexão |

---

## Como Usar — Criando um Novo Ambiente

Crie uma pasta `environments/production/` e use os módulos assim:

```hcl
# environments/production/main.tf

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr     = "10.2.0.0/16"
  project_name = "technova"
  environment  = "production"

  subnets = {
    "public-1a" = { cidr = "10.2.1.0/24", az = "us-east-1a", type = "public" }
    "public-1b" = { cidr = "10.2.2.0/24", az = "us-east-1b", type = "public" }
    "private-1a" = { cidr = "10.2.3.0/24", az = "us-east-1a", type = "private" }
    "private-1b" = { cidr = "10.2.4.0/24", az = "us-east-1b", type = "private" }
  }
}

module "api_sg" {
  source       = "../../modules/security-group"
  name         = "api-sg"
  vpc_id       = module.vpc.vpc_id
  project_name = "technova"
  environment  = "production"
  ingress_rules = [
    { description = "HTTPS", from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "rds_sg" {
  source       = "../../modules/security-group"
  name         = "rds-sg"
  vpc_id       = module.vpc.vpc_id
  project_name = "technova"
  environment  = "production"
  ingress_rules = [
    { description = "PostgreSQL", from_port = 5432, to_port = 5432, protocol = "tcp", cidr_blocks = ["10.2.0.0/16"] }
  ]
}

module "ec2" {
  source             = "../../modules/ec2"
  instance_name      = "technova-production-api"
  ami_id             = var.ami_id
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.api_sg.sg_id]
  key_name           = var.key_name
  environment        = "production"
  project_name       = "technova"
}

module "rds" {
  source             = "../../modules/rds"
  db_name            = "technova_production"
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.rds_sg.sg_id]
  environment        = "production"
  project_name       = "technova"
}
```

---

## Pré-requisitos

- **Terraform** >= 1.3.0 instalado ([terraform.io/downloads](https://developer.hashicorp.com/terraform/downloads))
- **AWS CLI** instalado e acessível no PATH
- **Key Pair** criado previamente no console AWS EC2 (região us-east-1)
- Conta com permissões suficientes para criar VPC, EC2, RDS e Security Groups

---

## Configurando Credenciais do Learner Lab

O AWS Academy Learner Lab gera credenciais temporárias que **expiram ao final de cada sessão**. Siga este fluxo toda vez que iniciar o lab:

### 1. Copie o arquivo de exemplo

```bash
cp aula-06/.aws-credentials.example aula-06/.aws-credentials
```

### 2. Obtenha as credenciais no painel do Academy

1. Acesse o painel do AWS Academy
2. Clique em **"AWS Details"** (botão no canto superior direito do terminal do Learner Lab)
3. Copie os três valores exibidos: `aws_access_key_id`, `aws_secret_access_key` e `aws_session_token`

### 3. Cole no arquivo `.aws-credentials`

Edite `aula-06/.aws-credentials` e substitua os placeholders:

```ini
[learner-lab]
aws_access_key_id = ASIA...
aws_secret_access_key = wJalr...
aws_session_token = IQoJb3...
```

### 4. Execute o Terraform

```bash
cd aula-06/environments/dev
terraform init
terraform validate
terraform plan
```

> ⚠️ **Importante:** O arquivo `.aws-credentials` está no `.gitignore` e **nunca deve ser commitado**. As credenciais expiram e precisam ser atualizadas a cada nova sessão do Learner Lab.

---

## Executando os Ambientes

```bash
# Ambiente Dev
cd aula-06/environments/dev
terraform init
terraform validate
terraform plan

# Ambiente Staging
cd aula-06/environments/staging
terraform init
terraform validate
terraform plan
```

Para aplicar (somente com credenciais válidas e após revisar o plan):

```bash
terraform apply
```
