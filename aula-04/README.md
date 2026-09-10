# Infraestrutura TechNova — Aula 04

Infraestrutura AWS criada com Terraform para a TechNova, utilizando uma arquitetura de rede Multi-AZ com VPC, subnets públicas e privadas, Internet Gateway, Route Table, Security Groups e uma instância EC2 para execução da API.

## Arquitetura

```text
                         INTERNET
                             |
                             |
                    +-------------------+
                    | Internet Gateway  |
                    +-------------------+
                             |
                             |
                  +-----------------------+
                  |      TechNova VPC     |
                  |      10.0.0.0/16      |
                  +-----------------------+
                     /                 \
                    /                   \
             AZ us-east-1a          AZ us-east-1b
                  |                       |
          +---------------+       +---------------+
          | Public Subnet |       | Public Subnet |
          | 10.0.1.0/24   |       | 10.0.3.0/24   |
          +---------------+       +---------------+
                  |                       |
                  |                       |
             +---------+             (futuro)
             |   EC2   |
             |  t2.micro|
             |   API   |
             +---------+
                  |
             Porta 3000
                  
          +---------------+       +---------------+
          |Private Subnet |       |Private Subnet |
          | 10.0.2.0/24   |       | 10.0.4.0/24   |
          +---------------+       +---------------+
                  |                       |
                  +-----------+-----------+
                              |
                       Futuro banco PostgreSQL
```

A infraestrutura foi distribuída em duas Availability Zones para permitir uma arquitetura preparada para alta disponibilidade e futuras expansões, como a utilização de um Load Balancer.

## Recursos criados

| Recurso              | Função                                             |
| -------------------- | -------------------------------------------------- |
| VPC                  | Rede principal da infraestrutura                   |
| Public Subnet        | Subnets com acesso à Internet                      |
| Private Subnet       | Subnets destinadas a recursos internos             |
| Internet Gateway     | Permite comunicação da rede pública com a Internet |
| Route Table Pública  | Direciona tráfego externo para o Internet Gateway  |
| Security Group API   | Controla acesso à instância EC2                    |
| Security Group DB    | Controla acesso futuro ao banco PostgreSQL         |
| EC2                  | Executa a API da TechNova                          |
| Key Pair             | Permite acesso SSH à EC2                           |
| IAM Role             | Permite que a EC2 assuma uma identidade AWS        |
| IAM Instance Profile | Anexa a IAM Role à EC2                             |
| User Data            | Automatiza a configuração e inicialização da API   |

## Subnets

A VPC utiliza quatro subnets distribuídas em duas Availability Zones:

### Availability Zone 1 — us-east-1a

* Pública: `10.0.1.0/24`
* Privada: `10.0.2.0/24`

### Availability Zone 2 — us-east-1b

* Pública: `10.0.3.0/24`
* Privada: `10.0.4.0/24`

Somente as subnets públicas possuem:

```hcl
map_public_ip_on_launch = true
```

As subnets privadas não possuem rota direta para a Internet.

## Internet Gateway e Route Table

Foi criado um Internet Gateway anexado à VPC.

A Route Table pública possui a rota:

```text
0.0.0.0/0 → Internet Gateway
```

Essa Route Table é associada às duas subnets públicas.

As subnets privadas utilizam a Route Table padrão da VPC, sem rota direta para a Internet.

Essa separação permite manter recursos que não precisam de acesso público em subnets privadas.

## Security Groups

### API

O Security Group da API permite:

| Porta | Protocolo | Origem      | Finalidade  |
| ----: | --------- | ----------- | ----------- |
|    22 | TCP       | `0.0.0.0/0` | SSH         |
|  3000 | TCP       | `0.0.0.0/0` | API Node.js |

O tráfego de saída é permitido para qualquer destino.

### Banco de dados

O Security Group destinado ao banco PostgreSQL permite:

| Porta | Protocolo | Origem        | Finalidade |
| ----: | --------- | ------------- | ---------- |
|  5432 | TCP       | `10.0.0.0/16` | PostgreSQL |

O banco foi preparado para uma futura implementação dentro da VPC, sem exposição direta à Internet.

## EC2

A infraestrutura cria uma instância:

```text
Tipo: t2.micro
Sistema: Amazon Linux 2023
Subnet: Public Subnet
Security Group: API
Porta da aplicação: 3000
```

A AMI do Amazon Linux 2023 é obtida automaticamente por meio de um `data source` do Terraform.

## User Data

A configuração inicial da EC2 é automatizada pelo arquivo `user_data.sh`.

O User Data realiza:

1. Atualização do sistema;
2. Instalação do Git;
3. Instalação do Node.js 18;
4. Criação da aplicação TechNova;
5. Criação do `package.json`;
6. Criação do servidor Express;
7. Instalação das dependências com `npm install`;
8. Inicialização da API na porta `3000`.

