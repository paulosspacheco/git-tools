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
# Versão: 1.3.0
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

list_section() {
  local pattern="$1"
  local title="$2"
  local commits

  if [ -n "$RANGE" ]; then
    commits=$(git log "$RANGE" --pretty=format:"%ad %s" --date=format:"%Y-%m-%d %H:%M" | grep " $pattern" || true)
  else
    commits=$(git log --pretty=format:"%ad %s" --date=format:"%Y-%m-%d %H:%M" | grep " $pattern" || true)
  fi

  commits=$(echo "$commits" | grep -vE "(bump version|atualiza version\.inc) para v" || true)

  if [ -n "$commits" ]; then
    printf "\n### %s\n\n" "$title"
    printf "%s\n" "$commits" | sed -E "s/^/- /" | sed -E "s/^(- [0-9-]+ [0-9:]+) [a-z!]+:/\1/"
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
  others=$(git log "$RANGE" --pretty=format:"%ad %s" --date=format:"%Y-%m-%d %H:%M" | grep -vE " (feat|fix|docs|refactor|chore)(!)?:" || true)
else
  others=$(git log --pretty=format:"%ad %s" --date=format:"%Y-%m-%d %H:%M" | grep -vE " (feat|fix|docs|refactor|chore)(!)?:" || true)
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

  # Notificação para quem executa via gerenciador de arquivos
  ask_confirm ver_relatorio "✔ Relatório CHANGELOG.md gerado na pasta atual.\n\nDeseja visualizar agora?"

  if [ "$ver_relatorio" = "s" ]; then
    if command -v x-terminal-emulator >/dev/null; then
      x-terminal-emulator -e "less CHANGELOG.md"
    elif command -v gnome-terminal >/dev/null; then
      gnome-terminal -- bash -c "less CHANGELOG.md; exec bash"
    elif command -v konsole >/dev/null; then
      konsole -e less CHANGELOG.md
    elif command -v xfce4-terminal >/dev/null; then
      xfce4-terminal -e "less CHANGELOG.md"
    else
      echo "⚠ Nenhum terminal gráfico encontrado para exibir o relatório." >&2
    fi
  fi

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