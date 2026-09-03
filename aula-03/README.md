# Aula 03 — Terraform + IAM | TechNova

## Design da Estrutura IAM

A estrutura IAM foi criada utilizando Terraform para manter as
configurações de usuários, grupos, políticas e roles como código.

Foram criados dois grupos com responsabilidades diferentes:

- `developers`: acesso de leitura aos recursos S3.
- `platform-eng`: acesso de gerenciamento de EC2 e leitura/escrita no S3.

Os usuários foram distribuídos de acordo com suas funções:

- Juliana: developers.
- Rafael: developers + platform-eng.
- Lucas: developers.

Essa separação evita conceder permissões administrativas para todos
os usuários e permite que cada pessoa tenha somente os acessos
necessários para sua função.

## Princípio do Menor Privilégio

O princípio do menor privilégio consiste em conceder a um usuário,
grupo ou serviço somente as permissões necessárias para executar
suas atividades.

No projeto, esse princípio foi aplicado de duas formas:

1. O grupo developers recebe somente permissões de leitura no S3,
   enquanto o grupo platform-eng possui permissões adicionais para
   gerenciamento de EC2 e escrita no S3.

2. As operações de StartInstances e StopInstances são permitidas
   somente para instâncias que possuem a tag Project=TechNova.

Também foi criada uma política com Deny explícito para impedir
operações destrutivas como Delete* no S3 e Terminate* no EC2 para
o grupo developers.

O uso de AmazonS3FullAccess não seria adequado porque concederia
permissões muito mais amplas do que as necessárias. Uma política
customizada permite limitar as ações e os recursos aos requisitos
específicos da aplicação.

## Diagrama de Permissões

```text
Users
  |
  +--> developers
  |       |
  |       +--> technova-s3-read
  |       |
  |       +--> technova-deny-destructive
  |
  +--> platform-eng
          |
          +--> technova-ec2-s3-full


EC2
 |
 +--> Instance Profile
        |
        +--> EC2 Role
                |
                +--> S3 Read/Write