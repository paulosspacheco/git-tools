#!/bin/bash
# =============================================================================
# git-changelog.sh — Gera CHANGELOG baseado nos commits Git
# =============================================================================
# Lista commits agrupados por tipo desde a última tag ou versão informada.
# Opcionalmente salva em CHANGELOG.md e/ou CHANGELOG.html.
#
# Uso: git-changelog.sh [--write] [--html] [versão]
#   git-changelog.sh            — exibe no terminal
#   git-changelog.sh --write    — salva em CHANGELOG.md
#   git-changelog.sh --html     — salva em CHANGELOG.md e CHANGELOG.html
#   git-changelog.sh v1.2.0     — mudanças desde a versão informada
#
# Versão: 1.4.0
# Dependências: git-lib.sh, pandoc (opcional, para --html)
# =============================================================================

source "/usr/local/bin/git-lib.sh"

show_help() {
  cat <<EOF
Uso: git-changelog.sh [opções] [versão]

Gera um CHANGELOG agrupado por tipo de commit seguindo o padrão
Conventional Commits. Por padrão exibe no terminal.

Opções:
  --write     Salva o resultado em CHANGELOG.md no diretório atual
  --html      Salva em CHANGELOG.md e gera CHANGELOG.html (requer pandoc)
  --help      Exibe esta ajuda

Argumentos:
  versão      Tag de referência (ex: v1.2.0). Se omitida, lista tudo.

Tipos de commit reconhecidos:
  feat:       Nova funcionalidade         → ➕ Funcionalidades
  fix:        Correção de bug             → 🐛 Correções
  feat!:      Quebra de compatibilidade   → ⚠ Alterações importantes
  fix!:       Quebra de compatibilidade   → ⚠ Alterações importantes
  docs:       Documentação                → 📚 Documentação
  refactor:   Refatoração                 → ♻️  Refatoração
  chore:      Manutenção interna          → 🔧 Manutenção

Exemplos:
  git-changelog.sh
      Exibe todo o histórico no terminal

  git-changelog.sh v0.2.0
      Exibe mudanças desde a tag v0.2.0

  git-changelog.sh --write
      Gera e salva em CHANGELOG.md

  git-changelog.sh --html
      Gera CHANGELOG.md e CHANGELOG.html

  git-changelog.sh --html v0.2.0
      Gera desde v0.2.0 em .md e .html
EOF
}

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

WRITE=false
HTML=false
VERSION=""

for arg in "$@"; do
  case "$arg" in
    --write) WRITE=true ;;
    --html)  HTML=true; WRITE=true ;;
    --help)  show_help; exit 0 ;;
    *)       VERSION="${arg#v}" ;;
  esac
done

if [ -n "$VERSION" ] && git rev-parse "v$VERSION" >/dev/null 2>&1; then
  RANGE="v$VERSION..HEAD"
  HEADER="## 📦 Mudanças desde v$VERSION"
else
  RANGE=""
  HEADER="## 📦 Histórico completo"
fi

# Formata uma linha de commit: "- DATA [**vX.Y.Z**] Mensagem"
# Usa tab como separador interno para não colidir com o conteúdo dos commits.
# %D contém as decorações de ref (ex: "tag: v1.2.0, HEAD -> main").
_format_line() {
  local date="$1"
  local deco="$2"
  local subj="$3"

  # Extrai tag de versão semântica da decoração, se houver
  local ver
  ver=$(printf '%s' "$deco" | grep -oE 'tag: v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/tag: //' | head -1)

  # Remove prefixo de tipo do subject (ex: "feat: " ou "fix!: ")
  local msg
  msg=$(printf '%s' "$subj" | sed -E 's/^[a-z]+(!)?:[[:space:]]*//')

  if [ -n "$ver" ]; then
    printf -- "- %s **%s** %s\n" "$date" "$ver" "$msg"
  else
    printf -- "- %s %s\n" "$date" "$msg"
  fi
}

list_section() {
  local pattern="$1"
  local title="$2"
  local raw commits

  if [ -n "$RANGE" ]; then
    raw=$(git log "$RANGE" --pretty=format:"%ad	%D	%s" --date=format:"%Y-%m-%d %H:%M")
  else
    raw=$(git log --pretty=format:"%ad	%D	%s" --date=format:"%Y-%m-%d %H:%M")
  fi

  # Filtra pelo padrão no subject (3º campo) e exclui commits de bump de versão
  commits=$(printf '%s\n' "$raw" \
    | awk -F'\t' -v p=" $pattern" '$3 ~ p && $3 !~ /(bump version|atualiza version\.inc) para v/')

  if [ -n "$commits" ]; then
    printf "\n### %s\n\n" "$title"
    while IFS=$'\t' read -r date deco subj; do
      _format_line "$date" "$deco" "$subj"
    done <<< "$commits"
  fi
}

OUTPUT="# 📘 CHANGELOG\n\n"
OUTPUT+="$HEADER\n"
OUTPUT+="$(list_section "feat!:" "⚠ Alterações que quebram compatibilidade")"
OUTPUT+="$(list_section "fix!:"  "⚠ Alterações que quebram compatibilidade")"
OUTPUT+="$(list_section "feat:"  "➕ Funcionalidades")"
OUTPUT+="$(list_section "fix:"   "🐛 Correções")"
OUTPUT+="$(list_section "docs:"  "📚 Documentação")"
OUTPUT+="$(list_section "refactor:" "♻️  Refatoração")"
OUTPUT+="$(list_section "chore:" "🔧 Manutenção")"

# Seção de commits sem tipo reconhecido
if [ -n "$RANGE" ]; then
  others_raw=$(git log "$RANGE" --pretty=format:"%ad	%D	%s" --date=format:"%Y-%m-%d %H:%M")
else
  others_raw=$(git log --pretty=format:"%ad	%D	%s" --date=format:"%Y-%m-%d %H:%M")
fi

others=$(printf '%s\n' "$others_raw" \
  | awk -F'\t' '$3 !~ / (feat|fix|docs|refactor|chore)(!)?:/')

if [ -n "$others" ]; then
  OUTPUT+="\n### 🧩 Outras mudanças\n\n"
  while IFS=$'\t' read -r date deco subj; do
    OUTPUT+="$(_format_line "$date" "$deco" "$subj")"$'\n'
  done <<< "$others"
fi

OUTPUT+="\n---\n"
OUTPUT+="_Gerado automaticamente em $(date "+%Y-%m-%d %H:%M:%S")_\n"

if [ "$WRITE" = true ]; then
  printf "%b" "$OUTPUT" > CHANGELOG.md
  echo "✔ CHANGELOG.md atualizado"

  if [ "$HTML" = true ]; then
    if command -v pandoc >/dev/null; then
      pandoc CHANGELOG.md -o CHANGELOG.html \
        --metadata title="CHANGELOG" \
        --standalone
      echo "✔ CHANGELOG.html gerado"
    else
      echo "⚠ pandoc não encontrado — CHANGELOG.html não gerado" >&2
    fi
  fi
else
  printf "%b" "$OUTPUT"
fi