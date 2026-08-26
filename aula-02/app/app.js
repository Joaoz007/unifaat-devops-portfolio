const express = require('express');
const { Pool } = require('pg');
const { createClient } = require('redis');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Configuração do pool de conexão com o PostgreSQL
const pgPool = new Pool({
  host: process.env.POSTGRES_HOST,
  port: Number(process.env.POSTGRES_PORT) || 5432,
  database: process.env.POSTGRES_DB,
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
});

// Configuração do cliente Redis
const redisClient = createClient({
  socket: {
    host: process.env.REDIS_HOST,
    port: Number(process.env.REDIS_PORT) || 6379,
  },
});

redisClient.on('error', (err) => console.error('Redis error:', err));

// Inicializa a tabela de itens caso não exista
async function initDb() {
  await pgPool.query(`
    CREATE TABLE IF NOT EXISTS items (
      id   SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      created_at TIMESTAMPTZ DEFAULT NOW()
    )
  `);
  console.log('Tabela "items" pronta.');
}

// ─── Rotas ───────────────────────────────────────────────────────────────────

// GET /health — usado pelos healthchecks e monitoramento
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// GET /items — lista todos os itens (com cache Redis de 30 s)
app.get('/items', async (_req, res) => {
  try {
    const cached = await redisClient.get('items');
    if (cached) {
      return res.json({ source: 'cache', data: JSON.parse(cached) });
    }

    const { rows } = await pgPool.query('SELECT * FROM items ORDER BY id');
    await redisClient.setEx('items', 30, JSON.stringify(rows));

    res.json({ source: 'database', data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao buscar itens.' });
  }
});

// POST /items — cria um novo item e invalida o cache
app.post('/items', async (req, res) => {
  const { name } = req.body;
  if (!name) {
    return res.status(400).json({ error: 'O campo "name" é obrigatório.' });
  }

  try {
    const { rows } = await pgPool.query(
      'INSERT INTO items (name) VALUES ($1) RETURNING *',
      [name]
    );
    await redisClient.del('items'); // invalida o cache após inserção
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao criar item.' });
  }
});

// DELETE /items/:id — remove um item e invalida o cache
app.delete('/items/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const { rowCount } = await pgPool.query('DELETE FROM items WHERE id = $1', [id]);
    if (rowCount === 0) {
      return res.status(404).json({ error: 'Item não encontrado.' });
    }
    await redisClient.del('items');
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao remover item.' });
  }
});

// ─── Inicialização ────────────────────────────────────────────────────────────

async function start() {
  await redisClient.connect();
  console.log('Conectado ao Redis.');

  await initDb();

  app.listen(PORT, () => {
    console.log(`API rodando em http://0.0.0.0:${PORT}`);
  });
}

start().catch((err) => {
  console.error('Falha ao iniciar a aplicação:', err);
  process.exit(1);
});
