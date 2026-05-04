# private-end

Comando de encerramento de sessão. Salva o contexto em memória e escreve o arquivo `.session.md` no projeto.

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

Se o arquivo já existir, **sobrescreva** — não acumule sessões no mesmo arquivo. O histórico fica no git.

### Passo 4 — Salvar memória persistente

Salve nas memórias do Claude (arquivo em `~/.claude/projects/`):
- O que o projeto faz (se ainda não estiver salvo)
- Decisões arquiteturais relevantes tomadas hoje
- Pendências críticas para a próxima sessão
- Qualquer preferência ou padrão identificado no projeto

### Passo 5 — Confirmar encerramento

```
## Sessão encerrada

**Duração:** [se souber]
**Commits desta sessão:** [quantidade]
**Arquivo salvo:** `.session.md`
**Memória atualizada:** sim

Até a próxima. Use `/private-start` para retomar.
```

## Notas
- O `.session.md` deve ser commitado junto com o código — é parte do projeto
- Seja específico no "o que foi feito" — "implementei X" é melhor que "trabalhei no projeto"
- Se houver código não commitado, mencione e pergunte se quer commitar antes de encerrar
