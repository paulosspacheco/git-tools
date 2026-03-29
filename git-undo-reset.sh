#!/bin/bash
# =============================================================================
# git-undo-reset.sh — Recupera commits após um git reset --hard
# =============================================================================
# Usa o git reflog para localizar e restaurar o estado anterior ao reset.
# Verifica e oferece recriar a tag de versão removida pelo git-reset.sh.
#
# ⚠️  Não recupera arquivos que nunca foram commitados.
#
# Uso: git-undo-reset.sh
#
# Versão: 1.2.0
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

ask_required POSITION "Qual posição do reflog deseja recuperar? (padrão: 1)" "1"

echo ""
echo "⚠️  Você está prestes a executar: git reset --hard HEAD@{$POSITION}"
echo ""

ask_confirm CONFIRM "Tem certeza?" "n"
if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
  echo "⚠ Operação cancelada pelo usuário."
  exit 0
fi

echo ""
git reset --hard "HEAD@{$POSITION}"

if [ $? -ne 0 ]; then
  echo ""
  echo "❌ Falha na recuperação. Tente manualmente: git reset --hard HEAD@{1}" >&2
  exit 1
fi

echo ""
echo "✔ Recuperação realizada com sucesso!"
echo "  Execute 'git log --oneline -10' para verificar o histórico."

# Verifica consistência da tag de versão
load_config
if [ -n "$VERSION" ]; then
  if ! git tag | grep -q "v$VERSION"; then
    echo ""
    echo "ℹ️  A tag v$VERSION não existe mas .gitproject indica VERSION=$VERSION"
    ask_confirm TAG_CONFIRM "Recriar a tag v$VERSION?" "s"
    if [[ ! "$TAG_CONFIRM" =~ ^[Nn]$ ]]; then
      git tag "v$VERSION"
      echo "✔ Tag v$VERSION recriada"
    else
      echo "⚠ Tag v$VERSION ausente — execute git-version.sh com cuidado"
    fi
  fi
fi