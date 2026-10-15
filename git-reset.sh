#!/bin/bash
# =============================================================================
# git-reset.sh — Desfaz o último commit e descarta todas as alterações
# =============================================================================
# Reverte o repositório para o estado do penúltimo commit, descartando
# permanentemente as alterações não commitadas.
# Antes de desfazer, mostra o estado da pasta com o git-state.sh e só
# continua se o último commit ainda não foi enviado ao GitHub.
# Detecta automaticamente se o commit removido era um bump de versão e
# oferece remover a tag correspondente.
#
# ℹ️  Commits podem ser recuperados com git-undo-reset.sh
# ⚠️  Alterações não commitadas e arquivos novos adicionados e nunca
#     commitados são perdidos permanentemente
#
# Uso: git-reset.sh
#
# Versão: 1.4.0
# Data:   2026-10-15
#
# Objetivo da versão:
#   - A confirmação passa a ser o relatório do git-state.sh: a pessoa vê o
#     que será descartado e qual commit será desfeito antes de decidir
#   - Não desfaz um commit que já está no GitHub, porque isso deixaria a
#     pasta diferente do GitHub e faria o próximo envio falhar
#   - Mostra o resultado em janela, para quem usa o menu do gerenciador de
#     arquivos, onde a saída do terminal não aparece
#   - Versão 1.3.1: só s ou sim confirmam; não executa com um único commit
#
# Observações de uso:
#   - Executar na raiz do repositório (pasta com .git), com ao menos 2 commits
#   - Com janela, o botão Desfazer só libera depois de marcar a caixa de
#     confirmação; no terminal, Enter cancela e só s ou sim confirmam
#   - Arquivos fora do Git (nunca adicionados) não são tocados
#   - A verificação do GitHub usa o que o Git guardou no último envio
#   - A tag sugerida para remoção é a última em ordem de versão
# Dependências: git-lib.sh, git-state.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

STATE="/usr/local/bin/git-state.sh"

if [ ! -d ".git" ]; then
  notify_info "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro."
  exit 1
fi

if [ ! -f "$STATE" ]; then
  notify_info "❌ git-state.sh não encontrado em /usr/local/bin.\n\nRode o git-install.sh de novo."
  exit 1
fi

bash "$STATE" --reset
case $? in
  0) ;;
  2) exit 1 ;;
  *) echo "⚠ Operação cancelada pelo usuário."
     exit 0 ;;
esac

REMOVED_MSG=$(git log --format="%s" HEAD -1)
LAST_TAG=$(git tag --sort=-version:refname | head -1)

echo ""
echo "Executando git reset --hard HEAD~1 ..."
if ! git reset --hard HEAD~1; then
  notify_info "❌ Falha ao executar git reset --hard HEAD~1."
  exit 1
fi

RESULT="✔ Reset concluído: você está 1 commit atrás.\n\nDesfeito: $REMOVED_MSG\n\nO commit pode ser recuperado com o git-undo-reset."

if [[ "$REMOVED_MSG" == "chore: bump version"* ]] && [ -n "$LAST_TAG" ]; then
  ask_confirm TAG_CONFIRM "O commit desfeito era a marcação da versão $LAST_TAG.\n\nManter a tag pode causar inconsistência com a versão atual.\n\nRemover a tag $LAST_TAG?" "s"
  if [[ "${TAG_CONFIRM,,}" =~ ^(s|sim)$ ]]; then
    git tag -d "$LAST_TAG"
    RESULT="$RESULT\n\nTag $LAST_TAG removida."
  else
    RESULT="$RESULT\n\n⚠ Tag $LAST_TAG mantida: execute git-version.sh com cuidado."
  fi
fi

notify_info "$RESULT"