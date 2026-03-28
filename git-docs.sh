#!/bin/bash
# =============================================================================
# git-docs.sh — Commit de documentação
# =============================================================================
# Realiza um commit do tipo docs seguindo o padrão Conventional Commits.
# Adiciona todos os arquivos modificados e cria o commit com prefixo docs:
#
# Uso: ./git-docs.sh ["mensagem"]
#
# Versão: 1.0.0
# Dependências: git-lib.sh
# =============================================================================

source "$(dirname "$0")/git-lib.sh"

ask_required MSG "Mensagem da documentação" "$1"

git add .
git commit -m "docs: $MSG"