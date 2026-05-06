---
name: private-end
description: Encerramento de sessão — escreve `.session.md` com estado atual e pendências, e atualiza a memória persistente do harness com fatos duradouros. Use quando o usuário invocar `/private-end`, ao terminar o trabalho do dia ou ao pausar o projeto por um período.
---

# private-end

Comando de encerramento de sessão. Salva o contexto efêmero em `.session.md` (no projeto) e o contexto duradouro na memória persistente do harness (`~/.claude/...`).

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

### Passo 4 — Garantir que `.session.md` está gitignorado

Por padrão, `.session.md` é estado de sessão pessoal e **não deve ser commitado** (gera ruído em PRs e pode vazar notas internas).

- Verifique se existe `.gitignore` na raiz; crie um se não existir
- Se `.session.md` ainda não estiver listado, adicione a linha `.session.md`
- Se o usuário preferir versionar (ex: projeto solo, quer histórico de sessões no git), pergunte uma única vez e respeite a escolha — registre na memória persistente para não perguntar de novo

### Passo 5 — Atualizar memória persistente

A memória persistente do harness fica em `~/.claude/projects/<projeto>/memory/` e sobrevive entre sessões. Diferente do `.session.md` (que é estado efêmero da última sessão), aqui só entram **fatos duradouros**:

- O que o projeto faz (memória `project`, se ainda não estiver salvo)
- Decisões arquiteturais relevantes tomadas hoje (memória `project`)
- Preferências do usuário identificadas (ex: "quer mensagens de commit em PT-BR") (memória `feedback`)
- Referências externas (ex: "tickets ficam no Linear projeto X") (memória `reference`)

**Não salve em memória persistente:**
- Estado da sessão (commits feitos, branch atual, pendências) → isso é `.session.md`
- O que pode ser inferido relendo o código ou o `git log`
- Detalhes efêmeros da conversa atual

### Passo 6 — Confirmar encerramento

```
## Sessão encerrada

**Duração:** [se souber]
**Commits desta sessão:** [quantidade]
**Arquivo salvo:** `.session.md`
**Memória atualizada:** sim

Até a próxima. Use `/private-start` para retomar.
```

## Notas
- `.session.md` = estado **efêmero** da última sessão (sobrescrito a cada `/private-end`); memória persistente = fatos **duradouros** sobre projeto/usuário
- Por padrão, `.session.md` fica gitignorado — versionar é opt-in
- Seja específico no "o que foi feito" — "implementei X" é melhor que "trabalhei no projeto"
- Se houver código não commitado, mencione e pergunte se quer commitar antes de encerrar
