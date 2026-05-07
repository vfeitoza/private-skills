#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# private-skills — instalador
# =============================================================================
# Instala os skills do private-flow em Claude Code, OpenCode, ou ambos.
#
# Modos:
#   ./install.sh                              — Claude Code, global
#   ./install.sh --opencode                   — OpenCode, global
#   ./install.sh --all                        — Claude Code + OpenCode, global
#   ./install.sh --project [<PATH>]           — Claude Code, projeto
#   ./install.sh --opencode --project [<PATH>] — OpenCode, projeto
#   ./install.sh --all --project [<PATH>]     — ambos, projeto
#   ./install.sh --uninstall [...]            — desinstala (mesmas flags)
#   ./install.sh --help                       — exibe ajuda
# =============================================================================

VERSION="0.5.0"

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/skills" && pwd)"

# Targets por harness
CLAUDE_GLOBAL_TARGET="$HOME/.claude/skills"
CLAUDE_PROJECT_SUBDIR=".claude/skills"

OPENCODE_GLOBAL_TARGET="$HOME/.config/opencode/command"
OPENCODE_PROJECT_SUBDIR=".opencode/command"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SKILLS=(
  "private-start.md"
  "private-create.md"
  "private-task.md"
  "private-fix.md"
  "private-test.md"
  "private-doc.md"
  "private-review.md"
  "private-end.md"
)

usage() {
  echo ""
  echo "  private-skills installer v${VERSION}"
  echo ""
  echo "  Uso: ./install.sh [--opencode|--all] [--project [<PATH>]] [--uninstall]"
  echo ""
  echo "  Harness (escolha um; padrão: Claude Code):"
  echo "    (sem flag)    Claude Code"
  echo "    --opencode    OpenCode (sst/opencode)"
  echo "    --all         Claude Code + OpenCode (instala/desinstala em ambos)"
  echo ""
  echo "  Escopo:"
  echo "    (sem flag)         Global"
  echo "                         Claude Code → ~/.claude/skills/"
  echo "                         OpenCode    → ~/.config/opencode/command/"
  echo ""
  echo "    --project          Projeto (interativo: atual ou outro path)"
  echo "    --project <PATH>   Projeto em <PATH>"
  echo "                         Claude Code → <PATH>/.claude/skills/"
  echo "                         OpenCode    → <PATH>/.opencode/command/"
  echo ""
  echo "  Modo:"
  echo "    (sem flag)    Instala / atualiza"
  echo "    --uninstall   Remove os skills do(s) destino(s) selecionado(s)"
  echo ""
  echo "  Outros:"
  echo "    --version     Exibe a versão e sai"
  echo "    --help        Exibe esta mensagem"
  echo ""
  echo "  Exemplos:"
  echo "    ./install.sh                                  # Claude Code, global"
  echo "    ./install.sh --opencode                       # OpenCode, global"
  echo "    ./install.sh --all                            # ambos, global"
  echo "    ./install.sh --all --project ~/Projetos/api   # ambos, no projeto"
  echo "    ./install.sh --project ~/Projetos/api         # Claude Code, projeto direto"
  echo "    ./install.sh --opencode --project .           # OpenCode, dir atual"
  echo "    ./install.sh --uninstall --all                # remove em ambos"
  echo ""
}

