# private-skills

Coleção de 8 slash-commands em markdown para o Claude Code, voltada para uso pessoal em projetos com stacks variadas.

## Stack

- **Linguagem:** Markdown (skills) + Bash (instalador)
- **Framework:** nenhum
- **Banco de dados:** nenhum
- **Interface:** instalador CLI (`install.sh`); skills consumidos pelo Claude Code via slash-commands

## Estrutura

```
.
├── install.sh        # instalador (global ou por projeto)
├── skills/           # 8 arquivos .md, um por slash-command
├── README.md         # documentação para o usuário
├── CHANGELOG.md      # histórico de versões
├── LICENSE           # MIT
└── CLAUDE.md         # este arquivo (contexto para o Claude)
```

Cada skill em `skills/` segue o formato:

```markdown
---
name: <nome-do-skill>
description: <quando e por que invocá-lo — usado pelo Claude para auto-discovery>
---

# <nome-do-skill>

<corpo do skill: passos, templates, notas>
```

O frontmatter YAML é **obrigatório** — sem ele o harness do Claude Code não registra o arquivo como skill invocável.

## Comandos essenciais

```bash
# Instalar globalmente (~/.claude/skills/)
./install.sh

# Instalar no projeto atual (.claude/skills/)
./install.sh --project

# Desinstalar
./install.sh --uninstall
./install.sh --uninstall --project

# Smoke test
bash -n install.sh && ./install.sh --help
```

Não há suíte de testes — o projeto é declarativo (markdown + bash). Verificação manual: rodar `--help`, `--version` e `bash -n` no instalador, e revisar visualmente o frontmatter de cada skill.

## Convenções

- **Idioma:** português brasileiro em todo o conteúdo (skills, README, mensagens do instalador). Frontmatter também em PT-BR para que o Claude reconheça gatilhos em português.
- **Tom dos skills:** direto, técnico, sem floreios — são lidos por outro agente, não por humanos.
- **Templates concretos > prosa abstrata:** todo skill traz o formato exato do output esperado (briefing, plano, relatório).
- **Cada skill é autocontido:** sem dependências entre si, sem subagentes, sem diretórios de planejamento em disco. Mini-planos vivem na conversa.
- **Numeração de passos:** `### Passo N — ...` (com travessão em vez de hífen simples).
- **Argumento opcional:** se o skill aceita argumento, documentar em uma seção `## Argumento opcional` logo após `## Quando usar`.

## Decisões de arquitetura

- **Sem subagentes:** todos os comandos rodam no agente principal. Mantém o contexto coeso e evita overhead para uso solo.
- **`.session.md` é efêmero e gitignorado por padrão:** estado da última sessão fica na raiz do projeto consumidor, é sobrescrito a cada `/private-end`, e não vai para o git por padrão (gera ruído em PR e pode vazar notas pessoais). Versionar é opt-in.
- **Memória persistente é separada de `.session.md`:** `~/.claude/projects/<projeto>/memory/` guarda fatos duradouros (o que o projeto faz, decisões arquiteturais, preferências do usuário). Estado de sessão (commits feitos, branch atual, pendências do dia) **não** entra lá.
- **OpenAPI é obrigatório quando há HTTP:** `private-task` e `private-doc` tratam endpoints sem documentação OpenAPI 3.x como tarefa incompleta. Decisão opinativa, mas consistente entre os skills.
- **Convivência com skills nativos do Claude Code:** os skills `private-*` coexistem com os nativos (`init`, `review`, `security-review`). Os privados são preferidos por terem fluxo integrado com `.session.md`/memória e por serem em PT-BR; os nativos seguem disponíveis quando preferíveis (ex: `security-review` é mais profundo que `private-review` em segurança).
- **Instalação por cópia, não por symlink:** o `install.sh` faz `cp` para que mudanças no repo não afetem instalações já feitas até que o usuário rode `./install.sh` de novo. Trade-off: precisa rodar para atualizar; ganho: instalações estáveis.

## Fora do escopo

- Subagentes ou orquestração paralela.
- Integrações com serviços externos (Linear, Jira, Slack).
- Suporte oficial a outros idiomas além de PT-BR.
- Empacotamento via npm/brew/etc — instalação é via `git clone` + `./install.sh`.

## Contexto importante

- O instalador roda sob `set -euo pipefail`. Qualquer aritmética com contadores deve usar `var=$((var + 1))` — `((var++))` retorna exit-code 1 quando `var=0` e quebra o script (foi um bug corrigido em 0.2.0).
- Ao adicionar um novo skill: criar `skills/<nome>.md` com frontmatter, adicionar à array `SKILLS=(...)` em `install.sh`, e listar em `README.md`, `CHANGELOG.md` e na mensagem final do instalador.
- Ao alterar um skill existente: bump de versão em `install.sh` (`VERSION="..."`) e entrada em `CHANGELOG.md`.
- O `CLAUDE.md` deste repo (este arquivo) descreve o **meta-projeto** dos skills. Não confundir com o `CLAUDE.md` que `private-create` gera nos projetos consumidores.
