#!/bin/bash
# =============================================================================
# git-state.sh — Mostra o estado da pasta antes de voltar atrás
# =============================================================================
# Exibe a pasta, o ramo, a versão, a situação do envio ao GitHub, os últimos
# commits e as alterações ainda não commitadas, separando o que o
# git-reset.sh descarta do que ele não toca. Mostra também qual commit seria
# desfeito e se o reset é permitido.
#
# Uso: git-state.sh            (apenas mostra)
#      git-state.sh --reset    (mostra e pede a confirmação do git-reset.sh)
#
# Versão: 1.2.1
# Data:   2026-10-15
#
# Objetivo da versão:
#   - Nomes de arquivo com acento ou espaço aparecem como são, sem códigos
#     como \303\241 nem aspas
#   - A janela usa fonte de largura fixa, para alinhar código, data e mensagem
#   - Com o reset bloqueado, os títulos das alterações não dizem mais o que o
#     git-reset faria com elas
#   - Uma única linha em branco entre os grupos de arquivos
#   - Versão 1.2.0: mostra se a pasta está em dia com o GitHub, bloqueia o
#     reset de commit já enviado e vira a confirmação do git-reset.sh
#     (modo --reset)
#   - Versão 1.1.0: data e hora dos commits e mensagens cortadas em 70
#     caracteres
#   - Versão 1.0.0: conferir o estado da pasta pelo menu do gerenciador de
#     arquivos, onde a saída do terminal não aparece
#
# Observações de uso:
#   - Executar na raiz do repositório (pasta com .git)
#   - A situação do GitHub vem do que o Git guardou no último envio; não usa
#     a internet. Mudanças feitas no GitHub depois disso não aparecem
#   - Sem envio registrado (pasta nunca enviada), o reset é permitido
#   - Saída do modo --reset: 0 confirmou, 1 cancelou, 2 reset não permitido
#   - As mensagens completas continuam no git log; o corte é só na exibição
#   - Não altera arquivos, commits nem tags
#   - No git-tools.conf, fica antes do git-reset.sh, para aparecer acima dele
#     no menu
# Dependências: git-lib.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

MODE="view"
[ "$1" = "--reset" ] && MODE="reset"

if [ ! -d ".git" ]; then
  notify_info "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro."
  [ "$MODE" = "reset" ] && exit 2
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

plural() {
  if [ "$1" -eq 1 ]; then echo "$1 $2"; else echo "$1 $3"; fi
}

REPORT=$(mktemp)
trap 'rm -f "$REPORT"' EXIT

BRANCH=$(git branch --show-current 2>/dev/null)
LAST_TAG=$(git tag --sort=-version:refname | head -1)
HAS_HEAD=0
git rev-parse --verify HEAD >/dev/null 2>&1 && HAS_HEAD=1

SERVER="servidor"
git config --get remote.origin.url 2>/dev/null | grep -q "github\.com" && SERVER="GitHub"

UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
AHEAD=0
BEHIND=0
HEAD_SHARED=0
if [ -n "$UPSTREAM" ] && [ $HAS_HEAD -eq 1 ]; then
  AHEAD=$(git rev-list --count "$UPSTREAM..HEAD" 2>/dev/null || echo 0)
  BEHIND=$(git rev-list --count "HEAD..$UPSTREAM" 2>/dev/null || echo 0)
  git merge-base --is-ancestor HEAD "$UPSTREAM" 2>/dev/null && HEAD_SHARED=1
fi

MODIFIED=()
STAGED_NEW=()
UNTRACKED=()
SKIP_NEXT=0
while IFS= read -r -d '' entry; do
  if [ $SKIP_NEXT -eq 1 ]; then
    SKIP_NEXT=0
    continue
  fi
  code="${entry:0:2}"
  file="${entry:3}"
  [[ "$code" == R* || "$code" == C* ]] && SKIP_NEXT=1
  if [ "$code" = "??" ]; then
    UNTRACKED+=("$file")
  elif [ "${code:0:1}" = "A" ]; then
    STAGED_NEW+=("$file")
  else
    MODIFIED+=("$file")
  fi
done < <(git status --porcelain -z 2>/dev/null)

REMOVED_MSG=""
[ $HAS_HEAD -eq 1 ] && REMOVED_MSG=$(git log --format="%s" HEAD -1)

HAS_PREVIOUS=0
git rev-parse --verify HEAD~1 >/dev/null 2>&1 && HAS_PREVIOUS=1

RESET_ALLOWED=0
[ $HAS_PREVIOUS -eq 1 ] && [ $HEAD_SHARED -eq 0 ] && RESET_ALLOWED=1

