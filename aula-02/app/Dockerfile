# ── Estágio de dependências ───────────────────────────────────────────────────
FROM node:20-alpine AS deps

WORKDIR /app

# Copia apenas os manifests para aproveitar o cache de camadas do Docker
COPY package.json ./

# Instala somente dependências de produção
RUN npm install --omit=dev

# ── Estágio final ─────────────────────────────────────────────────────────────
FROM node:20-alpine

WORKDIR /app

# Cria usuário não-root para execução segura
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copia dependências já instaladas do estágio anterior
COPY --from=deps /app/node_modules ./node_modules

# Copia o código-fonte
COPY app.js ./
COPY package.json ./

# Ajusta dono dos arquivos para o usuário não-root
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

# Healthcheck interno da imagem (o Compose define o seu próprio)
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "app.js"]
