# private-doc

Comando para criar ou atualizar documentação. Apresenta mini-plano para documentação estrutural, vai direto para atualizações pontuais.

## Quando usar
Ao precisar documentar uma feature nova, atualizar o README, registrar decisões de arquitetura ou adicionar comentários relevantes.

## Argumento opcional
`/private-doc [o que documentar]`

Se nenhum argumento for passado, analise o que mudou recentemente e sugira o que precisa de documentação.

## O que fazer

### Passo 1 — Classificar o tipo de documentação

**Pontual** (vai direto, sem plano):
- Atualizar changelog / CHANGELOG.md
- Adicionar/corrigir um comentário em função específica
- Atualizar versão no README
- Corrigir exemplo de uso desatualizado

**Estrutural** (exige mini-plano):
- Criar ou reescrever o README
- Documentar arquitetura do sistema
- Criar guia de contribuição ou setup
- Documentar uma API ou interface pública
- Criar ADR (Architecture Decision Record)
- Documentar fluxo de dados ou diagrama
- Criar ou atualizar especificação OpenAPI (obrigatório quando o projeto expõe endpoints HTTP)

### Passo 2 — Para documentação estrutural, apresente o mini-plano

```
## Plano de documentação — [o que será documentado]

**Objetivo:** [o que o leitor vai entender ao ler]
**Audiência:** [quem vai ler — você mesmo no futuro / colaborador / usuário externo]

**Arquivos que serão criados/modificados:**
- `README.md` — [seções que serão adicionadas/alteradas]
- `docs/arquitetura.md` — [novo arquivo, conteúdo previsto]

**Estrutura proposta:**
1. [seção 1]
2. [seção 2]
3. [seção 3]

**Fontes de informação:**
- [arquivos de código que vou ler para extrair informação]

Posso prosseguir?
```

### Passo 3 — Aguardar aprovação (apenas para estrutural)

### Passo 4 — Escrever a documentação
- Leia o código relevante antes de escrever — não documente de memória
- Seja direto: documente o comportamento real, não o ideal
- Para README: inclua sempre como instalar, como rodar, como testar
- Para comentários no código: documente o POR QUÊ, não o O QUÊ
- Não crie documentação para código que não existe ainda

**Regra obrigatória — endpoints HTTP:**
Se o projeto expõe endpoints HTTP (REST, GraphQL, etc.), a documentação dos endpoints é obrigatória:
- Verifique se já existe um arquivo OpenAPI (`openapi.yaml`, `openapi.json`, `swagger.yaml` ou similar)
- Se existir: atualize-o para refletir o estado atual dos endpoints
- Se não existir: crie `openapi.yaml` na raiz (ou em `docs/`) seguindo a especificação OpenAPI 3.x
- O arquivo OpenAPI deve cobrir: path, método HTTP, parâmetros, request body (com schema), responses (com schema e códigos de status), e autenticação se houver
- Endpoints sem documentação OpenAPI são considerados incompletos

### Passo 5 — Confirmar
Informe o que foi criado/modificado e onde encontrar.

## Notas
- Documentação desatualizada é pior que nenhuma documentação — só documente o que é verdade agora
- Se encontrar documentação desatualizada durante o processo, corrija ou remova
- Prefira exemplos concretos a descrições abstratas