if [ $RESET_ALLOWED -eq 1 ]; then
  T_MODIFIED="✏️  Alterados e não commitados (o git-reset descarta):"
  T_STAGED="⚠️  Novos, adicionados e nunca commitados (o git-reset apaga):"
  T_UNTRACKED="📄 Fora do Git (o git-reset não mexe):"
else
  T_MODIFIED="✏️  Alterados e não commitados:"
  T_STAGED="⚠️  Novos, adicionados e nunca commitados:"
  T_UNTRACKED="📄 Fora do Git:"
fi

FIRST_GROUP=1
print_group() {
  local title="$1"
  shift
  [ $# -eq 0 ] && return 0
  [ $FIRST_GROUP -eq 0 ] && echo ""
  FIRST_GROUP=0
  echo "$title"
  printf '   %s\n' "$@"
}

{
  echo "📁 Pasta: $(pwd)"
  echo "🌿 Ramo: ${BRANCH:-(sem ramo)}"
  [ -n "$VERSION" ] && echo "🏷  Versão no .gitproject: $VERSION"
  echo "🏷  Última tag: ${LAST_TAG:-(nenhuma)}"

  if [ -z "$UPSTREAM" ]; then
    echo "☁️  $SERVER: esta pasta ainda não foi enviada"
  elif [ "$AHEAD" -eq 0 ] && [ "$BEHIND" -eq 0 ]; then
    echo "☁️  $SERVER: em dia (conforme o último envio)"
  else
    [ "$AHEAD" -gt 0 ] && echo "☁️  $SERVER: $(plural "$AHEAD" "commit ainda não enviado" "commits ainda não enviados")"
    if [ "$BEHIND" -gt 0 ]; then
      echo "☁️  $SERVER: tem $(plural "$BEHIND" "commit" "commits") que esta pasta não tem"
      echo "   Se foi um git-reset de commit já enviado, o git-undo-reset devolve."
    fi
  fi
  echo ""

  if [ $HAS_HEAD -eq 1 ]; then
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
    print_group "$T_MODIFIED" "${MODIFIED[@]}"
    print_group "$T_STAGED" "${STAGED_NEW[@]}"
    print_group "$T_UNTRACKED" "${UNTRACKED[@]}"
  fi
  echo ""

  if [ $HAS_PREVIOUS -eq 0 ]; then
    echo "↩  Não há commit anterior para voltar: o git-reset não pode ser usado."
  elif [ $RESET_ALLOWED -eq 0 ]; then
    echo "⛔ O git-reset não pode desfazer o último commit:"
    echo "   $(commit_line HEAD)"
    echo "   Ele já está no $SERVER. Desfazer só aqui deixaria esta pasta"
    echo "   diferente do $SERVER, e o próximo envio falharia."
    echo "   Para corrigir, faça um commit novo com a correção (git-fix ou git-docs)."
    if [[ "$REMOVED_MSG" == "chore: bump version"* ]] && [ -n "$LAST_TAG" ]; then
      echo "   A versão $LAST_TAG já foi publicada: se precisar corrigir, lance a próxima."
    fi
  else
    echo "↩  Se rodar o git-reset agora:"
    echo "   desfaz:  $(commit_line HEAD)"
    echo "   volta a: $(commit_line HEAD~1)"
    if [[ "$REMOVED_MSG" == "chore: bump version"* ]] && [ -n "$LAST_TAG" ]; then
      echo "   e oferece remover a tag $LAST_TAG"
    fi
    echo "   O commit desfeito pode ser recuperado com o git-undo-reset."
  fi
} > "$REPORT"

GUI=0
_has_display && command -v zenity >/dev/null && GUI=1

if [ "$MODE" = "view" ] || [ $RESET_ALLOWED -eq 0 ]; then
  if [ $GUI -eq 1 ]; then
    zenity --text-info \
           --title="Git Tools — Estado da pasta" \
           --filename="$REPORT" \
           --font="monospace" \
           --width=760 \
           --height=500 2>/dev/null
  else
    cat "$REPORT"
  fi
  [ "$MODE" = "reset" ] && exit 2
  exit 0
fi

if [ $GUI -eq 1 ]; then
  zenity --text-info \
         --title="Git Tools — Desfazer último commit" \
         --filename="$REPORT" \
         --font="monospace" \
         --checkbox="Conferi o estado da pasta e quero desfazer o último commit" \
         --ok-label="Desfazer" \
         --cancel-label="Cancelar" \
         --width=760 \
         --height=520 2>/dev/null && exit 0
  exit 1
fi

cat "$REPORT"
echo ""
read -rp "Desfazer o último commit? Só s ou sim confirmam [s/N]: " ANSWER || exit 1
[[ "${ANSWER,,}" =~ ^(s|sim)$ ]] && exit 0
exit 1