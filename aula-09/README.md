# Aula 09 — TechNova API

Projeto demonstrativo de Docker, Amazon ECR e revisão automatizada de código com GitHub Actions e IA.

## Tecnologias

- Node.js 22
- Express
- Docker
- Amazon ECR (`us-east-1`)
- GitHub Actions
- API da OpenAI para revisão complementar

## Estrutura

```text
aula-09/
├── .github/
│   ├── scripts/
│   │   └── ai-review.js
│   └── workflows/
│       └── ai-review.yml
├── screenshots/
├── .dockerignore
├── .gitignore
├── Dockerfile
├── app.js
├── app.test.js
├── ecr-push.sh
├── ia-cicd-analise.md
├── package.json
└── package-lock.json
```

O workflow ativo do GitHub Actions está em `.github/workflows/ai-review-aula-09.yml`, na raiz do repositório, porque o GitHub procura workflows nesse local.

## Executar localmente

Instale as dependências:

```bash
npm install
```

Execute os testes:

```bash
npm test
```

Inicie a API:

```bash
npm start
```

Endpoints disponíveis:

- `GET /` — informações da API.
- `GET /health` — verificação de saúde.
- `GET /api/status` — estado do serviço.

## Construir a imagem Docker

Execute os comandos a partir desta pasta:

```bash
docker build -t technova-api:local .
docker run --rm -p 3000:3000 technova-api:local
```

A API ficará disponível em `http://localhost:3000`.

## Publicar no Amazon ECR

Pré-requisitos:

- Docker e AWS CLI instalados.
- Credenciais válidas do AWS Academy Learner Lab.
- Permissões necessárias para acessar e publicar no ECR.
- Região `us-east-1`.

No PowerShell com Git Bash disponível, execute:

```powershell
bash ./aula-09/ecr-push.sh
```

Esse comando é executado a partir da raiz do repositório. O script publica as tags baseadas no SHA e `latest`; tags semânticas também são publicadas quando o commit atual tem uma tag Git `vMAJOR.MINOR.PATCH`.

## Revisão automatizada por IA

O workflow é acionado quando um Pull Request altera arquivos de `aula-09/`.

Configure o segredo `OPENAI_API_KEY` nas configurações do repositório GitHub. Não grave a chave em arquivos versionados.

A revisão combina verificações por padrões e análise complementar por IA. Um achado `CRITICAL` reprova a etapa de qualidade; `WARNING` e `INFO` não a reprovam.

## Evidências

Guarde as capturas reais na pasta `screenshots/`. Os nomes previstos e os requisitos estão descritos em `ia-cicd-analise.md`.
