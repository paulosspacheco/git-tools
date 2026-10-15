#!/bin/bash
# =============================================================================
# git-undo-reset.sh — Recupera commits desfeitos pelo git-reset.sh
# =============================================================================
# Procura no histórico do Git (reflog) os commits que foram desfeitos e não
# estão mais na pasta, deixa a pessoa escolher qual recuperar e o devolve
# sem apagar o que foi feito depois.
# Verifica e oferece recriar a tag de versão removida pelo git-reset.sh.
#
# ⚠️  Não recupera arquivos que nunca foram commitados.
#
# Uso: git-undo-reset.sh
#
# Versão: 1.3.0
# Data:   2026-10-15
#
# Objetivo da versão:
#   - Mostra numa lista os commits desfeitos, com data e mensagem, e deixa
#     escolher qual recuperar; antes, voltava sempre para a posição 1 do
#     histórico, que depois de qualquer outra ação era o lugar errado
#   - Se nada foi feito depois do reset, devolve o commit original, com o
#     mesmo código; se houve commits depois, copia o commit recuperado por
#     cima deles (cherry-pick), sem perder nada
#   - Em caso de conflito, desiste da tentativa e deixa a pasta como estava
#   - Recria a tag no commit que marcou a versão, não no commit atual
#   - Mostra as mensagens em janela, para quem usa o menu do gerenciador de
#     arquivos
#
# Observações de uso:
#   - Executar na raiz do repositório (pasta com .git)
#   - Exige a pasta sem alterações não commitadas; arquivos fora do Git
#     (nunca adicionados) não são tocados nem impedem a recuperação
#   - Commits cujo conteúdo já está na pasta (por exemplo, já recuperados com
#     cherry-pick) não aparecem na lista
#   - A lista mostra até 15 commits, do mais recente para o mais antigo; o
#     mais recente já vem marcado
#   - Recuperar um commit traz junto os commits desfeitos que vêm antes dele
#   - Com janela, a confirmação vem com Não como padrão; no terminal, Enter
#     cancela e só s ou sim confirmam
#   - O Git apaga do histórico as entradas antigas com o tempo
# Dependências: git-lib.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

MAX_MSG=70
MAX_ITEMS=15

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

GUI=0
_has_display && command -v zenity >/dev/null && GUI=1

confirm_no_default() {
  local prompt="$1" answer
  if [ $GUI -eq 1 ]; then
    zenity --question \
           --title="Git Tools" \
           --text="$prompt" \
           --ok-label="Sim" \
           --cancel-label="Não" \
           --default-cancel \
           --width=520 2>/dev/null
    return $?
  fi
  echo -e "$prompt"
  read -rp "Confirma? Só s ou sim confirmam [s/N]: " answer || return 1
  [[ "${answer,,}" =~ ^(s|sim)$ ]]
}

