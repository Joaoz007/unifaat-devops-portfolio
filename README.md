# Portfólio DevOps — UniFAAT 2026-2

**Aluno:** João Pedro Paulino Ferreira
**RA:** 6325175
**Disciplina:** DevOps — Centro Universitário UniFAAT
**Professor:** Alexandre Tavares
**Semestre:** 2026-2

## Sobre

Repositório de atividades e projetos da disciplina de DevOps.

Aqui documento minha evolução desde os fundamentos de Git e Docker até pipelines completas de CI/CD.

## Estrutura

* `aula-01/` — Fundamentos de Git e Docker
* `aula-02/` — API com Node.js, PostgreSQL, Redis e Docker Compose

## Aula 01 — Fundamentos de Git e Docker

Aplicação inicial desenvolvida para praticar os fundamentos de Git, GitHub e Docker.

**Status:** Concluída ✅

## Aula 02 — API com PostgreSQL e Redis

Nesta aula foi desenvolvida uma API utilizando Node.js e Express, executada em containers Docker e integrada com PostgreSQL e Redis.

### Tecnologias

* Node.js
* Express
* Docker
* Docker Compose
* PostgreSQL
* Redis
* Git e GitHub

### Ferramentas utilizadas

* **Kiro** — ferramenta de apoio ao desenvolvimento, utilizada na análise dos requisitos, planejamento, organização e implementação das funcionalidades.
* **Visual Studio Code** — ambiente utilizado para desenvolvimento e edição dos arquivos.
* **Git** — controle de versão do projeto.
* **GitHub** — armazenamento do repositório e acompanhamento da evolução do projeto.

### Implementações

* API REST
* `POST /items` para criação de itens
* `GET /items` para consulta de itens
* Persistência dos dados no PostgreSQL
* Cache das consultas utilizando Redis
* Healthchecks dos serviços
* Persistência do PostgreSQL através de volume Docker
* Configuração através de variáveis de ambiente
* Arquivo `.env.example` para configuração do ambiente

### Funcionamento do cache

Na primeira consulta, os dados são recuperados do PostgreSQL:

```text
GET /items → database
```

Após a consulta ser armazenada no Redis, as próximas requisições utilizam o cache:

```text
GET /items → cache
```

Também foi realizado um teste de reinicialização do ambiente com Docker Compose, confirmando a persistência dos dados no PostgreSQL e a reconstrução do cache no Redis.

**Status:** Concluída ✅

## Aprendizados

Esta seção será atualizada a cada aula com os principais conceitos, práticas e ferramentas aprendidas durante a disciplina.

### Aula 01

* Fundamentos de Git e GitHub
* Versionamento de código
* Docker

### Aula 02

* Containerização de aplicações
* Docker Compose
* Comunicação entre containers
* Persistência de dados
* PostgreSQL
* Redis e estratégia de cache
* Healthchecks
* Variáveis de ambiente
* Organização de serviços em uma aplicação conteinerizada
* Uso do Kiro como ferramenta de apoio ao desenvolvimento

## Próximas aulas

Novos conteúdos e implementações serão adicionados conforme o avanço da disciplina.
