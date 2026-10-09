#!/bin/bash
# =============================================================================
# git-cloud.sh — Envia o projeto para o GitHub e cria o repositório se não existir
# =============================================================================
# Versão: 0.1.0
# Data:   2026-10-08
#
# Objetivo da versão:
#   - Envia a branch atual e as tags para o GitHub (origin)
#   - Se o repositório não existir, pergunta nome, visibilidade e descrição
#     e o cria pela API do GitHub
#   - Deixa o origin configurado com o endereço SSH
#
# Observações de uso:
#   - Uso: git-cloud.sh
#   - Executar na raiz do repositório (pasta com .git), com ao menos um commit
#   - Requer chave SSH cadastrada na conta do GitHub (teste: ssh -T git@github.com)
#   - Criar o repositório exige um token clássico com permissão repo, obtido
#     de GITHUB_TOKEN, do gh (gh auth login) ou digitado no diálogo
#   - O token não é gravado em lugar nenhum
#   - Repositórios de organização devem ser criados pelo site do GitHub
#   - Origin que não seja do GitHub recebe apenas o envio
#   - Dependências: git-lib.sh, git, ssh, curl
# =============================================================================

source "/usr/local/bin/git-lib.sh"
load_config

API="https://api.github.com"
SSH_HOST="git@github.com"
RESP=$(mktemp)
trap 'rm -f "$RESP"' EXIT

fail() {
  notify_info "❌ $1"
  exit 1
}

ask_default() {
  local -n _out=$1
  local _prompt="$2" _default="$3" _value

  if _has_display && command -v zenity >/dev/null; then
    _value=$(zenity --entry --title="Git Tools" --text="$_prompt:" \
                    --entry-text="$_default" --width=400 2>/dev/null) || return 1
  else
    read -rp "$_prompt [$_default]: " _value
  fi

  _value="${_value:-$_default}"
  [ -n "$_value" ] || return 1
  _out="$_value"
}

ask_secret() {
  local -n _out=$1
  local _prompt="$2" _value

  if _has_display && command -v zenity >/dev/null; then
    _value=$(zenity --entry --hide-text --title="Git Tools" --text="$_prompt" \
                    --width=400 2>/dev/null) || return 1
  else
    printf '%b\n' "$_prompt" >&2
    read -rsp "Token: " _value
    echo >&2
  fi

  [ -n "$_value" ] || return 1
  _out="$_value"
}

get_token() {
  TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
  if [ -z "$TOKEN" ] && command -v gh >/dev/null 2>&1; then
    TOKEN=$(gh auth token 2>/dev/null)
  fi
  [ -n "$TOKEN" ] && return 0

  ask_secret TOKEN "Para criar o repositório é preciso um token do GitHub (token clássico com permissão repo).\nCrie em: GitHub > Settings > Developer settings > Personal access tokens.\n\nCole o token"
}

api() {
  local method="$1" path="$2" data="${3:-}"
  local args=(-sS -o "$RESP" -w '%{http_code}' -X "$method" -H "Accept: application/vnd.github+json" -K -)
  [ -n "$data" ] && args+=(-d "$data")
  printf 'header = "Authorization: Bearer %s"\n' "$TOKEN" | curl "${args[@]}" "$API$path"
}

api_message() {
  sed -n 's/.*"message": *"\([^"]*\)".*/\1/p' "$RESP" | paste -sd';' -
}

json_escape() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr -d '\n\r'
}

remote_exists() {
  GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=15" \
    git ls-remote "$1" >/dev/null 2>&1
}

parse_github_url() {
  local url="$1"
  if [[ "$url" =~ github\.com[:/]([^/]+)/([^/]+)$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]%.git}"
    return 0
  fi
  return 1
}

