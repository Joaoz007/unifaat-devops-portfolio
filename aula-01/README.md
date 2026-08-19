# Aula 01 — Fundamentos de Git e Docker

## O que aprendi

Nesta aula pratiquei os fundamentos de Git e Docker, criando uma aplicação Express e executando-a dentro de um container.

### Git

* Criação e organização de um repositório.
* Uso de branches para desenvolvimento.
* Commits seguindo o padrão Conventional Commits.
* Consulta do histórico com `git log`.
* Merge de uma feature branch para a `main`.

### Docker

* Criação de imagens através de um `Dockerfile`.
* Uso de `.dockerignore`.
* Build e execução de containers.
* Mapeamento de portas.
* Verificação do container com `docker ps` e `docker logs`.

## Comandos praticados

**Git:**

```bash
git init
git status
git add
git commit
git checkout -b
git branch
git log
git merge
git push
```

**Docker:**

```bash
docker build
docker run
docker ps
docker logs
docker stop
docker rm
```

## Como executar

Na raiz do projeto:

```bash
docker build -t portfolio-aula01:1.0 ./aula-01/app
docker run -d --name portfolio-test -p 3000:3000 portfolio-aula01:1.0
```

Testar a API:

```bash
curl.exe http://localhost:3000
curl.exe http://localhost:3000/health
```

## Dificuldades encontradas

Ao testar a API pelo PowerShell, o comando `curl` foi interpretado como `Invoke-WebRequest` e apresentou um aviso. Resolvi utilizando `curl.exe` diretamente.

Também pratiquei o mapeamento da porta `3000` do container para a porta `3000` do computador.

## Resultado

A aplicação foi executada com sucesso dentro do Docker. A rota `/` retornou `online` e a rota `/health` retornou `healthy`.
