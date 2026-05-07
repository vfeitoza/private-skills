# Guia de uso — Claude Code

Este guia mostra, com exemplos, como usar cada um dos 8 comandos `/private-*` no **Claude Code** (CLI da Anthropic). Para o guia equivalente do OpenCode, veja [`USAGE-OPENCODE.md`](USAGE-OPENCODE.md).

## Setup

### 1. Instalar

```bash
git clone https://github.com/vfeitoza/private-skills.git ~/private-skills
cd ~/private-skills

# Global (todos os projetos)
./install.sh

# OU em um projeto específico
./install.sh --project ~/Projetos/meu-app
```

### 2. Reiniciar o Claude Code

Saia do CLI (`Ctrl+D` ou `/exit`) e abra novamente. Os skills só são registrados na inicialização.

### 3. Verificar registro

No CLI, digite `/` e role até encontrar:

```
/private-start    Início de sessão de trabalho — lê o estado do projeto…
/private-create   Cria ou atualiza o `AGENTS.md` do projeto…
/private-task     Inicia uma nova implementação…
…
```

Se os 8 não aparecerem, você reiniciou? Os arquivos estão em `~/.claude/skills/`?

---

## Conceitos centrais

### Auto-discovery vs invocação explícita

No Claude Code, os skills `private-*` podem ser invocados de duas formas:

**1. Explícita (digite o comando):**

```
/private-task implementar login com JWT
```

**2. Implícita (Claude detecta pela `description`):**

```
> Quero implementar um login com JWT
```

O Claude lê a `description` do frontmatter de cada skill e decide automaticamente que `/private-task` é apropriado para essa intenção. **Isso só funciona se a `description` for descritiva o suficiente** — por isso as descrições neste projeto são longas e detalhadas.

> Em caso de dúvida, prefira a forma explícita. Garante que o fluxo correto seja seguido.

### Arquivos de estado no projeto

| Arquivo | Onde fica | Ciclo de vida | Conteúdo |
|---|---|---|---|
| `.session.md` | raiz do projeto | sobrescrito a cada `/private-end` | estado da última sessão (commits, pendências, decisões do dia) |
| `.agent-memory.md` | raiz do projeto | incremental (atualizado por `/private-end`) | fatos duradouros (decisões arquiteturais, preferências, referências) |
| `~/.claude/projects/<proj>/memory/` | global do harness | incremental, gerenciado pelo Claude Code | espelho dos fatos duradouros, mais a memória nativa do harness |

Os dois primeiros ficam **gitignorados por padrão**. O `.agent-memory.md` é a fonte canônica portátil; a memória nativa do Claude é um espelho conveniente.

### `AGENTS.md` vs `CLAUDE.md`

`/private-create` gera `AGENTS.md` por padrão e cria um symlink `CLAUDE.md → AGENTS.md`. Claude Code 4.x lê os dois — então a leitura funciona quer você referencie `AGENTS.md` ou `CLAUDE.md`.

---

## `/private-start` — início de sessão

### Quando usar
Toda vez que você abre o Claude Code num projeto, antes de qualquer outra coisa.

### Exemplo de uso

```
> /private-start
```

**Resposta esperada:**

```
## Sessão iniciada — meu-app

**Stack:** TypeScript 5.4 + Next.js 14 + Postgres
**Branch:** feature/user-profile
**Último commit:** a3f2b1c — feat: adiciona campo bio ao perfil
**Estado:** 2 arquivos modificados (não commitados)

**Contexto anterior:** Última sessão (2026-05-06): refatorou middleware
de auth e parou no meio do upload de avatar — falta validar tipo MIME.

**Memória do projeto:** projeto adota REST sobre GraphQL; commits em
PT-BR; testes de integração obrigatórios para rotas /api/*.

**Pendências identificadas:**
- Validar tipo MIME no upload de avatar (avatar-upload.ts:42)
- Adicionar teste de integração para POST /api/profile

Pronto. O que vamos fazer hoje?
```

