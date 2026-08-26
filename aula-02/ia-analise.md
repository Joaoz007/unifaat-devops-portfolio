# Análise do Uso de IA — Aula 02 TF

## Prompt Utilizado

O seguinte prompt foi utilizado no Kiro para gerar o rascunho inicial do ambiente:

> Crie um ambiente Docker Compose para a Aula 02 do meu portfólio DevOps.
>
> O ambiente deve ter:
> - Uma API Node.js 20 com Express;
> - PostgreSQL 15 como banco de dados;
> - Redis 7 como cache;
> - A API deve rodar na porta 3000;
> - O PostgreSQL deve usar volume nomeado para persistência;
> - Todos os serviços devem estar na mesma rede bridge customizada;
> - Use variáveis de ambiente com interpolação a partir de um arquivo .env;
> - Adicione healthchecks;
> - Use depends_on com condition;
> - Use restart policy unless-stopped.
>
> Crie os arquivos necessários dentro da pasta aula-02, incluindo docker-compose.yml, app.js, package.json, Dockerfile, .dockerignore, .env.example e ia-analise.md.
>
> Não inclua o arquivo .env no Git.

---

## Output Original do Kiro

O Kiro gerou inicialmente o seguinte `docker-compose.yml`, antes das validações e ajustes realizados durante o desenvolvimento:

```yaml
name: aula-02

# ─── Rede customizada ─────────────────────────────────────────────────────────

networks:

  app-network:

    driver: bridge

# ─── Volumes nomeados ─────────────────────────────────────────────────────────

volumes:

  postgres-data:

# ─── Serviços ─────────────────────────────────────────────────────────────────

services:

  # ── PostgreSQL 15 ────────────────────────────────────────────────────────────

  postgres:

    image: postgres:15-alpine

    container_name: aula02-postgres

    restart: unless-stopped

    environment:

      POSTGRES_DB:       ${POSTGRES_DB}

      POSTGRES_USER:     ${POSTGRES_USER}

      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}

    volumes:

      - postgres-data:/var/lib/postgresql/data

    networks:

      - app-network

    healthcheck:

      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]

      interval: 10s

      timeout: 5s

      retries: 5

      start_period: 10s

  # ── Redis 7 ──────────────────────────────────────────────────────────────────

  redis:

    image: redis:7-alpine

    container_name: aula02-redis

    restart: unless-stopped

    networks:

      - app-network

    healthcheck:

      test: ["CMD", "redis-cli", "ping"]

      interval: 10s

      timeout: 5s

      retries: 5

      start_period: 5s

  # ── API Node.js ──────────────────────────────────────────────────────────────

  api:

    build:

      context: ./app

      dockerfile: Dockerfile

    container_name: aula02-api

    restart: unless-stopped

    ports:

      - "${PORT:-3000}:3000"

    environment:

      PORT:              ${PORT:-3000}

      POSTGRES_HOST:     ${POSTGRES_HOST:-postgres}

      POSTGRES_PORT:     ${POSTGRES_PORT:-5432}

      POSTGRES_DB:       ${POSTGRES_DB}

      POSTGRES_USER:     ${POSTGRES_USER}

      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}

      REDIS_HOST:        ${REDIS_HOST:-redis}

      REDIS_PORT:        ${REDIS_PORT:-6379}

    networks:

      - app-network

    depends_on:

      postgres:

        condition: service_healthy

      redis:

        condition: service_healthy

    healthcheck:

      test: ["CMD-SHELL", "wget -qO- http://localhost:3000/health || exit 1"]

      interval: 15s

      timeout: 5s

      retries: 3

      start_period: 15s
```

---

## Alterações e Validações Realizadas Manualmente

O output inicial do Kiro já apresentou uma estrutura bastante próxima dos requisitos técnicos da atividade. Por isso, não foram necessárias grandes alterações estruturais no `docker-compose.yml`.

Durante o desenvolvimento, o projeto foi revisado e validado manualmente para confirmar que a configuração gerada realmente funcionava.

