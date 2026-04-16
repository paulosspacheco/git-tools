#!/bin/bash
# =============================================================================
# git-feat.sh — Commit de nova funcionalidade
# =============================================================================
# Realiza um commit do tipo feat seguindo o padrão Conventional Commits.
# Adiciona todos os arquivos modificados e cria o commit com prefixo feat:
#
# Uso: git-feat.sh ["mensagem"]
#
# Versão: 1.1.0
# Dependências: git-lib.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

# 1. Tipo de funcionalidade (opcional, mas ajuda na clareza)
ask_select ACAO "Tipo de funcionalidade:" adiciona implementa integra refatora || exit 1

# 2. Mensagem
if [ -n "$1" ]; then
  MSG="$1"
else
  ask_required MSG "Tipo: $ACAO\n\nDescreva a nova funcionalidade" "" || exit 1
fi

# 3. Monta mensagem
COMMIT_MSG="feat: $ACAO : $MSG"

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