### Notas
- Não modifica nada. Só lê e resume.
- Se for a primeira sessão (sem `.session.md`), diz "primeira sessão registrada".
- Se o repo estiver sujo, lista os arquivos modificados.

---

## `/private-create` — cria ou atualiza `AGENTS.md`

### Quando usar
- Projeto novo (vazio): levanta requisitos via perguntas
- Projeto existente sem spec: oferece ler o código e gerar
- Projeto legado só com `CLAUDE.md`: oferece migrar para `AGENTS.md` + symlink
- Projeto com `AGENTS.md`: atualiza, regenera ou complementa

### Exemplo — projeto vazio

```
> /private-create
```

**Resposta:**

```
Projeto vazio detectado. Vou levantar requisitos por blocos de perguntas.

Bloco 1 — Identidade do projeto
1. Qual é o nome do projeto?
```

Você responde uma pergunta de cada vez. Ao final dos 5 blocos (identidade, stack, estrutura, contexto de desenvolvimento, funcionalidades), o Claude apresenta o `AGENTS.md` proposto e pergunta:

> "Posso salvar este `AGENTS.md` no projeto e criar o symlink `CLAUDE.md → AGENTS.md`?"

### Exemplo — projeto existente, ler código

```
> /private-create
```

**Resposta:**

```
Encontrei arquivos no projeto. Posso ler o código para gerar o
AGENTS.md automaticamente, ou prefere responder perguntas manualmente?
(ler código / responder perguntas)
```

Você diz "ler código" e o Claude varre `package.json`, `pyproject.toml`, etc., infere a stack, apresenta um resumo, pede confirmação e gera o `AGENTS.md`.

### Exemplo — migrar `CLAUDE.md` legado

```
> /private-create
```

**Resposta:**

```
CLAUDE.md encontrado (sem AGENTS.md). Recomendação: promover para o
padrão cross-tool AGENTS.md, mantendo CLAUDE.md como symlink.

O que deseja fazer?
1. Migrar para AGENTS.md (renomeia + cria symlink CLAUDE.md → AGENTS.md)
2. Apenas atualizar o CLAUDE.md existente, sem migrar
3. Cancelar
```

---

## `/private-task` — nova implementação

### Quando usar
Qualquer feature, mudança de comportamento, refatoração ou integração.

### Exemplo — tarefa não-trivial

```
> /private-task adicionar rate limiting em /api/login
```

**Resposta:**

```
## Plano — rate limiting em /api/login

**Objetivo:** prevenir brute-force limitando tentativas de login a
5 por minuto por IP.

**Arquivos afetados:**
- src/middleware/rate-limit.ts — novo middleware
- src/routes/login.ts — aplicar middleware na rota
- src/config/rate-limit.ts — configuração centralizada
- openapi.yaml — adicionar response 429 ao endpoint

**Ordem de execução:**
1. Criar config com limites e janela de tempo
2. Implementar middleware usando express-rate-limit
3. Aplicar middleware em /api/login
4. Atualizar OpenAPI com response 429
5. Adicionar teste unitário de bloqueio após 5 tentativas

**Riscos / decisões:**
- IP atrás de proxy: usar X-Forwarded-For (já temos trust proxy)
- Storage: in-memory por enquanto (Redis em uma próxima)

**Fora do escopo:**
- Rate limiting global (só /api/login agora)
- Bloqueio por usuário (só por IP)

Posso prosseguir?
```

Você responde "sim" e o Claude executa exatamente o plano. Ao final, informa em 2-3 linhas o que foi feito.

### Exemplo — tarefa trivial

```
> /private-task corrigir typo "lenght" → "length" em validators.ts
```

**Resposta:** o Claude vai direto, sem mini-plano (typo é trivial).

### Notas
- Endpoints HTTP **exigem** documentação OpenAPI atualizada como parte da tarefa. Não negociável.
- Se o escopo mudar durante a execução, o Claude para e informa.

---

## `/private-fix` — debugging estruturado

