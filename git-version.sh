#!/bin/bash
# =============================================================================
# git-version.sh — Atualização automática de versão do projeto
# =============================================================================
# Calcula e aplica a próxima versão semântica (SemVer) com base nos commits
# desde a última tag, seguindo o padrão Conventional Commits:
#   feat!: incrementa MAJOR (quebra de compatibilidade)
#   feat:  incrementa MINOR (nova funcionalidade)
#   fix:   incrementa PATCH (correção de bug)
#
# Ao final, cria uma tag Git com a nova versão e atualiza .gitproject.
#
# Uso: git-version.sh
#
# Versão: 1.2.0
# Dependências: git-lib.sh, .gitproject
# =============================================================================

source "/usr/local/bin/git-lib.sh"
load_config

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

if [ -z "$VERSION" ]; then
  notify_info "❌ VERSION não definida em .gitproject"
  exit 1
fi

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LAST_TAG" ]; then
  notify_info "ℹ Nenhuma tag encontrada — analisando todos os commits"
  COMMITS=$(git log --pretty=format:"%s" 2>/dev/null)
  IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
else
  COMMITS=$(git log "${LAST_TAG}..HEAD" --pretty=format:"%s" 2>/dev/null)
  IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_TAG#v}"
fi

if [ -z "$COMMITS" ]; then
  notify_info "⚠ Nenhum commit novo desde v$VERSION — versão mantida"
  exit 0
fi

BUMP_MAJOR=0
BUMP_MINOR=0
BUMP_PATCH=0

while read -r line; do
  if [[ "$line" == *"feat!"* ]]; then
    BUMP_MAJOR=1
  elif [[ "$line" == feat:* ]]; then
    BUMP_MINOR=1
  elif [[ "$line" == fix:* ]]; then
    BUMP_PATCH=1
  fi
done <<< "$COMMITS"

if [ $BUMP_MAJOR -eq 1 ]; then
  ((MAJOR++)); MINOR=0; PATCH=0
elif [ $BUMP_MINOR -eq 1 ]; then
  ((MINOR++)); PATCH=0
elif [ $BUMP_PATCH -eq 1 ]; then
  ((PATCH++))
else
  notify_info "⚠ Nenhum commit relevante (feat/fix) — versão mantida: $MAJOR.$MINOR.$PATCH"
  exit 0
fi

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Confirma
ask_confirm CONFIRM "Confirma a atualização de versão?\n\nv$VERSION → v$NEW_VERSION"
if [ "$CONFIRM" != "s" ]; then
  notify_info "❌ Atualização cancelada"
  exit 0
fi

sed -i "s/^VERSION=.*/VERSION=$NEW_VERSION/" .gitproject
git add .gitproject
git commit -m "chore: bump version to v$NEW_VERSION"
git tag "v$NEW_VERSION"

notify_info "✔ Versão atualizada: v$VERSION → v$NEW_VERSION"