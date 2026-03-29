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

# ask_required MSG "Mensagem do fix" "$1"

# git add .
# git commit -m "fix: $MSG"
# ask_confirm ch "✔ Adicionando o fix: $MSG"

# 1. Tipo sempre precisa
ask_select ACAO "Tipo de correção:" corrige ajusta resolve melhora || exit 1

# 2. Se veio da LCL, usa direto
if [ -n "$1" ]; then
  MSG="$1"
else
#   ask_required MSG "Descreva o problema" ""
  ask_required MSG "Tipo: $ACAO\n\nDescreva o problema" ""
fi

# 3. Monta mensagem
COMMIT_MSG="fix: $ACAO $MSG"

# 4. Confirma
ask_confirm CONFIRM "Confirma o commit?\n\n$COMMIT_MSG"

if [ "$CONFIRM" != "s" ]; then
  notify_info "❌ Commit cancelado"
  exit 1
fi

# 5. Commit
git add .
git commit -m "$COMMIT_MSG"

notify_info "✔ Commit realizado:\n$COMMIT_MSG"