A API possui os endpoints:

```text
GET /
GET /health
GET /orders
```

Exemplo de resposta do endpoint `/health`:

```json
{
  "status": "healthy",
  "service": "technova-api"
}
```

## IAM

A EC2 utiliza um Instance Profile associado a uma IAM Role.

A Role possui uma Trust Policy permitindo que o serviço EC2 assuma a Role:

```text
ec2.amazonaws.com
```

Também foi associada a política gerenciada:

```text
AmazonS3ReadOnlyAccess
```

Isso permite que a instância tenha acesso de leitura ao Amazon S3 sem necessidade de armazenar credenciais AWS diretamente na máquina.

## Tags

Os recursos utilizam tags padronizadas para facilitar identificação e gerenciamento:

```hcl
tags = {
  Name        = "technova-<nome-do-recurso>"
  Project     = "TechNova"
  Environment = "development"
  ManagedBy   = "Terraform"
  Owner       = "6325175"
}
```

## Outputs

O Terraform disponibiliza os seguintes outputs:

* `vpc_id`
* `public_subnet_ids`
* `private_subnet_ids`
* `api_security_group_id`
* `db_security_group_id`
* `ec2_public_ip`
* `api_url`
* `ssh_command`

Após o `terraform apply`, esses valores podem ser consultados com:

```bash
terraform output
```

Ou individualmente:

```bash
terraform output vpc_id
terraform output ec2_public_ip
terraform output api_url
terraform output ssh_command
```

## Como executar

### Pré-requisitos

* AWS CLI configurado;
* Terraform instalado;
* Acesso ao AWS Academy Learner Lab;
* Chave SSH disponível em:

```text
~/.ssh/technova-key
~/.ssh/technova-key.pub
```

### Inicializar o Terraform

```bash
terraform init
```

### Validar a configuração

```bash
terraform fmt
terraform validate
```

### Verificar o plano

```bash
terraform plan
```

Para salvar a evidência do plano:

```bash
terraform plan > evidencia-plan.txt
```

### Criar a infraestrutura

```bash
terraform apply
```

Confirme com:

```text
yes
```

### Verificar os outputs

```bash
terraform output
```

## Como testar a API

Depois do `terraform apply`, obtenha o IP público:

```bash
terraform output ec2_public_ip
```

Teste a API:

```bash
curl http://<IP_PUBLICO>:3000
```

Teste o health check:

```bash
curl http://<IP_PUBLICO>:3000/health
```

Teste também:

```bash
curl http://<IP_PUBLICO>:3000/orders
```

Para salvar as evidências:

```bash
curl http://<IP_PUBLICO>:3000 > evidencia-api.json
curl http://<IP_PUBLICO>:3000/health >> evidencia-api.json
```

## Como testar via SSH

O comando pode ser obtido automaticamente:

```bash
terraform output ssh_command
```

Ou utilizado diretamente:

```bash
ssh -i ~/.ssh/technova-key ec2-user@<IP_PUBLICO>
```

Para verificar o Node.js e a identidade AWS:

```bash
ssh -i ~/.ssh/technova-key ec2-user@<IP_PUBLICO> "node --version && aws sts get-caller-identity"
```

A saída pode ser salva como evidência:

```bash
ssh -i ~/.ssh/technova-key ec2-user@<IP_PUBLICO> "node --version && aws sts get-caller-identity" > evidencia-ssh.txt
```

## Decisões técnicas

### Multi-AZ

A infraestrutura utiliza duas Availability Zones para distribuir as subnets e preparar o ambiente para maior disponibilidade.

### Separação entre subnets públicas e privadas

As subnets públicas são destinadas aos recursos que precisam receber conexões externas, como a EC2 da API.

As subnets privadas são destinadas a recursos internos, como o futuro banco de dados, reduzindo sua exposição à Internet.

### Security Groups

Os Security Groups controlam o tráfego de entrada e saída. A API possui acesso às portas necessárias para SSH e HTTP da aplicação, enquanto o banco aceita PostgreSQL somente a partir da rede interna da VPC.

### Infrastructure as Code

O Terraform permite criar, modificar e destruir a infraestrutura de forma reproduzível, mantendo a configuração versionada no Git.

### Preparação para Load Balancer

A existência de subnets públicas em duas Availability Zones permite que futuramente seja adicionado um Load Balancer distribuindo o tráfego entre múltiplas instâncias da API.

## Destruir a infraestrutura

Após capturar todas as evidências e finalizar os testes, execute:

```bash
terraform destroy
```

Confirme com:

```text
yes
```

Isso remove os recursos criados pelo Terraform e evita manter recursos ativos no AWS Academy.
