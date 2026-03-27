#!/bin/bash
# =============================================================================
# git-fix.sh — Commit de correção de bug
# =============================================================================
# Realiza um commit do tipo fix seguindo o padrão Conventional Commits.
# Adiciona todos os arquivos modificados e cria o commit com prefixo fix:
#
# Uso: ./git-fix.sh ["mensagem"]
#
# Versão: 1.0.0
# Dependências: git-lib.sh
# =============================================================================

source "$(dirname "$0")/git-lib.sh"

ask_required MSG "Mensagem do fix" "$1"

git add .
git commit -m "fix: $MSG"