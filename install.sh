#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# private-skills — instalador
# =============================================================================
# Instala os skills do private-flow no Claude Code.
#
# Modos:
#   ./install.sh                       — instala globalmente (~/.claude/skills/)
#   ./install.sh --project             — instala em um projeto (pergunta o path)
#   ./install.sh --project <PATH>      — instala em <PATH>/.claude/skills/
#   ./install.sh --uninstall           — remove a instalação global
#   ./install.sh --uninstall --project [<PATH>] — remove de um projeto
#   ./install.sh --help                — exibe ajuda
# =============================================================================

VERSION="0.3.0"

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/skills" && pwd)"
GLOBAL_TARGET="$HOME/.claude/skills"

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
  echo "  Uso: ./install.sh [opção] [path]"
  echo ""
  echo "  Opções:"
  echo "    (sem opção)        Instala globalmente em ~/.claude/skills/"
  echo "                       Disponível em todos os projetos"
  echo ""
  echo "    --project          Instala em um projeto (.claude/skills/)"
  echo "                       Sem path, pergunta interativamente:"
  echo "                         1) usar o diretório atual"
  echo "                         2) informar outro path"
  echo ""
  echo "    --project <PATH>   Instala em <PATH>/.claude/skills/ (não-interativo)"
  echo "                       Aceita ~ e paths relativos. Se o diretório não"
  echo "                       existir, pergunta antes de criar."
  echo ""
  echo "    --uninstall                 Remove da instalação global"
  echo "    --uninstall --project [<PATH>]  Remove da instalação de um projeto"
  echo ""
  echo "    --version          Exibe a versão e sai"
  echo "    --help             Exibe esta mensagem"
  echo ""
  echo "  Exemplos:"
  echo "    ./install.sh                              # global"
  echo "    ./install.sh --project                    # interativo"
  echo "    ./install.sh --project ~/Projetos/api     # direto"
  echo "    ./install.sh --project .                  # diretório atual"
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
  echo "  Comandos disponíveis após reiniciar o Claude Code:"
  echo "    /private-start   — iniciar sessão"
  echo "    /private-create  — criar ou atualizar CLAUDE.md"
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

if [ "$SCOPE" = "global" ]; then
  TARGET="$GLOBAL_TARGET"
  SCOPE_LABEL="(global — todos os projetos)"
else
  # Resolve o path do projeto
  if [ -z "$PROJECT_PATH" ]; then
    PROJECT_PATH="$(prompt_project_path)"
  else
    PROJECT_PATH="$(expand_path "$PROJECT_PATH")"
  fi

  # Para instalação, garante que o diretório base existe;
  # para desinstalação, exige que já exista
  if [ "$MODE" = "install" ]; then
    ensure_project_dir "$PROJECT_PATH"
  elif [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Erro: diretório '$PROJECT_PATH' não existe.${NC}" >&2
    exit 1
  fi

  TARGET="$PROJECT_PATH/.claude/skills"
  SCOPE_LABEL="(projeto: $PROJECT_PATH)"
fi

if [ "$MODE" = "install" ]; then
  install_skills "$TARGET" "$SCOPE_LABEL"
else
  uninstall_skills "$TARGET" "$SCOPE_LABEL"
fi
