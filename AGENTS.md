# private-skills

Coleção de 8 slash-commands em markdown para agentes de coding (Claude Code, OpenCode, e outros que sigam o padrão `AGENTS.md`), voltada para uso pessoal em projetos com stacks variadas.

> Este projeto adota `AGENTS.md` como spec única. `CLAUDE.md` é um symlink para este arquivo (compatibilidade com versões antigas do Claude Code).

## Stack

- **Linguagem:** Markdown (skills/comandos) + Bash (instalador)
- **Framework:** nenhum
- **Banco de dados:** nenhum
- **Interface:** instalador CLI (`install.sh`); skills consumidos pelos agentes via slash-commands

## Estrutura

```
.
├── install.sh        # instalador (Claude Code ou OpenCode; global ou por projeto)
├── skills/           # 8 arquivos .md, um por slash-command (fonte única)
├── README.md         # documentação para o usuário
├── CHANGELOG.md      # histórico de versões
├── LICENSE           # MIT
├── AGENTS.md         # este arquivo (contexto/spec do projeto)
└── CLAUDE.md         # symlink → AGENTS.md
```

Cada arquivo em `skills/` segue o formato:

```markdown
---
name: <nome-do-skill>
description: <quando e por que invocá-lo — usado pelo Claude Code para auto-discovery; aparece no menu `/` do OpenCode>
---

# <nome-do-skill>

<corpo: passos, templates, notas>
```

O frontmatter YAML é **obrigatório** para Claude Code (sem ele o harness não registra como skill). O OpenCode ignora o campo `name:` (deriva do filename) mas aceita o frontmatter sem reclamar.

## Comandos essenciais

```bash
# Claude Code — global / projeto
./install.sh
./install.sh --project ~/meu-projeto

# OpenCode — global / projeto
./install.sh --opencode
./install.sh --opencode --project ~/meu-projeto

# Desinstalar (mesmas flags + --uninstall)
./install.sh --uninstall
./install.sh --uninstall --opencode --project ~/meu-projeto

# Smoke test
bash -n install.sh && ./install.sh --help
```

Não há suíte de testes — o projeto é declarativo (markdown + bash). Verificação manual: rodar `--help`, `--version` e `bash -n` no instalador, e revisar visualmente o frontmatter de cada skill.

## Convenções

- **Idioma:** português brasileiro em todo o conteúdo (skills, README, mensagens do instalador). Frontmatter também em PT-BR para que os agentes reconheçam gatilhos em português.
- **Tom dos skills:** direto, técnico, sem floreios — são lidos por outro agente, não por humanos.
- **Templates concretos > prosa abstrata:** todo skill traz o formato exato do output esperado (briefing, plano, relatório).
- **Cada skill é autocontido:** sem dependências entre si, sem subagentes, sem diretórios de planejamento em disco. Mini-planos vivem na conversa.
- **Numeração de passos:** `### Passo N — ...` (com travessão em vez de hífen simples).
- **Argumento opcional:** se o skill aceita argumento, documentar em uma seção `## Argumento opcional` logo após `## Quando usar`.

## Decisões de arquitetura

- **`AGENTS.md` é canônico, `CLAUDE.md` é symlink:** `AGENTS.md` é o padrão cross-tool ([agents.md](https://agents.md)) lido por Claude Code, OpenCode, Cursor, Aider e outros. O symlink garante que Claude Code antigo (que só lê `CLAUDE.md`) continue funcionando sem duplicar conteúdo.
- **Fonte única em `skills/`:** o mesmo arquivo serve para Claude Code (copiado para `~/.claude/skills/`) e OpenCode (copiado para `~/.config/opencode/command/`). O instalador escolhe o destino; o conteúdo é idêntico.
- **Sem subagentes:** todos os comandos rodam no agente principal. Mantém o contexto coeso e evita overhead para uso solo.
- **`.session.md` é efêmero e gitignorado por padrão:** estado da última sessão fica na raiz do projeto consumidor, é sobrescrito a cada `/private-end`, e não vai para o git por padrão (gera ruído em PR e pode vazar notas pessoais). Versionar é opt-in.
- **Memória portátil em `.agent-memory.md`:** fatos duradouros (decisões arquiteturais, preferências do usuário, referências externas) ficam neste arquivo, gitignorado por padrão. Funciona em qualquer harness. No Claude Code, `private-end` também atualiza `~/.claude/projects/<proj>/memory/` (memória nativa); `.agent-memory.md` é a fonte portátil canônica.
- **OpenAPI é obrigatório quando há HTTP:** `private-task` e `private-doc` tratam endpoints sem documentação OpenAPI 3.x como tarefa incompleta. Decisão opinativa, mas consistente entre os skills.
- **Convivência com skills nativos:** Claude Code tem `init`, `review`, `security-review`; OpenCode tem suas próprias. Os `private-*` coexistem — não há conflito.
- **Instalação por cópia, não por symlink:** o `install.sh` faz `cp` para que mudanças no repo não afetem instalações já feitas até que o usuário rode `./install.sh` de novo. Trade-off: precisa rodar para atualizar; ganho: instalações estáveis.

## Fora do escopo

- Subagentes ou orquestração paralela.
- Integrações com serviços externos (Linear, Jira, Slack).
- Suporte oficial a outros idiomas além de PT-BR.
- Empacotamento via npm/brew/etc — instalação é via `git clone` + `./install.sh`.

## Contexto importante

- O instalador roda sob `set -euo pipefail`. Qualquer aritmética com contadores deve usar `var=$((var + 1))` — `((var++))` retorna exit-code 1 quando `var=0` e quebra o script (bug corrigido em 0.2.0).
- Ao adicionar um novo skill: criar `skills/<nome>.md` com frontmatter, adicionar à array `SKILLS=(...)` em `install.sh`, e listar em `README.md`, `CHANGELOG.md` e na mensagem final do instalador.
- Ao alterar um skill existente: bump de versão em `install.sh` (`VERSION="..."`) e entrada em `CHANGELOG.md`.
- O `AGENTS.md` deste repo (este arquivo) descreve o **meta-projeto** dos skills. Não confundir com o `AGENTS.md` que `private-create` gera nos projetos consumidores.
