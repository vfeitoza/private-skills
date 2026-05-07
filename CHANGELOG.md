# Changelog

Todas as mudanças relevantes em `private-skills` são documentadas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o projeto adota [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [0.4.0] — 2026-05-07

### Added
- **Suporte ao OpenCode (sst/opencode):** novas flags `--opencode` e `--opencode --project [PATH]` no instalador. Mesma fonte (`skills/`); apenas o destino muda (`~/.config/opencode/command/` ou `<PROJ>/.opencode/command/`).
- **Memória portátil em `.agent-memory.md`:** novo arquivo na raiz do projeto consumidor com fatos duradouros (decisões arquiteturais, preferências, referências). Funciona em qualquer harness. Lido por `/private-start` e atualizado por `/private-end`.
- **Symlink `CLAUDE.md → AGENTS.md`** no próprio repositório, adotando o padrão cross-tool [agents.md](https://agents.md). `private-create` agora gera `AGENTS.md` por padrão e oferece o symlink como retrocompatibilidade com Claude Code.
- **Estado D no `private-create`:** novo fluxo "projeto existente com `AGENTS.md`"; estado C virou "projeto legado só com `CLAUDE.md`" (oferece migração para `AGENTS.md` + symlink).
- **Guias detalhados de uso por harness:** `docs/USAGE-CLAUDE.md` e `docs/USAGE-OPENCODE.md` com exemplos por comando.
- `.gitignore` cobrindo também `.agent-memory.md`.

### Changed
- `private-start`: agora também lê `.agent-memory.md` e prefere `AGENTS.md` a `CLAUDE.md`.
- `private-end`: separa claramente memória portátil (`.agent-memory.md`, sempre) de memória nativa do Claude Code (espelhamento opcional). Em OpenCode/Cursor/Aider, o `.agent-memory.md` é a fonte canônica.
- `install.sh`: estrutura interna refatorada para suportar múltiplos harnesses (`HARNESS_LABEL`, `GLOBAL_TARGET` e `PROJECT_SUBDIR` resolvidos por harness). Help reescrito.
- `README.md`: tabela de compatibilidade com harnesses, comandos de instalação para Claude Code e OpenCode lado a lado, links para os guias detalhados.
- Meta-projeto: `CLAUDE.md` deste repo virou symlink para `AGENTS.md` (preservando histórico via `git mv`).

### Notes
- A fonte de skills permanece em `skills/` (decisão de arquitetura: um arquivo serve aos dois harnesses).

## [0.3.0] — 2026-05-07

### Added
- `install.sh --project <PATH>`: aceita o path do projeto como argumento, instalando em `<PATH>/.claude/skills/`. Suporta `~`, paths relativos e absolutos.
- `install.sh --project` (sem path): em terminal interativo, pergunta se deseja usar o diretório atual ou informar outro path.
- Validação do diretório de destino: se não existir em modo `install`, pergunta antes de criar; em modo `uninstall`, falha de forma explícita.
- Detecção de modo não-interativo: `--project` sem path em pipe/redirecionamento agora retorna erro claro em vez de travar.

### Changed
- Mensagens de `--help` e exemplos atualizados para refletir os novos modos.
- `SCOPE_LABEL` em modo projeto agora exibe o path absoluto do diretório, não mais o genérico "(projeto atual)".

## [0.2.0] — 2026-05-06

### Added
- Frontmatter YAML (`name`, `description`) em todos os 8 skills, permitindo registro e descoberta automática pelo Claude Code.
- `LICENSE` (MIT).
- `CHANGELOG.md`.
- `.gitignore` cobrindo `.session.md` e arquivos temporários.
- `CLAUDE.md` para o próprio repositório.
- Flags `--version` / `-v` no `install.sh`.

### Changed
- `private-end` agora gitignora `.session.md` por padrão e clarifica a fronteira entre estado efêmero (`.session.md`) e memória persistente do harness (`~/.claude/projects/.../memory/`).
- `README.md` revisado: URL de clonagem corrigida, seção sobre relação com skills nativos do Claude Code, e referência à licença.
- `install.sh`: removido o workaround `((var++)) || true` (substituído por `var=$((var+1))`, idiomático sob `set -e`).

### Fixed
- `private-create.md`: corrigida a numeração duplicada das perguntas no Bloco 3 (antiga "8" repetida).

## [0.1.0] — 2026-05-05

### Added
- Versão inicial com 8 skills: `private-start`, `private-create`, `private-task`, `private-fix`, `private-test`, `private-doc`, `private-review`, `private-end`.
- Instalador `install.sh` com modos global, projeto e desinstalação.
- README.md com instruções de instalação e atualização.
