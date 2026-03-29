#!/bin/bash
# =============================================================================
# git-fix.sh — Commit de correção de bug
# =============================================================================
# Realiza um commit do tipo fix seguindo o padrão Conventional Commits.
# Adiciona todos os arquivos modificados e cria o commit com prefixo fix:
#
# Uso: git-fix.sh ["mensagem"]
#
# Versão: 1.1.0
# Dependências: git-lib.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

# 1. Tipo de correção
ask_select ACAO "Tipo de correção:" corrige ajusta resolve melhora || exit 1

# 2. Mensagem
if [ -n "$1" ]; then
  MSG="$1"
else
  ask_required MSG "Tipo: $ACAO\n\nDescreva o problema" "" || exit 1
fi

# 3. Monta mensagem
COMMIT_MSG="fix: $ACAO : $MSG"

# 4. Confirma
ask_confirm CONFIRM "Confirma o commit?\n\n$COMMIT_MSG"
if [ "$CONFIRM" != "s" ]; then
  notify_info "❌ Commit cancelado"
  exit 0
fi

# 5. Commit
git add .
git commit -m "$COMMIT_MSG"

notify_info "✔ Commit realizado:\n$COMMIT_MSG"