# Expande ~ e resolve para path absoluto
expand_path() {
  local p="$1"
  # Expande ~ no início
  p="${p/#\~/$HOME}"
  # Resolve absoluto se possível (sem realpath para portabilidade)
  if [ -d "$p" ]; then
    (cd "$p" && pwd)
  else
    # Diretório ainda não existe — devolve normalizado
    case "$p" in
      /*) echo "$p" ;;
      *)  echo "$PWD/$p" ;;
    esac
  fi
}

# Pergunta o path do projeto interativamente (modo --project sem argumento)
prompt_project_path() {
  if [ ! -t 0 ] || [ ! -t 1 ]; then
    echo -e "${RED}Erro: --project sem path requer terminal interativo.${NC}" >&2
    echo "Use: ./install.sh --project <PATH>" >&2
    exit 1
  fi

  echo "" >&2
  echo "Onde instalar os skills?" >&2
  echo "  1) Diretório atual: $PWD" >&2
  echo "  2) Informar outro path" >&2
  echo "" >&2

  local choice raw
  read -rp "Escolha [1/2] (padrão: 1): " choice
  choice="${choice:-1}"

  case "$choice" in
    1)
      echo "$PWD"
      ;;
    2)
      read -rp "Informe o path do projeto: " raw
      if [ -z "$raw" ]; then
        echo -e "${RED}Erro: path vazio.${NC}" >&2
        exit 1
      fi
      expand_path "$raw"
      ;;
    *)
      echo -e "${RED}Opção inválida: $choice${NC}" >&2
      exit 1
      ;;
  esac
}

# Garante que o diretório do projeto existe (cria se o usuário aprovar)
ensure_project_dir() {
  local dir="$1"
  if [ -d "$dir" ]; then
    return 0
  fi

  if [ ! -t 0 ] || [ ! -t 1 ]; then
    echo -e "${RED}Erro: diretório '$dir' não existe (modo não-interativo).${NC}" >&2
    exit 1
  fi

  echo -e "${YELLOW}Diretório '$dir' não existe.${NC}" >&2
  read -rp "Criar? [s/N]: " yn
  case "$yn" in
    s|S|y|Y|sim|SIM|yes|YES)
      mkdir -p "$dir"
      ;;
    *)
      echo "Abortado." >&2
      exit 1
      ;;
  esac
}

check_skills_dir() {
  if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "${RED}Erro: diretório 'skills/' não encontrado em $(dirname "$SKILLS_DIR")${NC}"
    echo "Execute este script a partir do diretório raiz do private-skills."
    exit 1
  fi
}

install_skills() {
  local target="$1"
  local scope="$2"

  echo ""
  echo -e "${BLUE}Instalando private-skills ${scope}...${NC}"
  echo "  Destino: $target"
  echo ""

  mkdir -p "$target"

  local installed=0
  local skipped=0

  for skill in "${SKILLS[@]}"; do
    local src="$SKILLS_DIR/$skill"
    local dst="$target/$skill"

    if [ ! -f "$src" ]; then
      echo -e "  ${YELLOW}⚠ Não encontrado: $skill${NC}"
      continue
    fi

    if [ -f "$dst" ]; then
      # Verifica se é idêntico
      if cmp -s "$src" "$dst"; then
        echo -e "  ${YELLOW}= Sem mudanças: $skill${NC}"
        skipped=$((skipped + 1))
        continue
      fi
      echo -e "  ${BLUE}↻ Atualizado:   $skill${NC}"
    else
      echo -e "  ${GREEN}+ Instalado:    $skill${NC}"
    fi

    cp "$src" "$dst"
    installed=$((installed + 1))
  done

  echo ""
  if [ "$installed" -gt 0 ]; then
    echo -e "${GREEN}✓ $installed skill(s) instalado(s)/atualizado(s).${NC}"
  else
    echo -e "${YELLOW}Nenhuma mudança — tudo já estava atualizado.${NC}"
  fi

  echo ""
  echo "  Comandos disponíveis após reiniciar o agente:"
  echo "    /private-start   — iniciar sessão"
  echo "    /private-create  — criar ou atualizar AGENTS.md"
  echo "    /private-task    — nova implementação"
  echo "    /private-fix     — debugging"
  echo "    /private-test    — rodar testes"
  echo "    /private-doc     — documentação"
  echo "    /private-review  — revisão de código"
  echo "    /private-end     — encerrar sessão"
  echo ""
}

uninstall_skills() {
  local target="$1"
  local scope="$2"

  echo ""
  echo -e "${YELLOW}Removendo private-skills ${scope}...${NC}"
  echo "  Origem: $target"
  echo ""

  if [ ! -d "$target" ]; then
    echo "  Diretório não existe — nada a remover."
    echo ""
    return
  fi

  local removed=0

  for skill in "${SKILLS[@]}"; do
    local dst="$target/$skill"
    if [ -f "$dst" ]; then
      rm "$dst"
      echo -e "  ${RED}- Removido: $skill${NC}"
      removed=$((removed + 1))
    fi
  done

  if [ "$removed" -eq 0 ]; then
    echo "  Nenhum skill encontrado para remover."
  else
    echo ""
    echo -e "${GREEN}✓ $removed skill(s) removido(s).${NC}"
  fi
  echo ""
}

# =============================================================================
# Main
# =============================================================================

MODE="install"
SCOPE="global"
HARNESS="claude"
PROJECT_PATH=""

while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --version|-v)
      echo "private-skills v${VERSION}"
      exit 0
      ;;
    --opencode)
      HARNESS="opencode"
      ;;
    --claude)
      HARNESS="claude"
      ;;
    --all)
      HARNESS="all"
      ;;
    --project)
      SCOPE="project"
      # Se o próximo arg existe e não começa com '--', trata como path
      if [ $# -ge 2 ] && [ "${2#--}" = "$2" ]; then
        PROJECT_PATH="$2"
        shift
      fi
      ;;
    --uninstall)
      MODE="uninstall"
      ;;
    *)
      echo -e "${RED}Opção desconhecida: $1${NC}"
      usage
      exit 1
      ;;
  esac
  shift
done

check_skills_dir

# Resolve o path do projeto uma vez (compartilhado entre harnesses no modo --all)
if [ "$SCOPE" = "project" ]; then
  if [ -z "$PROJECT_PATH" ]; then
    PROJECT_PATH="$(prompt_project_path)"
  else
    PROJECT_PATH="$(expand_path "$PROJECT_PATH")"
  fi

  if [ "$MODE" = "install" ]; then
    ensure_project_dir "$PROJECT_PATH"
  elif [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Erro: diretório '$PROJECT_PATH' não existe.${NC}" >&2
    exit 1
  fi
fi

# Resolve target/label para um harness e executa install ou uninstall
run_for_harness() {
  local harness="$1"
  local label global_target subdir target scope_label

  case "$harness" in
    claude)
      label="Claude Code"
      global_target="$CLAUDE_GLOBAL_TARGET"
      subdir="$CLAUDE_PROJECT_SUBDIR"
      ;;
    opencode)
      label="OpenCode"
      global_target="$OPENCODE_GLOBAL_TARGET"
      subdir="$OPENCODE_PROJECT_SUBDIR"
      ;;
  esac

  if [ "$SCOPE" = "global" ]; then
    target="$global_target"
    scope_label="(${label}, global — todos os projetos)"
  else
    target="$PROJECT_PATH/$subdir"
    scope_label="(${label}, projeto: $PROJECT_PATH)"
  fi

  if [ "$MODE" = "install" ]; then
    install_skills "$target" "$scope_label"
  else
    uninstall_skills "$target" "$scope_label"
  fi
}

# Executa para o(s) harness(es) selecionado(s)
case "$HARNESS" in
  all)
    run_for_harness claude
    run_for_harness opencode
    ;;
  *)
    run_for_harness "$HARNESS"
    ;;
esac