| O que foi revisado/ajustado | Por quê |
|---|---|
| Configuração dos serviços API, PostgreSQL e Redis | Garantir que os três serviços exigidos pelo TF estivessem presentes e corretamente orquestrados. |
| Variáveis de ambiente | Garantir que as configurações sensíveis fossem obtidas através do `.env`, sem deixar as credenciais diretamente no `docker-compose.yml`. |
| Volume `postgres-data` | Garantir a persistência dos dados do PostgreSQL. |
| Rede `app-network` | Garantir que os três serviços estivessem conectados pela mesma rede bridge customizada. |
| Healthchecks | Validar a disponibilidade dos serviços antes da inicialização dependente da API. |
| `depends_on` com `service_healthy` | Garantir que a API aguardasse PostgreSQL e Redis estarem saudáveis. |
| `restart: unless-stopped` | Atender ao requisito do trabalho e melhorar a recuperação dos containers após falhas. |
| Validação com `docker compose config` | Confirmar que o arquivo Compose era válido e que as variáveis estavam sendo interpoladas corretamente. |
| Testes com Docker Compose | Confirmar o funcionamento real dos três containers, e não apenas a validade da configuração. |

---

## O que o Kiro Acertou

O Kiro conseguiu gerar um rascunho inicial bastante completo e próximo dos requisitos do trabalho.

Entre os principais acertos estão:

- criação dos três serviços necessários;
- utilização do PostgreSQL 15 Alpine;
- utilização do Redis 7 Alpine;
- construção da API a partir de um Dockerfile local;
- criação de uma rede bridge customizada;
- utilização de volume nomeado para o PostgreSQL;
- utilização de variáveis de ambiente com interpolação;
- configuração de healthchecks;
- utilização de `depends_on` com condições de saúde;
- utilização da política de reinicialização `unless-stopped`.

O resultado inicial economizou tempo na criação da estrutura do projeto e serviu como uma base para entender como os serviços deveriam ser organizados.

---

## O que o Kiro Errou ou Omitiu

Apesar de o rascunho ter atendido grande parte dos requisitos, a configuração gerada pela IA não deve ser considerada automaticamente correta apenas por estar sintaticamente válida.

Foi necessário validar manualmente o ambiente e conferir se os serviços realmente iniciavam e se comunicavam corretamente.

Também foi necessário revisar a documentação gerada inicialmente para adequá-la ao formato exigido pelo professor. A primeira versão do `ia-analise.md` apresentava principalmente uma análise técnica da arquitetura, mas não documentava adequadamente o processo de utilização da IA, o prompt utilizado e a comparação entre o output original e o resultado final.

Essa revisão mostrou que a IA pode gerar uma boa base, mas ainda é necessário analisar criticamente o conteúdo produzido.

---

## Validação do Ambiente

Depois da implementação, o ambiente foi validado utilizando Docker Compose.

Foi executado:

```powershell
docker compose -f aula-02/docker-compose.yml config
```

O comando confirmou a configuração final do Compose, incluindo os três serviços, rede, volume, healthchecks e dependências.

Também foi verificado o estado dos containers:

```powershell
docker compose ps
```

O ambiente apresentou os seguintes serviços saudáveis:

```text
aula02-api
aula02-postgres
aula02-redis
```

Também foram realizados testes da API utilizando o endpoint:

```text
GET /items
```

Na primeira consulta, os dados foram recuperados do banco:

```json
{
  "source": "database"
}
```

Na consulta seguinte, os dados foram recuperados do Redis:

```json
{
  "source": "cache"
}
```

Isso confirmou na prática o funcionamento da integração entre API, PostgreSQL e Redis.

---

## Minha Avaliação

- **Tempo economizado usando IA:** aproximadamente 30 minutos.
- **Tempo gasto validando/corrigindo:** aproximadamente 20 minutos.
- **Nota para o output da IA:** 8/10.
- **Usaria novamente para este tipo de tarefa:** Sim.

A IA foi útil principalmente para acelerar a criação da estrutura inicial do ambiente e apresentar uma configuração que já continha grande parte dos requisitos solicitados.

Porém, a experiência também mostrou que o código gerado pela IA precisa ser revisado e testado. Não basta aceitar o resultado automaticamente: é necessário entender a configuração, verificar os requisitos da atividade e executar testes para confirmar que o ambiente realmente funciona.

Eu usaria novamente a IA como copiloto, principalmente para gerar rascunhos, sugerir configurações e acelerar tarefas repetitivas. Entretanto, manteria a validação manual como parte obrigatória do processo.