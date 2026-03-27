#!/bin/bash
# =============================================================================
# git-feat.sh — Commit de nova funcionalidade
# =============================================================================
# Realiza um commit do tipo feat seguindo o padrão Conventional Commits.
# Adiciona todos os arquivos modificados e cria o commit com prefixo feat:
#
# Uso: ./git-feat.sh ["mensagem"]
#
# Versão: 1.0.0
# Dependências: git-lib.sh
# =============================================================================

source "$(dirname "$0")/git-lib.sh"

ask_required MSG "Mensagem da feature" "$1"

git add .
git commit -m "feat: $MSG"