choose_commit() {
  local -n _choice=$1
  shift
  local labels=("$@") i answer

  if [ $GUI -eq 1 ]; then
    local rows=()
    for i in "${!labels[@]}"; do
      if [ "$i" -eq 0 ]; then rows+=(TRUE); else rows+=(FALSE); fi
      rows+=("$((i + 1))" "${labels[$i]}")
    done
    answer=$(zenity --list --radiolist \
                    --title="Git Tools — Recuperar commit desfeito" \
                    --text="Commits desfeitos que não estão mais na pasta.\nEscolha qual recuperar:" \
                    --column="" --column="Nº" --column="Commit" \
                    --print-column=2 \
                    "${rows[@]}" \
                    --width=760 --height=420 2>/dev/null) || return 1
  else
    echo "Commits desfeitos que não estão mais na pasta:"
    for i in "${!labels[@]}"; do
      echo "  $((i + 1))) ${labels[$i]}"
    done
    read -rp "Qual recuperar? [1]: " answer || return 1
    answer="${answer:-1}"
  fi

  [[ "$answer" =~ ^[0-9]+$ ]] && [ "$answer" -ge 1 ] && [ "$answer" -le ${#labels[@]} ] || return 1
  _choice=$((answer - 1))
}

if [ ! -d ".git" ]; then
  notify_info "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro."
  exit 1
fi

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  notify_info "❌ O repositório ainda não tem nenhum commit."
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  notify_info "❌ Há alterações não commitadas nesta pasta.\n\nFaça o commit delas antes de recuperar, para não misturar as mudanças.\n\nConfira com o Ver estado da pasta (git-state)."
  exit 1
fi

CANDIDATES=()
LABELS=()
declare -A SEEN
while read -r commit; do
  [ -n "${SEEN[$commit]}" ] && continue
  SEEN[$commit]=1
  git merge-base --is-ancestor "$commit" HEAD 2>/dev/null && continue
  [ -z "$(git rev-list --cherry-pick --right-only --no-merges "HEAD...$commit" 2>/dev/null)" ] && continue
  CANDIDATES+=("$commit")
  LABELS+=("$(commit_line "$commit")")
  [ ${#CANDIDATES[@]} -ge $MAX_ITEMS ] && break
done < <(git rev-list -g HEAD 2>/dev/null)

if [ ${#CANDIDATES[@]} -eq 0 ]; then
  notify_info "ℹ️  Não há commits desfeitos para recuperar.\n\nTudo o que está no histórico recente já está nesta pasta."
  exit 0
fi

choose_commit INDEX "${LABELS[@]}" || {
  echo "⚠ Operação cancelada pelo usuário."
  exit 0
}

TARGET="${CANDIDATES[$INDEX]}"

if git merge-base --is-ancestor HEAD "$TARGET"; then
  METHOD="ff"
  COUNT=$(git rev-list --count "HEAD..$TARGET")
  PLAN="A pasta volta para:\n   $(commit_line "$TARGET")\n\n$COUNT commit(s) recuperado(s) com os códigos originais.\nNada do que está na pasta será perdido."
else
  METHOD="pick"
  mapfile -t PICKS < <(git rev-list --reverse --cherry-pick --right-only --no-merges "HEAD...$TARGET")
  PLAN="Depois do reset houve outros commits, que serão mantidos.\nEstes commits serão copiados por cima deles, com códigos novos:\n"
  for c in "${PICKS[@]}"; do
    PLAN="$PLAN\n   $(commit_line "$c")"
  done
fi

confirm_no_default "$PLAN\n\nRecuperar?" || {
  echo "⚠ Operação cancelada pelo usuário."
  exit 0
}

if [ "$METHOD" = "ff" ]; then
  if ! git merge --ff-only -q "$TARGET"; then
    notify_info "❌ Falha na recuperação. A pasta não foi alterada."
    exit 1
  fi
else
  if ! git cherry-pick "${PICKS[@]}" >/dev/null 2>&1; then
    git cherry-pick --abort >/dev/null 2>&1
    notify_info "❌ Não foi possível recuperar automaticamente.\n\nAs mudanças do commit recuperado conflitam com as que vieram depois do reset.\n\nA pasta ficou como estava."
    exit 1
  fi
fi

RESULT="✔ Recuperação concluída.\n\nÚltimo commit agora:\n   $(commit_line HEAD)"

VERSION=""
load_config
if [ -n "$VERSION" ] && ! git rev-parse -q --verify "refs/tags/v$VERSION" >/dev/null; then
  BUMP=$(git log -1 --format=%H --fixed-strings --grep="chore: bump version to v$VERSION" HEAD)
  if [ -n "$BUMP" ]; then
    ask_confirm TAG_CONFIRM "A tag v$VERSION não existe, mas o .gitproject indica VERSION=$VERSION.\n\nRecriar a tag v$VERSION no commit:\n   $(commit_line "$BUMP")?" "s"
    if [[ "${TAG_CONFIRM,,}" =~ ^(s|sim)$ ]]; then
      git tag "v$VERSION" "$BUMP"
      RESULT="$RESULT\n\nTag v$VERSION recriada."
    else
      RESULT="$RESULT\n\n⚠ Tag v$VERSION ausente: execute git-version.sh com cuidado."
    fi
  else
    RESULT="$RESULT\n\n⚠ Tag v$VERSION ausente e o commit que marcou essa versão não foi encontrado."
  fi
fi

notify_info "$RESULT"