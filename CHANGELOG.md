# Changelog

Todas as mudanças relevantes em `private-skills` são documentadas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o projeto adota [Semantic Versioning](https://semver.org/lang/pt-BR/).

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
