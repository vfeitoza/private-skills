---
name: private-end
description: Encerramento de sessão — escreve `.session.md` (estado efêmero) e atualiza `.agent-memory.md` (memória portátil duradoura). No Claude Code, espelha opcionalmente para a memória nativa do harness. Use quando o usuário invocar `/private-end`, ao terminar o trabalho do dia ou ao pausar o projeto por um período.
---

# private-end

Comando de encerramento de sessão. Salva o estado efêmero da sessão em `.session.md` e fatos duradouros em `.agent-memory.md` (portátil entre harnesses). No Claude Code, espelha opcionalmente para a memória nativa em `~/.claude/...`.

## Quando usar
Ao terminar o trabalho do dia ou ao pausar o projeto por um período.

## O que fazer

### Passo 1 — Coletar o estado atual
- Rode `git status` para ver o que está pendente
- Rode `git log --oneline -5` para ver os commits da sessão
- Revise a conversa atual para identificar o que foi feito

### Passo 2 — Perguntar sobre pendências
Pergunte ao usuário:
- "Tem algo que ficou pela metade ou que precisa continuar na próxima sessão?"
- "Alguma decisão tomada hoje que vale registrar?"

Se o usuário não quiser responder, infira do contexto da conversa.

### Passo 3 — Escrever o `.session.md` no projeto

Crie ou sobrescreva o arquivo `.session.md` na raiz do projeto com este formato:

```markdown
# Sessão — [data no formato YYYY-MM-DD]

## O que foi feito
- [item 1 — seja específico, não genérico]
- [item 2]

## Estado atual
- **Branch:** [branch atual]
- **Último commit:** [hash curto] [mensagem]
- **Pendências no git:** [limpo / X arquivos modificados não commitados]

## Pendências para próxima sessão
- [ ] [tarefa pendente 1]
- [ ] [tarefa pendente 2]

## Decisões tomadas
- [decisão relevante tomada hoje, se houver]

## Contexto importante
[qualquer informação que seria útil retomar na próxima sessão — bugs conhecidos, limitações, dependências externas, etc.]
```

Se o arquivo já existir, **sobrescreva** — não acumule sessões no mesmo arquivo. O histórico fica no git (se commitado) ou na memória persistente.

### Passo 4 — Garantir que `.session.md` e `.agent-memory.md` estão gitignorados

Por padrão, esses arquivos são estado pessoal e **não devem ser commitados** (geram ruído em PRs e podem vazar notas internas).

- Verifique se existe `.gitignore` na raiz; crie um se não existir
- Se `.session.md` ou `.agent-memory.md` ainda não estiverem listados, adicione as linhas correspondentes
- Se o usuário preferir versionar (ex: projeto solo, quer histórico no git), pergunte uma única vez e respeite a escolha — registre essa preferência em `.agent-memory.md` para não perguntar de novo

### Passo 5 — Atualizar memória portátil em `.agent-memory.md`

`.agent-memory.md` fica na raiz do projeto consumidor e contém **fatos duradouros**, sobrevivendo entre sessões e funcionando em qualquer harness (Claude Code, OpenCode, Cursor, Aider). Diferente do `.session.md` (sobrescrito a cada sessão), o `.agent-memory.md` é **incremental**: você atualiza/adiciona, não substitui.

Estrutura recomendada:

```markdown
# Memória do projeto

> Fatos duradouros sobre este projeto. Atualizado pelo `/private-end`.
> Lido pelo `/private-start` em sessões futuras.

## Sobre o projeto
[O que faz, para quem, restrições principais. Atualize se mudar.]

## Decisões arquiteturais
- [YYYY-MM-DD] [decisão] — [motivo / contexto]
- [YYYY-MM-DD] [decisão] — [motivo / contexto]

## Preferências do usuário
- [preferência identificada — ex: "mensagens de commit em PT-BR"]
- [preferência — ex: "evita comentários em código"]

## Referências externas
- [Linear / Jira / Notion / etc — onde achar contexto adicional]

## Observações
- [bugs conhecidos, limitações, dependências externas]
```

**O que entra:**
- O que o projeto faz (atualize se mudar)
- Decisões arquiteturais relevantes tomadas hoje (com data)
- Preferências do usuário identificadas (ex: "quer mensagens de commit em PT-BR")
- Referências externas (ex: "tickets ficam no Linear projeto X")

**O que NÃO entra:**
- Estado da sessão (commits feitos, branch atual, pendências) → isso é `.session.md`
- O que pode ser inferido relendo o código ou o `git log`
- Detalhes efêmeros da conversa atual

### Passo 6 — (Apenas Claude Code) Atualizar memória nativa do harness

Se estiver rodando em **Claude Code**, espelhe os fatos duradouros relevantes no sistema de memória nativo (`~/.claude/projects/<projeto>/memory/`), respeitando os tipos:

- `project` — sobre o projeto e decisões arquiteturais
- `feedback` — preferências do usuário
- `reference` — referências externas
- `user` — informações sobre o usuário (papel, expertise)

Em **OpenCode** ou outros harnesses sem memória nativa, **pule este passo** — o `.agent-memory.md` já é a fonte canônica.

### Passo 7 — Confirmar encerramento

```
## Sessão encerrada

**Duração:** [se souber]
**Commits desta sessão:** [quantidade]
**Arquivo salvo:** `.session.md`
**Memória portátil:** `.agent-memory.md` [atualizado / sem mudanças]
**Memória do harness:** [atualizada / n/a]

Até a próxima. Use `/private-start` para retomar.
```

## Notas
- `.session.md` = estado **efêmero** da última sessão (sobrescrito a cada `/private-end`); `.agent-memory.md` = fatos **duradouros** sobre projeto/usuário (incremental)
- `.agent-memory.md` é portátil entre harnesses; memória nativa do Claude Code é um espelho opcional, não a fonte canônica
- Por padrão, ambos ficam gitignorados — versionar é opt-in
- Seja específico no "o que foi feito" — "implementei X" é melhor que "trabalhei no projeto"
- Se houver código não commitado, mencione e pergunte se quer commitar antes de encerrar
