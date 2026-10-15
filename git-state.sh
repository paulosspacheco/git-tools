#!/bin/bash
# =============================================================================
# git-state.sh — Mostra o estado da pasta antes de voltar atrás
# =============================================================================
# Exibe a pasta, o ramo, a versão, os últimos commits e as alterações ainda
# não commitadas, separando o que o git-reset.sh descarta do que ele não toca.
# Mostra também qual commit seria desfeito e para qual o repositório voltaria.
#
# Uso: git-state.sh
#
# Versão: 1.1.0
# Data:   2026-10-15
#
# Objetivo da versão:
#   - Mostra a data e a hora de cada commit (dd/mm/aaaa hh:mm) no lugar do
#     tempo relativo, que o Git escreve em inglês ("7 hours ago")
#   - Corta as mensagens de commit longas em 70 caracteres, terminando com
#     "…", para não encher a janela
#   - Versão 1.0.0: permitir conferir o estado da pasta pelo menu do
#     gerenciador de arquivos, onde a saída do terminal não aparece, antes
#     de rodar o git-reset.sh
#
# Observações de uso:
#   - Executar na raiz do repositório (pasta com .git)
#   - As mensagens completas continuam no git log; o corte é só na exibição
#   - Apenas mostra informações: não altera arquivos, commits nem tags
#   - Com janela (zenity), o resultado aparece numa janela de texto; sem
#     janela, é impresso no terminal
#   - No git-tools.conf, fica antes do git-reset.sh, para aparecer acima dele
#     no menu
# Dependências: git-lib.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

load_config

MAX_MSG=70

short_msg() {
  local LC_ALL=C.UTF-8
  local msg="$1"
  if [ ${#msg} -gt $MAX_MSG ]; then
    echo "${msg:0:$((MAX_MSG - 1))}…"
  else
    echo "$msg"
  fi
}

commit_line() {
  local ref="$1"
  local hash date msg
  IFS='|' read -r hash date msg < <(git log -1 --date=format:'%d/%m/%Y %H:%M' --format='%h|%cd|%s' "$ref")
  echo "$hash  $date  $(short_msg "$msg")"
}

REPORT=$(mktemp)
trap 'rm -f "$REPORT"' EXIT

BRANCH=$(git branch --show-current 2>/dev/null)
LAST_TAG=$(git tag --sort=-version:refname | head -1)

MODIFIED=()
STAGED_NEW=()
UNTRACKED=()
while IFS= read -r line; do
  [ -z "$line" ] && continue
  code="${line:0:2}"
  file="${line:3}"
  if [ "$code" = "??" ]; then
    UNTRACKED+=("$file")
  elif [ "${code:0:1}" = "A" ]; then
    STAGED_NEW+=("$file")
  else
    MODIFIED+=("$file")
  fi
done < <(git status --porcelain 2>/dev/null)

{
  echo "📁 Pasta: $(pwd)"
  echo "🌿 Ramo: ${BRANCH:-(sem ramo)}"
  [ -n "$VERSION" ] && echo "🏷  Versão no .gitproject: $VERSION"
  echo "🏷  Última tag: ${LAST_TAG:-(nenhuma)}"
  echo ""

  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    echo "🕘 Últimos commits:"
    while read -r ref; do
      echo "   $(commit_line "$ref")"
    done < <(git log --format='%H' -5)
  else
    echo "🕘 Ainda não há commits nesta pasta."
  fi
  echo ""

  if [ ${#MODIFIED[@]} -eq 0 ] && [ ${#STAGED_NEW[@]} -eq 0 ] && [ ${#UNTRACKED[@]} -eq 0 ]; then
    echo "✔ Tudo salvo: não há alterações fora de commit."
  else
    if [ ${#MODIFIED[@]} -gt 0 ]; then
      echo "✏️  Alterados e não commitados (o git-reset descarta):"
      printf '   %s\n' "${MODIFIED[@]}"
      echo ""
    fi
    if [ ${#STAGED_NEW[@]} -gt 0 ]; then
      echo "⚠️  Novos, adicionados e nunca commitados (o git-reset apaga):"
      printf '   %s\n' "${STAGED_NEW[@]}"
      echo ""
    fi
    if [ ${#UNTRACKED[@]} -gt 0 ]; then
      echo "📄 Fora do Git (o git-reset não mexe):"
      printf '   %s\n' "${UNTRACKED[@]}"
    fi
  fi
  echo ""

  if git rev-parse --verify HEAD~1 >/dev/null 2>&1; then
    REMOVED_MSG=$(git log --format="%s" HEAD -1)
    echo "↩  Se rodar o git-reset agora:"
    echo "   desfaz:  $(commit_line HEAD)"
    echo "   volta a: $(commit_line HEAD~1)"
    if [[ "$REMOVED_MSG" == "chore: bump version"* ]] && [ -n "$LAST_TAG" ]; then
      echo "   e oferece remover a tag $LAST_TAG"
    fi
    echo "   O commit desfeito pode ser recuperado com o git-undo-reset."
  else
    echo "↩  Não há commit anterior para voltar: o git-reset não pode ser usado."
  fi
} > "$REPORT"

if _has_display && command -v zenity >/dev/null; then
  zenity --text-info \
         --title="Git Tools — Estado da pasta" \
         --filename="$REPORT" \
         --width=700 \
         --height=500 2>/dev/null
else
  cat "$REPORT"
fi