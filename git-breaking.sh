#!/bin/bash
# =============================================================================
# git-breaking.sh — Commit de mudança incompatível (breaking change)
# =============================================================================
# Realiza um commit do tipo feat! seguindo o padrão Conventional Commits.
# Usado quando a mudança quebra compatibilidade com versões anteriores.
# Adiciona todos os arquivos modificados e cria o commit com prefixo feat!:
#
# Uso: git-breaking.sh ["mensagem"]
#
# Versão: 1.1.0
# Dependências: git-lib.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

# 1. Tipo de breaking change
ask_select ACAO "Tipo de breaking change:" remove altera renomeia reestrutura || exit 1

# 2. Mensagem
if [ -n "$1" ]; then
  MSG="$1"
else
  ask_required MSG "Tipo: $ACAO\n\nDescreva a quebra de compatibilidade" "" || exit 1
fi

# 3. Monta mensagem
COMMIT_MSG="feat!: $ACAO : $MSG"

# 4. Confirma
ask_confirm CONFIRM "⚠️ Breaking change — confirma o commit?\n\n$COMMIT_MSG"
if [ "$CONFIRM" != "s" ]; then
  notify_info "❌ Commit cancelado"
  exit 0
fi

# 5. Commit
git add .
git commit -m "$COMMIT_MSG"

notify_info "✔ Commit realizado:\n$COMMIT_MSG"