#!/bin/bash
# =============================================================================
# git-reset.sh — Desfaz o último commit e descarta todas as alterações
# =============================================================================
# Reverte o repositório para o estado do penúltimo commit, descartando
# permanentemente todas as mudanças não commitadas.
# Detecta automaticamente se o commit removido era um bump de versão e
# oferece remover a tag correspondente.
#
# ℹ️  Commits podem ser recuperados com git-undo-reset.sh
# ⚠️  Arquivos NUNCA commitados serão perdidos permanentemente
#
# Uso: git-reset.sh
#
# Versão: 1.3.0
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

ask_confirm CONFIRM "Tem certeza que deseja continuar?" "n"
if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
  echo "⚠ Operação cancelada pelo usuário."
  exit 0
fi

# Captura informações do commit antes do reset
REMOVED_MSG=$(git log --format="%s" HEAD -1)
LAST_TAG=$(git tag --sort=-version:refname | head -1)

echo ""
echo "Executando git reset --hard HEAD~1 ..."
git reset --hard HEAD~1

echo ""
echo "✔ Reset concluído — você está 1 commit atrás."

# Detecta se o commit removido era um bump de versão
if [[ "$REMOVED_MSG" == "chore: bump version"* ]]; then
  echo ""
  echo "ℹ️  O commit removido era um bump de versão ($LAST_TAG)"
  echo "   Manter a tag pode causar inconsistência com a versão atual."
  ask_confirm TAG_CONFIRM "Remover a tag $LAST_TAG?" "s"
  if [[ ! "$TAG_CONFIRM" =~ ^[Nn]$ ]]; then
    git tag -d "$LAST_TAG"
    echo "✔ Tag $LAST_TAG removida"
  else
    echo "⚠ Tag $LAST_TAG mantida — execute git-version.sh com cuidado"
  fi
fi