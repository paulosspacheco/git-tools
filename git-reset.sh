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
# Versão: 1.3.1
# Data:   2026-10-09
#
# Objetivo da versão:
#   - A confirmação só prossegue com resposta afirmativa (s ou sim); antes,
#     qualquer resposta diferente de n/N (como "nao") executava o reset --hard
#   - Não executa o reset quando o repositório tem apenas um commit, e não
#     informa sucesso nem oferece apagar a tag se o git reset falhar
#
# Observações de uso:
#   - Executar na raiz do repositório (pasta com .git), com ao menos 2 commits
#   - A resposta padrão da confirmação é n: Enter cancela
#   - Com janela (zenity), os botões Sim e Não funcionam como antes
#   - A tag sugerida para remoção é a última em ordem de versão
# Dependências: git-lib.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

if ! git rev-parse --verify HEAD~1 >/dev/null 2>&1; then
  echo "❌ O repositório não tem um commit anterior para voltar (HEAD~1)." >&2
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
if [[ ! "${CONFIRM,,}" =~ ^(s|sim)$ ]]; then
  echo "⚠ Operação cancelada pelo usuário."
  exit 0
fi

# Captura informações do commit antes do reset
REMOVED_MSG=$(git log --format="%s" HEAD -1)
LAST_TAG=$(git tag --sort=-version:refname | head -1)

echo ""
echo "Executando git reset --hard HEAD~1 ..."
if ! git reset --hard HEAD~1; then
  echo "" >&2
  echo "❌ Falha ao executar git reset --hard HEAD~1." >&2
  exit 1
fi

echo ""
echo "✔ Reset concluído — você está 1 commit atrás."

# Detecta se o commit removido era um bump de versão
if [[ "$REMOVED_MSG" == "chore: bump version"* ]] && [ -n "$LAST_TAG" ]; then
  echo ""
  echo "ℹ️  O commit removido era um bump de versão ($LAST_TAG)"
  echo "   Manter a tag pode causar inconsistência com a versão atual."
  ask_confirm TAG_CONFIRM "Remover a tag $LAST_TAG?" "s"
  if [[ "${TAG_CONFIRM,,}" =~ ^(s|sim)$ ]]; then
    git tag -d "$LAST_TAG"
    echo "✔ Tag $LAST_TAG removida"
  else
    echo "⚠ Tag $LAST_TAG mantida — execute git-version.sh com cuidado"
  fi
fi