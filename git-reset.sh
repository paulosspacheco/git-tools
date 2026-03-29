#!/bin/bash
# =============================================================================
# git-reset.sh — Desfaz o último commit e descarta todas as alterações
# =============================================================================
# Reverte o repositório para o estado do penúltimo commit, descartando
# permanentemente todas as mudanças não commitadas.
#
# ⚠️  ATENÇÃO: Este comando vai fazer o seguinte:
#    • Apagar o último commit
#    • Descartar TODAS as alterações nos arquivos
#    • Arquivos nunca commitados serão perdidos permanentemente
#    • Commits podem ser recuperados via git-undo-reset.sh
#
# Uso: git-reset.sh
#
# Versão: 1.0.0
# Dependências: git-lib.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

echo "⚠️  ATENÇÃO: Este comando vai fazer o seguinte:"
echo "   • Apagar o último commit"
echo "   • Descartar TODAS as alterações nos arquivos não commitadas"
echo ""
echo "ℹ️  O commit pode ser recuperado com git-undo-reset.sh"
echo "   Arquivos NUNCA commitados serão perdidos permanentemente"
echo ""

read -rp "Tem certeza que deseja continuar? (digite 'sim' para confirmar): " CONFIRM

if [[ "$CONFIRM" != "sim" && "$CONFIRM" != "SIM" ]]; then
  echo "⚠ Operação cancelada pelo usuário."
  exit 0
fi

echo "Executando git reset --hard HEAD~1 ..."

git reset --hard HEAD~1

echo ""
echo "✔ Reset concluído — você está 1 commit atrás."