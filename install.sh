#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# private-skills — instalador
# =============================================================================
# Instala os skills do private-flow no Claude Code.
#
# Modos:
#   ./install.sh           — instala globalmente (~/.claude/skills/)
#   ./install.sh --project — instala no projeto atual (.claude/skills/)
#   ./install.sh --help    — exibe ajuda
# =============================================================================

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/skills" && pwd)"
GLOBAL_TARGET="$HOME/.claude/skills"
PROJECT_TARGET=".claude/skills"

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
  echo "  Uso: ./install.sh [opção]"
  echo ""
  echo "  Opções:"
  echo "    (sem opção)   Instala globalmente em ~/.claude/skills/"
  echo "                  Disponível em todos os projetos"
  echo ""
  echo "    --project     Instala no projeto atual em .claude/skills/"
  echo "                  Disponível apenas neste projeto"
  echo ""
  echo "    --uninstall           Remove da instalação global"
  echo "    --uninstall --project Remove da instalação do projeto atual"
  echo ""
  echo "    --help        Exibe esta mensagem"
  echo ""
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
        ((skipped++)) || true
        continue
      fi
      echo -e "  ${BLUE}↻ Atualizado:   $skill${NC}"
    else
      echo -e "  ${GREEN}+ Instalado:    $skill${NC}"
    fi

    cp "$src" "$dst"
    ((installed++)) || true
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
      ((removed++)) || true
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

for arg in "$@"; do
  case "$arg" in
    --help|-h)
      usage
      exit 0
      ;;
    --project)
      SCOPE="project"
      ;;
    --uninstall)
      MODE="uninstall"
      ;;
    *)
      echo -e "${RED}Opção desconhecida: $arg${NC}"
      usage
      exit 1
      ;;
  esac
done

check_skills_dir

if [ "$SCOPE" = "global" ]; then
  TARGET="$GLOBAL_TARGET"
  SCOPE_LABEL="(global — todos os projetos)"
else
  TARGET="$PROJECT_TARGET"
  SCOPE_LABEL="(projeto atual)"
fi

if [ "$MODE" = "install" ]; then
  install_skills "$TARGET" "$SCOPE_LABEL"
else
  uninstall_skills "$TARGET" "$SCOPE_LABEL"
fi
