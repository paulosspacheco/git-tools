#!/bin/bash
# =============================================================================
# git-changelog.sh — Gera CHANGELOG baseado nos commits Git
# =============================================================================
# Lista commits agrupados por tipo desde a última tag ou versão informada.
# Opcionalmente salva em CHANGELOG.md.
#
# Uso: git-changelog.sh [--write] [versão]
#   git-changelog.sh            — mudanças desde a última tag
#   git-changelog.sh v1.2.0     — mudanças desde a versão informada
#   git-changelog.sh --write    — salva em CHANGELOG.md
#
# Versão: 1.1.0
# Dependências: git-lib.sh
# =============================================================================

source "/usr/local/bin/git-lib.sh"

show_help() {
  cat <<EOF
Uso: git-changelog.sh [opções] [versão]

Gera um CHANGELOG agrupado por tipo de commit seguindo o padrão
Conventional Commits. Por padrão exibe no terminal.

Opções:
  --write     Salva o resultado em CHANGELOG.md no diretório atual
  --help      Exibe esta ajuda

Argumentos:
  versão      Tag de referência (ex: v1.2.0). Se omitida, usa a última tag.

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
      Lista todas as mudanças desde a última tag

  git-changelog.sh v0.2.0
      Lista mudanças desde a tag v0.2.0

  git-changelog.sh --write
      Gera e salva em CHANGELOG.md

  git-changelog.sh --write v0.2.0
      Gera desde v0.2.0 e salva em CHANGELOG.md
EOF
}

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

WRITE=false
VERSION=""

for arg in "$@"; do
  case "$arg" in
    --write) WRITE=true ;;
    --help)  show_help; exit 0 ;;
    *)       VERSION="${arg#v}" ;;
  esac
done

# if [ -z "$VERSION" ]; then
#   LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
#   if [ -n "$LAST_TAG" ]; then
#     VERSION="${LAST_TAG#v}"
#   fi
# fi

if [ -n "$VERSION" ] && git rev-parse "v$VERSION" >/dev/null 2>&1; then
  RANGE="v$VERSION..HEAD"
  HEADER="## 📦 Mudanças desde v$VERSION"
else
  RANGE=""
  HEADER="## 📦 Histórico completo"
fi

list_section() {
  local pattern="$1"
  local title="$2"
  local commits

  if [ -n "$RANGE" ]; then
    commits=$(git log "$RANGE" --pretty=format:"%s" | grep "^$pattern" || true)
  else
    commits=$(git log --pretty=format:"%s" | grep "^$pattern" || true)
  fi

  if [ -n "$commits" ]; then
    printf "\n### %s\n\n" "$title"
    printf "%s\n" "$commits" | sed -E "s/^$pattern[[:space:]]*/- /"
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

if [ -n "$RANGE" ]; then
  others=$(git log "$RANGE" --pretty=format:"%s" | grep -vE "^(feat|fix|docs|refactor|chore)(!)?:" || true)
else
  others=$(git log --pretty=format:"%s" | grep -vE "^(feat|fix|docs|refactor|chore)(!)?:" || true)
fi

if [ -n "$others" ]; then
  OUTPUT+="\n### 🧩 Outras mudanças\n\n"
  OUTPUT+="$(printf "%s\n" "$others" | sed 's/^/- /')\n"
fi

OUTPUT+="\n---\n"
OUTPUT+="_Gerado automaticamente em $(date "+%Y-%m-%d %H:%M:%S")_\n"

if [ "$WRITE" = true ]; then
  printf "%b" "$OUTPUT" > CHANGELOG.md
  echo "✔ CHANGELOG.md atualizado"
else
  printf "%b" "$OUTPUT"
fi