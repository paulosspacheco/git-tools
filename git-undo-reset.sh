#!/bin/bash
# =============================================================================
# git-undo-reset.sh — Recupera commits após um git reset --hard
# =============================================================================
# Usa o git reflog para localizar e restaurar o estado anterior ao reset.
# Não recupera arquivos que nunca foram commitados.
#
# Uso: git-undo-reset.sh
#
# Versão: 1.0.0
# Dependências: git-lib.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

echo "🔄 Tentando recuperar após git reset --hard..."
echo ""
echo "📜 Histórico recente de ações:"
echo "----------------------------------------"
git reflog --oneline | head -n 15
echo "----------------------------------------"
echo ""
echo "ℹ️  O reset geralmente aparece como HEAD@{1} ou HEAD@{2}"
echo ""

read -rp "Qual posição do reflog deseja recuperar? (padrão: 1): " POSITION
POSITION="${POSITION:-1}"

echo ""
echo "⚠️  Você está prestes a executar: git reset --hard HEAD@{$POSITION}"
echo ""
read -rp "Tem certeza? (digite 'sim' para confirmar): " CONFIRM

if [[ "$CONFIRM" != "sim" && "$CONFIRM" != "SIM" ]]; then
  echo "⚠ Operação cancelada pelo usuário."
  exit 0
fi

echo ""
git reset --hard "HEAD@{$POSITION}"

if [ $? -eq 0 ]; then
  echo ""
  echo "✔ Recuperação realizada com sucesso!"
  echo "  Execute 'git log --oneline -10' para verificar o histórico."
else
  echo ""
  echo "❌ Falha na recuperação. Tente manualmente: git reset --hard HEAD@{1}" >&2
  exit 1
fi