### Quando usar
Bug, erro inesperado, comportamento incorreto, falha em teste.

### Exemplo — bug não-óbvio

```
> /private-fix usuários intermitentemente recebem 401 mesmo com token válido
```

**Resposta:**

```
## Diagnóstico — 401 intermitente com token válido

**Sintoma:** ~5% das requisições autenticadas retornam 401, sem padrão
claro de horário ou usuário.

**Hipótese principal:** clock skew entre processos da aplicação fazendo
o `iat` do JWT cair no futuro durante validação.

**Hipóteses alternativas:**
- Cache de chave pública JWT desatualizado em uma das instâncias
- Token sendo invalidado pela rotação de secret antes do TTL expirar

**Plano de investigação:**
1. Verificar uso de `iat` na validação (jwt-verify.ts) — se compara com
   tolerância ou estrita
2. Conferir se o cluster usa NTP sincronizado (pode precisar de logs)
3. Olhar logs das últimas 401 para padrão de instância/timestamp

**Arquivos suspeitos:**
- src/auth/jwt-verify.ts — lógica de validação
- src/auth/key-cache.ts — cache de chaves

**O que NÃO vou mudar ainda:** rotas e middlewares, até confirmar a
causa raiz.

Posso prosseguir com a investigação?
```

Você aprova; o Claude lê os arquivos, confirma a hipótese (ou descarta), e informa antes de aplicar a correção:

```
Causa encontrada: jwt-verify.ts:23 valida `iat` sem clockTolerance.
Quando uma instância está adiantada em ~2s, tokens recém-emitidos
caem no futuro e falham.

Correção: adicionar `clockTolerance: 5` ao `jwt.verify()`.

Aplicando…
```

### Exemplo — bug óbvio

```
> /private-fix import faltando em utils/format.ts: ReferenceError: format is not defined
```

**Resposta:** o Claude vai direto adicionar o import faltante (sem mini-plano de investigação).

---

## `/private-test` — testes e cobertura

### Quando usar
Após implementar feature ou corrigir bug.

### Exemplo

```
> /private-test
```

**Resposta:**

```
## Resultado dos testes

**Suíte:** vitest
**Resultado:** 87 passaram / 2 falharam / 0 pulados

**Falhas:**
- "POST /api/login bloqueia após 5 tentativas" — Expected 429, got 401
  Arquivo: tests/login.test.ts:42
- "validateMime aceita image/jpeg" — TypeError: not a function
  Arquivo: tests/avatar.test.ts:18

**Gaps de cobertura identificados:**
- src/middleware/rate-limit.ts — nova função handleRateLimitExceeded
  sem teste
- src/utils/sanitize.ts — função stripHtml sem teste

**Recomendações:**
- Cobrir o caminho de erro do rate-limit (header Retry-After)
- Adicionar teste para sanitize.stripHtml com input malicioso

Quer corrigir as falhas agora ou apenas registrar?
```

### Notas
- Detecta a stack automaticamente (jest, vitest, pytest, go test, cargo test, rspec…).
- Não modifica código de produção neste comando — só roda e reporta.

---

## `/private-doc` — documentação

### Quando usar
Atualizar README, criar ADR, documentar API, escrever guia de contribuição, atualizar OpenAPI.

### Exemplo — documentação estrutural

```
> /private-doc documentar o fluxo de autenticação
```

**Resposta:**

```
## Plano de documentação — fluxo de autenticação

**Objetivo:** novo dev consegue entender o fluxo completo (login →
JWT → refresh → logout) sem ler código.
**Audiência:** colaboradores novos no time.

**Arquivos que serão criados/modificados:**
- docs/auth-flow.md — novo, conteúdo principal
- README.md — adicionar link na seção "Documentação"

**Estrutura proposta:**
1. Visão geral (diagrama em ASCII)
2. Endpoints envolvidos
3. Ciclo de vida do token (TTLs, rotação)
4. Tratamento de erros comuns

**Fontes de informação:**
- src/auth/* (vou ler antes de escrever)
- openapi.yaml (referenciar)

Posso prosseguir?
```

