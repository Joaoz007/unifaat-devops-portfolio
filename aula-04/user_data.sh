# =============================================================
# TECHNOVA API - USER DATA
# =============================================================

LOG_FILE="/var/log/technova-setup.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "TechNova API - Iniciando configuração"
echo "=========================================="

# Atualizar sistema
echo "Atualizando sistema..."
yum update -y

# Instalar Git
echo "Instalando Git..."
yum install -y git

# Instalar Node.js 18
echo "Instalando Node.js 18..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

echo "Node.js instalado:"
node --version
npm --version

# Criar diretório da aplicação
echo "Criando aplicação..."
mkdir -p /opt/technova-api
cd /opt/technova-api

# Criar package.json
cat > package.json <<'EOF'
{
  "name": "technova-api",
  "version": "1.0.0",
  "description": "TechNova API",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.21.2"
  }
}
EOF

# Criar server.js
cat > server.js <<'EOF'
const express = require("express");
const os = require("os");

const app = express();
const PORT = 3000;

app.get("/", (req, res) => {
  res.json({
    message: "TechNova API - Rodando na AWS!",
    hostname: os.hostname(),
    platform: process.platform,
    node_version: process.version
  });
});

app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    service: "technova-api"
  });
});

app.get("/orders", (req, res) => {
  res.json({
    orders: [
      {
        id: 1,
        product: "Widget A",
        status: "shipped"
      },
      {
        id: 2,
        product: "Widget B",
        status: "processing"
      }
    ]
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`TechNova API rodando na porta ${PORT}`);
});
EOF

# Instalar dependências
echo "Instalando dependências..."
npm install

# Iniciar API
echo "Iniciando API..."
nohup npm start > /var/log/technova-api.log 2>&1 &

echo "=========================================="
echo "TechNova API configurada com sucesso!"
echo "=========================================="
