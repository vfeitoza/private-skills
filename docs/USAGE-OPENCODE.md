# Guia de uso — OpenCode

Este guia mostra, com exemplos, como usar cada um dos 8 comandos `/private-*` no **OpenCode** ([sst/opencode](https://opencode.ai)). Para o guia equivalente do Claude Code, veja [`USAGE-CLAUDE.md`](USAGE-CLAUDE.md).

## Setup

### 1. Instalar

```bash
git clone https://github.com/vfeitoza/private-skills.git ~/private-skills
cd ~/private-skills

# Global (todos os projetos)
./install.sh --opencode

# OU em um projeto específico
./install.sh --opencode --project ~/Projetos/meu-app
```

Os arquivos vão para `~/.config/opencode/command/` (global) ou `<PROJ>/.opencode/command/` (projeto).

### 2. Reiniciar o OpenCode

Saia (`Ctrl+D`) e abra novamente. Os comandos só são registrados na inicialização.

### 3. Verificar registro

No OpenCode, digite `/` e role até encontrar:

```
/private-start    Início de sessão de trabalho — lê o estado do projeto…
/private-create   Cria ou atualiza o `AGENTS.md` do projeto…
/private-task     Inicia uma nova implementação…
…
```

Se os 8 não aparecerem: você reiniciou? Os arquivos estão em `~/.config/opencode/command/`?

---

## Conceitos centrais

### Invocação é sempre explícita

Diferente do Claude Code, no OpenCode os comandos `/private-*` são **invocados explicitamente**. O agente não lê a `description` do frontmatter para decidir invocar automaticamente — você digita `/private-task`, `/private-fix`, etc.

```
/private-task implementar login com JWT       # explícito
```

Pedir "implementa um login" sem invocar `/private-task` faz o agente seguir um caminho genérico, sem o mini-plano nem a estrutura prevista no skill.

> **Hábito recomendado:** comece toda sessão com `/private-start` e termine com `/private-end`. Para feature/fix, use `/private-task` ou `/private-fix` antes de descrever o pedido.

### `AGENTS.md` é a spec canônica

OpenCode lê **`AGENTS.md`** automaticamente na raiz do projeto (padrão [agents.md](https://agents.md)). É lá que ficam:
- O que o projeto faz
- Stack
- Convenções
- Decisões arquiteturais

`/private-create` gera esse arquivo. Se o projeto já tem `CLAUDE.md` legado, ele oferece migrar para `AGENTS.md` mantendo o `CLAUDE.md` como symlink.

### Arquivos de estado no projeto

| Arquivo | Onde fica | Ciclo de vida | Conteúdo |
|---|---|---|---|
| `.session.md` | raiz do projeto | sobrescrito a cada `/private-end` | estado da última sessão |
| `.agent-memory.md` | raiz do projeto | incremental (atualizado por `/private-end`) | fatos duradouros |

Os dois ficam **gitignorados por padrão**. No OpenCode, **não há memória nativa do harness** — o `.agent-memory.md` é a única fonte canônica de fatos duradouros entre sessões. Por isso é especialmente importante usar `/private-end` ao terminar.

### Frontmatter é tolerante

Os skills têm frontmatter com `name:` e `description:`. O OpenCode usa só o `description` (mostrado no menu `/`); o `name:` é ignorado. Não causa erro nem warning.

---

## `/private-start` — início de sessão

### Quando usar
Toda vez que você abre o OpenCode num projeto, antes de qualquer outra coisa.

### Exemplo de uso

```
/private-start
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
- Se não houver `.agent-memory.md`, menciona que será criado no primeiro `/private-end`.
- O OpenCode pode mostrar a saída streamada — espere o agente terminar antes de digitar.

---

## `/private-create` — cria ou atualiza `AGENTS.md`

### Quando usar
- Projeto novo (vazio): levanta requisitos via perguntas
- Projeto existente sem spec: oferece ler o código e gerar
- Projeto legado só com `CLAUDE.md`: oferece migrar para `AGENTS.md` + symlink
- Projeto com `AGENTS.md`: atualiza, regenera ou complementa

### Exemplo — projeto vazio

```
/private-create
```

**Resposta:**

```
Projeto vazio detectado. Vou levantar requisitos por blocos de perguntas.

Bloco 1 — Identidade do projeto
1. Qual é o nome do projeto?
```

Você responde uma pergunta de cada vez. Ao final, o agente apresenta o `AGENTS.md` proposto e pergunta se pode salvar.

### Exemplo — projeto existente, ler código

```
/private-create
```

**Resposta:**

```
Encontrei arquivos no projeto. Posso ler o código para gerar o
AGENTS.md automaticamente, ou prefere responder perguntas manualmente?
(ler código / responder perguntas)
```

Você diz "ler código" e o agente varre `package.json`, `pyproject.toml`, etc., infere a stack, apresenta um resumo, pede confirmação e gera o `AGENTS.md`.

### Exemplo — migrar `CLAUDE.md` legado

```
/private-create
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

> Recomendado: opção 1. OpenCode prefere ler `AGENTS.md` (é o padrão dele); o symlink mantém o Claude Code antigo funcionando.

---

## `/private-task` — nova implementação

### Quando usar
Qualquer feature, mudança de comportamento, refatoração ou integração.

### Exemplo — tarefa não-trivial

```
/private-task adicionar rate limiting em /api/login
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

Você responde "sim" e o agente executa exatamente o plano. Ao final, informa em 2-3 linhas o que foi feito.

### Exemplo — tarefa trivial

```
/private-task corrigir typo "lenght" → "length" em validators.ts
```

**Resposta:** o agente vai direto, sem mini-plano (typo é trivial).

### Notas
- Endpoints HTTP **exigem** documentação OpenAPI atualizada como parte da tarefa. Não negociável.
- Se o escopo mudar durante a execução, o agente para e informa.
- Se você usar tools/permissions específicas no OpenCode (ex: `read_only`), garanta que o agente atual tem permissão para escrever — caso contrário o plano será apresentado mas a execução falhará.

---

## `/private-fix` — debugging estruturado

### Quando usar
Bug, erro inesperado, comportamento incorreto, falha em teste.

### Exemplo — bug não-óbvio

```
/private-fix usuários intermitentemente recebem 401 mesmo com token válido
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

Você aprova; o agente lê os arquivos, confirma a hipótese (ou descarta), e informa antes de aplicar a correção.

### Exemplo — bug óbvio

```
/private-fix import faltando em utils/format.ts: ReferenceError: format is not defined
```

**Resposta:** o agente vai direto adicionar o import faltante (sem mini-plano de investigação).

---

## `/private-test` — testes e cobertura

### Quando usar
Após implementar feature ou corrigir bug.

### Exemplo

```
/private-test
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
- O OpenCode pode pedir confirmação antes de executar comandos shell — aprove para ver a saída completa.

---

## `/private-doc` — documentação

### Quando usar
Atualizar README, criar ADR, documentar API, escrever guia de contribuição, atualizar OpenAPI.

### Exemplo — documentação estrutural

```
/private-doc documentar o fluxo de autenticação
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
- Para mudanças pontuais (corrigir comentário, atualizar versão no README), o agente vai direto sem plano.
- Se o projeto expõe HTTP, atualizar `openapi.yaml` é parte do trabalho — não opcional.

---

## `/private-review` — revisão pré-commit

### Quando usar
Antes de fazer commit ou push, para avaliar segurança, corretude e qualidade do diff atual.

### Exemplo

```
/private-review
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
Ao encerrar o trabalho do dia ou pausar o projeto. **Especialmente importante no OpenCode**, onde o `.agent-memory.md` é a única persistência de fatos duradouros entre sessões.

### Exemplo

```
/private-end
```

**Diálogo esperado:**

```
Tem algo que ficou pela metade ou que precisa continuar na próxima sessão?
> Falta adicionar o teste de integração do rate-limit, próximo do PR

Alguma decisão tomada hoje que vale registrar?
> Decidimos usar in-memory para rate-limit por enquanto (Redis vira sprint 12)
```

O agente então:
1. Escreve `.session.md` com estado atual e pendências
2. Adiciona `.session.md` e `.agent-memory.md` ao `.gitignore` (se ainda não estiverem)
3. Atualiza `.agent-memory.md` com a decisão (in-memory rate-limit) na seção `## Decisões arquiteturais`
4. (No OpenCode, **não** atualiza memória nativa do harness — não há)
5. Confirma:

```
## Sessão encerrada

**Duração:** ~2h
**Commits desta sessão:** 4
**Arquivo salvo:** `.session.md`
**Memória portátil:** `.agent-memory.md` atualizada (1 nova decisão)
**Memória do harness:** n/a (OpenCode)

Até a próxima. Use `/private-start` para retomar.
```

### Notas
- `.session.md` é sobrescrito a cada sessão; `.agent-memory.md` é incremental.
- Se houver código não commitado, o agente pergunta antes se você quer commitar.
- Como o OpenCode não tem memória nativa, **se você pular o `/private-end`, o `.agent-memory.md` não é atualizado** e fatos importantes podem se perder. Crie o hábito.

---

## Fluxo recomendado de uma sessão

```
abrir OpenCode
  └─ /private-start                  # 30s: contexto carregado
     └─ /private-task <descrição>    # plano + execução
        └─ /private-test             # roda testes
           └─ /private-review        # checagem pré-commit
              └─ git commit
                 └─ /private-end     # salva contexto (essencial!)
fechar OpenCode
```

Para correção de bug, troque `/private-task` por `/private-fix`.

---

## Customização

Os arquivos instalados ficam em `~/.config/opencode/command/<nome>.md` (global) ou `<PROJ>/.opencode/command/<nome>.md` (projeto). Edite à vontade.

> O frontmatter (`---\nname: ...\ndescription: ...\n---`) não é obrigatório no OpenCode (ele aceita arquivos `.md` puros). Mas mantenha-o por compatibilidade — assim o mesmo arquivo serve para ambos os harnesses, e a `description` aparece no menu `/`.

Para reverter uma customização local, basta rodar `./install.sh --opencode` de novo a partir do repositório `private-skills` — o instalador sobrescreve com a versão original (e mostra `↻ Atualizado` para os arquivos modificados).

---

## Diferenças relevantes em relação ao Claude Code

| Aspecto | Claude Code | OpenCode |
|---|---|---|
| Diretório dos comandos | `~/.claude/skills/` | `~/.config/opencode/command/` |
| Invocação | Explícita ou automática (via `description`) | Apenas explícita (digite `/<nome>`) |
| Memória nativa do harness | Sim (`~/.claude/projects/<proj>/memory/`) | Não — `.agent-memory.md` é a fonte canônica |
| Frontmatter obrigatório | Sim | Não (mas recomendado para portabilidade) |
| Lê `AGENTS.md` na raiz do projeto | Sim (4.x) | Sim (nativo) |
| Lê `CLAUDE.md` na raiz do projeto | Sim | Não (use o symlink para `AGENTS.md`) |

A consequência prática mais importante: **no OpenCode, sempre invoque os comandos explicitamente e nunca pule o `/private-end`** — é seu único mecanismo de persistência de contexto duradouro.
