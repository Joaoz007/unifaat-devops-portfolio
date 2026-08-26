# Aula 02 — Análise do Ambiente Docker Compose

## Visão Geral

Este ambiente demonstra uma stack multi-serviço orquestrada com Docker Compose, composta por uma API Node.js 20, banco de dados PostgreSQL 15 e cache Redis 7. É um padrão amplamente utilizado em aplicações web modernas.

---

## Arquitetura dos Serviços

```
┌─────────────────────────────────────────────────┐
│                 app-network (bridge)            │
│                                                 │
│  ┌──────────┐   ┌──────────┐   ┌────────────┐  │
│  │   API    │──▶│ Postgres │   │   Redis    │  │
│  │ :3000    │   │  :5432   │   │   :6379    │  │
│  └──────────┘   └──────────┘   └────────────┘  │
│       │                │                        │
└───────┼────────────────┼────────────────────────┘
        │                │
   porta 3000       volume nomeado
  (host ↔ container)  postgres-data
```

---

## Decisões Técnicas

### Rede bridge customizada (`app-network`)
Isola os serviços do ambiente padrão do Docker. Dentro desta rede, os contêineres se resolvem pelo nome do serviço (ex.: `postgres`, `redis`), dispensando IPs fixos.

### Volume nomeado (`postgres-data`)
Garante que os dados do PostgreSQL sobrevivam a `docker compose down`. Ao contrário de bind mounts, volumes nomeados são gerenciados pelo Docker e portáveis entre ambientes.

### Variáveis de ambiente com `.env`
O Compose faz interpolação automática de variáveis a partir do arquivo `.env` na mesma pasta do `docker-compose.yml`. O arquivo `.env.example` serve de template e é versionado; o `.env` real fica fora do Git.

### Healthchecks
| Serviço  | Mecanismo               | Justificativa |
|----------|-------------------------|---------------|
| postgres | `pg_isready`            | Verifica se o servidor aceita conexões TCP e autentica o usuário configurado. |
| redis    | `redis-cli ping`        | Resposta `PONG` confirma que o servidor está operacional. |
| api      | `GET /health` via wget  | Valida que a aplicação Node.js subiu e está respondendo HTTP. |

### `depends_on` com `condition: service_healthy`
Impede que a API inicie antes de o PostgreSQL e o Redis estarem de fato prontos para aceitar conexões, eliminando a necessidade de lógica de retry no código da aplicação para a inicialização inicial.

### Restart policy `unless-stopped`
O Docker reinicia automaticamente o contêiner após falhas ou reinicializações do host, mas respeita paradas manuais (`docker compose stop`). Adequado para ambientes de desenvolvimento e staging.

### Dockerfile multi-stage
- **Estágio `deps`**: instala somente as dependências de produção (`--omit=dev`), aproveitando o cache de camadas.
- **Estágio final**: copia apenas o necessário, reduzindo o tamanho da imagem e a superfície de ataque.
- **Usuário não-root**: segue o princípio do menor privilégio.

---

## Cache com Redis

O endpoint `GET /items` armazena o resultado no Redis por **30 segundos**. Operações de escrita (`POST`, `DELETE`) invalidam a chave imediatamente (`DEL items`), garantindo consistência entre o cache e o banco.

```
Cliente → GET /items
             │
             ▼
       Cache hit? ──sim──▶ retorna { source: "cache", data: [...] }
             │
            não
             │
             ▼
     SELECT * FROM items
             │
             ▼
     setEx("items", 30, ...)
             │
             ▼
     retorna { source: "database", data: [...] }
```

---

## Endpoints da API

| Método | Rota         | Descrição                          |
|--------|--------------|------------------------------------|
| GET    | `/health`    | Healthcheck — retorna `{ status: "ok" }` |
| GET    | `/items`     | Lista todos os itens (com cache)   |
| POST   | `/items`     | Cria um item `{ "name": "..." }`   |
| DELETE | `/items/:id` | Remove um item pelo ID             |

---

## Como Executar

```bash
# 1. Copie o arquivo de variáveis de ambiente
cp .env.example .env

# 2. Edite o .env com valores seguros para produção
# (opcional em desenvolvimento)

# 3. Suba o ambiente
docker compose up --build -d

# 4. Verifique os serviços
docker compose ps

# 5. Teste a API
curl http://localhost:3000/health
curl http://localhost:3000/items
curl -X POST http://localhost:3000/items \
     -H "Content-Type: application/json" \
     -d '{"name": "primeiro item"}'

# 6. Encerre o ambiente (dados persistem no volume)
docker compose down

# 7. Encerre e remova os volumes (apaga os dados)
docker compose down -v
```

---

## Melhorias para Produção

- Substituir o arquivo `.env` por um gerenciador de segredos (AWS Secrets Manager, HashiCorp Vault).
- Adicionar um proxy reverso (Nginx ou Traefik) na frente da API.
- Configurar TLS/HTTPS.
- Usar réplicas e um orquestrador como Kubernetes para alta disponibilidade.
- Adicionar observabilidade: métricas (Prometheus), logs estruturados (Loki) e rastreamento (OpenTelemetry).