### Notas
- Para mudanças pontuais (corrigir comentário, atualizar versão no README), o Claude vai direto sem plano.
- Se o projeto expõe HTTP, atualizar `openapi.yaml` é parte do trabalho — não opcional.

---

## `/private-review` — revisão pré-commit

### Quando usar
Antes de fazer commit ou push, para avaliar segurança, corretude e qualidade do diff atual.

### Exemplo

```
> /private-review
```

**Resposta:**

```
## Revisão de código

**Escopo:** 3 arquivos modificados (git diff)
**Resultado geral:** Aprovado com ressalvas

**Problemas encontrados:**

🔴 Crítico
- src/routes/admin.ts:42 — query SQL construída por concatenação de
  strings; injeção potencial em `userId`. Use parâmetros.

🟡 Importante
- src/utils/parse.ts:88 — função tryParse retorna `null` em erro,
  mascarando bugs de input. Considere lançar e tratar no caller.

🔵 Sugestão
- src/middleware/log.ts:15 — variável `req` poderia ser
  desestruturada para legibilidade.

**Pontos positivos:**
- Tratamento explícito de timeout em fetch-external.ts:30
- Cobertura adicionada para o caminho de erro do rate-limit

Recomendo NÃO commitar até resolver o problema crítico.
Quer corrigir agora? (use /private-fix admin.ts:42)
```

### Notas
- Apenas reporta. Não modifica nada.
- Análise estática — não roda o código nem os testes.

---

## `/private-end` — encerramento de sessão

### Quando usar
Ao encerrar o trabalho do dia ou pausar o projeto.

### Exemplo

```
> /private-end
```

**Diálogo esperado:**

```
Tem algo que ficou pela metade ou que precisa continuar na próxima sessão?
> Falta adicionar o teste de integração do rate-limit, próximo do PR

Alguma decisão tomada hoje que vale registrar?
> Decidimos usar in-memory para rate-limit por enquanto (Redis vira sprint 12)
```

O Claude então:
1. Escreve `.session.md` com estado atual e pendências
2. Adiciona `.session.md` e `.agent-memory.md` ao `.gitignore` (se ainda não estiverem)
3. Atualiza `.agent-memory.md` com a decisão (in-memory rate-limit) na seção `## Decisões arquiteturais`
4. Espelha a decisão na memória nativa do Claude Code (`~/.claude/projects/<proj>/memory/`)
5. Confirma:

```
## Sessão encerrada

**Duração:** ~2h
**Commits desta sessão:** 4
**Arquivo salvo:** `.session.md`
**Memória portátil:** `.agent-memory.md` atualizada (1 nova decisão)
**Memória do harness:** atualizada

Até a próxima. Use `/private-start` para retomar.
```

### Notas
- `.session.md` é sobrescrito a cada sessão; `.agent-memory.md` é incremental.
- Se houver código não commitado, o Claude pergunta antes se você quer commitar.

---

## Fluxo recomendado de uma sessão

```
abrir CLI
  └─ /private-start                  # 30s: contexto carregado
     └─ /private-task <descrição>    # plano + execução
        └─ /private-test             # roda testes
           └─ /private-review        # checagem pré-commit
              └─ git commit
                 └─ /private-end     # salva contexto
fechar CLI
```

Para correção de bug, troque `/private-task` por `/private-fix`.

---

## Customização

Os arquivos instalados ficam em `~/.claude/skills/<nome>.md` (global) ou `<PROJ>/.claude/skills/<nome>.md` (projeto). Edite à vontade.

> **Atenção:** o frontmatter (`---\nname: ...\ndescription: ...\n---`) é obrigatório no Claude Code. Sem ele, o skill não é registrado.

Para reverter uma customização local, basta rodar `./install.sh` de novo a partir do repositório `private-skills` — o instalador sobrescreve com a versão original (e mostra `↻ Atualizado` para os arquivos modificados).
