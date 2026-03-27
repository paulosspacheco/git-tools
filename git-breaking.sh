#!/bin/bash
# =============================================================================
# git-breaking.sh — Commit de mudança incompatível (breaking change)
# =============================================================================
# Realiza um commit do tipo feat! seguindo o padrão Conventional Commits.
# Usado quando a mudança quebra compatibilidade com versões anteriores.
# Adiciona todos os arquivos modificados e cria o commit com prefixo feat!:
#
# Uso: ./git-breaking.sh ["mensagem"]
#
# Versão: 1.0.0
# Dependências: git-lib.sh
# =============================================================================

source "$(dirname "$0")/git-lib.sh"

ask_required MSG "Mensagem da quebra de compatibilidade" "$1"

git add .
git commit -m "feat!: $MSG"