create_repo() {
  local private=false code login

  ask_select VISIBILITY "Visibilidade do repositório:" "Público" "Privado" || exit 1
  ask_optional DESCRIPTION "Descrição do repositório (opcional)" "" || exit 1
  [ "$VISIBILITY" = "Privado" ] && private=true

  get_token || fail "Token do GitHub não informado."

  code=$(api GET /user) || fail "Sem conexão com api.github.com."
  case "$code" in
    200) ;;
    401) fail "Token inválido ou expirado." ;;
    *)   fail "Falha ao validar o token (HTTP $code): $(api_message)" ;;
  esac

  login=$(sed -n 's/.*"login": *"\([^"]*\)".*/\1/p' "$RESP" | head -1)
  if [ "${login,,}" != "${OWNER,,}" ]; then
    fail "O token pertence a '$login', mas o repositório é de '$OWNER'.\n\nPara organizações, crie o repositório pelo site do GitHub."
  fi

  code=$(api POST /user/repos "{\"name\":\"$(json_escape "$REPO_NAME")\",\"description\":\"$(json_escape "$DESCRIPTION")\",\"private\":$private}") \
    || fail "Sem conexão com api.github.com."
  case "$code" in
    201) ;;
    422) fail "O GitHub recusou a criação: $(api_message)\n\nSe o repositório já existe, confira se a chave SSH tem acesso a ele." ;;
    *)   fail "Falha ao criar o repositório (HTTP $code): $(api_message)" ;;
  esac
}

push_all() {
  local out
  out=$(git push -u origin "$BRANCH" 2>&1) || fail "Falha ao enviar a branch $BRANCH:\n\n$out"
  echo "$out"
  out=$(git push origin --tags 2>&1) || fail "Falha ao enviar as tags:\n\n$out"
  echo "$out"
}

[ -d .git ] || fail "Nenhum repositório Git encontrado.\n\nExecute git-ini.sh primeiro."
git rev-parse --verify HEAD >/dev/null 2>&1 || fail "O repositório ainda não tem nenhum commit."

BRANCH=$(git branch --show-current)
[ -n "$BRANCH" ] || fail "Nenhuma branch ativa (HEAD solto)."

ORIGIN_URL=$(git config --get remote.origin.url)

if [ -n "$ORIGIN_URL" ] && ! parse_github_url "$ORIGIN_URL"; then
  push_all
  notify_info "✔ Projeto enviado para $ORIGIN_URL\n\nBranch: $BRANCH"
  exit 0
fi

SSH_OUT=$(ssh -o BatchMode=yes -o ConnectTimeout=15 -T "$SSH_HOST" 2>&1)
GH_USER=$(printf '%s\n' "$SSH_OUT" | sed -n 's/^Hi \([^!/]*\)[!/].*/\1/p' | head -1)
[ -n "$GH_USER" ] || fail "A chave SSH não está autenticada no GitHub.\n\nCadastre-a em GitHub > Settings > SSH and GPG keys."

if [ -z "$ORIGIN_URL" ]; then
  ask_default OWNER "Usuário do GitHub" "$GH_USER" || exit 1
  ask_default REPO_NAME "Nome do repositório" "${PROJECT_NAME:-$(basename "$PWD")}" || exit 1
fi

[[ "$OWNER" =~ ^[A-Za-z0-9-]+$ ]] || fail "Usuário do GitHub inválido: $OWNER"
[[ "$REPO_NAME" =~ ^[A-Za-z0-9._-]+$ ]] || fail "Nome de repositório inválido: $REPO_NAME\n\nUse apenas letras, números, ponto, hífen ou sublinhado."

SSH_URL="$SSH_HOST:$OWNER/$REPO_NAME.git"

if ! remote_exists "$SSH_URL"; then
  ask_confirm CREATE "Repositório $OWNER/$REPO_NAME não encontrado no GitHub.\n\nCriar agora?"
  if [ "${CREATE,,}" != "s" ]; then
    notify_info "❌ Envio cancelado"
    exit 0
  fi
  create_repo
fi

if [ -z "$ORIGIN_URL" ]; then
  git remote add origin "$SSH_URL"
elif [ "$ORIGIN_URL" != "$SSH_URL" ]; then
  git remote set-url origin "$SSH_URL"
fi

push_all

notify_info "✔ Projeto enviado para o GitHub!\n\nhttps://github.com/$OWNER/$REPO_NAME\n\nBranch: $BRANCH\nTags enviadas."