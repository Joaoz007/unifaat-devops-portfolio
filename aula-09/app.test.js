const test = require("node:test");
const assert = require("node:assert/strict");
const app = require("./app");

test("GET / retorna as informações da TechNova API", async () => {
  const server = app.listen(0, "127.0.0.1");

  try {
    await new Promise((resolve) => server.once("listening", resolve));
    const address = server.address();
    const response = await fetch(`http://127.0.0.1:${address.port}/`);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(body.name, "TechNova API");
    assert.equal(body.version, "1.0.0");
  } finally {
    await new Promise((resolve, reject) =>
      server.close((error) => error ? reject(error) : resolve())
    );
  }
});

test("GET /health retorna status ok", async () => {
  const server = app.listen(0, "127.0.0.1");

  try {
    await new Promise((resolve) => server.once("listening", resolve));
    const address = server.address();
    const response = await fetch(`http://127.0.0.1:${address.port}/health`);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(body.status, "ok");
    assert.ok(body.timestamp);
  } finally {
    await new Promise((resolve, reject) =>
      server.close((error) => error ? reject(error) : resolve())
    );
  }
});

test("GET /api/status informa que o serviço está funcionando", async () => {
  const server = app.listen(0, "127.0.0.1");

  try {
    await new Promise((resolve) => server.once("listening", resolve));
    const address = server.address();
    const response = await fetch(`http://127.0.0.1:${address.port}/api/status`);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(body.service, "technova-api");
    assert.equal(body.status, "running");
  } finally {
    await new Promise((resolve, reject) =>
      server.close((error) => error ? reject(error) : resolve())
    );
  }
});
