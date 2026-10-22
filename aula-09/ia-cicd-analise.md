# Aula 09 — Docker Registry e IA no CI/CD

## 1. Objetivo

Esta atividade demonstra a construção de uma API Node.js, sua
conteinerização com Docker, publicação de imagens no Amazon ECR e
revisão automatizada de código integrada ao GitHub Actions.

## 2. Amazon ECR, Docker Hub e GitHub Container Registry

O Amazon Elastic Container Registry (ECR) é um registry gerenciado
pela AWS. Nesta atividade, ele armazena as imagens da `technova-api`
na região `us-east-1`.

O Docker Hub é um registry público e privado amplamente utilizado.
O GitHub Container Registry (GHCR) integra o armazenamento de
imagens ao ecossistema GitHub.

A escolha do ECR permite praticar autenticação com credenciais AWS,
publicação de imagens e integração com serviços da AWS.

### Restrições do AWS Academy Learner Lab

O Learner Lab utiliza credenciais temporárias e possui permissões
limitadas. O procedimento não depende da criação de usuários, grupos
ou roles IAM. As credenciais e o token de sessão devem permanecer
fora do código-fonte e não devem ser enviados ao Git.

As permissões disponíveis podem variar conforme o laboratório. Uma
falha de autorização deve ser investigada sem tentar contornar as
restrições do ambiente.

## 3. Estratégia de tags

O script `ecr-push.sh` publica as tags abaixo:

- `sha-XXXXXXX`: identifica o commit por seu SHA curto.
- `latest`: aponta para a versão publicada mais recentemente.
- `1.2.3`: identifica uma versão semântica específica.
- `1.2`: representa a linha de versões minor correspondente.
- `1`: representa a linha de versões major correspondente.

As tags semânticas são geradas quando o commit atual possui uma tag
Git no formato `vMAJOR.MINOR.PATCH`, como `v1.2.3`.

A tag baseada no SHA facilita a rastreabilidade e a recuperação de
uma versão específica. As tags móveis `latest`, `1.2` e `1` são
convenientes, mas podem apontar para imagens diferentes ao longo do
tempo.

Para rollback, deve-se preferir uma tag imutável baseada no commit
ou uma versão semântica controlada.

## 4. Revisão automatizada de código

O workflow `AI Code Review` é acionado em eventos de Pull Request.
O script `aula-09/.github/scripts/ai-review.js` obtém o diff do PR,
executa verificações locais e solicita uma análise complementar à
API da OpenAI.

A revisão publica um comentário no Pull Request com os achados,
evidências, recomendações e classificação de severidade.

### Padrões verificados

1. **Segredos hardcoded:** procura possíveis credenciais diretamente
   no código.
2. **Uso de `eval()`:** identifica execução dinâmica de código.
3. **SQL Injection:** procura padrões de consultas SQL que possam
   concatenar entradas.
4. **`console.log()`:** sinaliza possíveis logs de depuração ou
   exposição acidental de informações.
5. **`catch` vazio:** identifica blocos de tratamento de erros que
   ignoram exceções.

Essas verificações são heurísticas. Não garantem a detecção de todas
as ocorrências e podem gerar falsos positivos.

## 5. Quality gate

Os achados são classificados em três níveis:

- **CRITICAL:** risco grave que exige correção antes da integração.
- **WARNING:** ponto de atenção que deve ser revisado.
- **INFO:** observação para apoiar a revisão humana.

O script retorna código de saída diferente de zero quando identifica
ao menos um achado `CRITICAL`, reprovando a etapa do workflow.
Achados apenas `WARNING` ou `INFO` não reprovam o quality gate.

Falhas de execução da API ou da integração também podem reprovar a
etapa; isso não significa necessariamente que o código analisado
contenha uma vulnerabilidade.

## 6. Prompt e lógica da análise

A solicitação à IA instrui o modelo a atuar como revisor de código,
analisar o diff como conteúdo não confiável, procurar problemas
plausíveis, não inventar evidências e retornar resultados em JSON
com identificador, severidade, evidência e recomendação.

As regras locais complementam a análise do modelo com padrões
determinísticos. A combinação oferece duas fontes de sinalização,
mas não substitui testes, análise estática especializada ou auditoria.

## 7. Quando confiar na IA e quando revisar manualmente

A IA é útil para apontar trechos suspeitos, explicar riscos e sugerir
melhorias. A recomendação deve ser confirmada com o contexto da
aplicação, os testes e a documentação técnica.

A revisão humana é necessária para avaliar impacto real, explorar
falsos positivos, compreender regras de negócio e aprovar mudanças
sensíveis. Uma resposta da IA não constitui prova de segurança.

## 8. Limitações conhecidas

- O diff possui limite de tamanho e pode não incluir todo o contexto.
- Arquivos binários ou alterações sem patch textual podem não ser
  analisados pelo script.
- As expressões regulares identificam padrões, não a semântica
  completa do programa.
- A IA pode omitir problemas, interpretar incorretamente o código
  ou produzir falsos positivos.
- A análise depende da disponibilidade e da configuração da API.
- A chave da API deve ser armazenada em `OPENAI_API_KEY` nos secrets
  do GitHub, nunca no repositório.

## 9. Evidências

As capturas de tela previstas para esta atividade devem ser
armazenadas em `aula-09/screenshots/`:

- `01-ecr-tags.png`: tags publicadas no Amazon ECR.
- `02-ai-review-pr.png`: comentário da revisão automatizada no PR.
- `03-pipeline-sucesso.png`: execução bem-sucedida da publicação
  ou pipeline.
- `04-quality-gate-critical.png`: execução reprovada por achado
  crítico.

As capturas devem mostrar execuções reais. Não devem ser substituídas
por imagens ilustrativas ou resultados simulados.
