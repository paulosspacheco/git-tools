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
# Uso: ./git-version.sh
#
# Versão: 1.1.0
# Dependências: git-lib.sh, .gitproject
# =============================================================================

source "$(dirname "$0")/git-lib.sh"
load_config

if [ -z "$VERSION" ]; then
  echo "❌ VERSION não definida em .gitproject" >&2
  exit 1
fi

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LAST_TAG" ]; then
  echo "ℹ Nenhuma tag encontrada — analisando todos os commits"
  COMMITS=$(git log --pretty=format:"%s" 2>/dev/null)
  IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
else
  COMMITS=$(git log "${LAST_TAG}..HEAD" --pretty=format:"%s" 2>/dev/null)
  IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_TAG#v}"
fi

if [ -z "$COMMITS" ]; then
  echo "⚠ Nenhum commit novo desde v$VERSION — versão mantida" >&2
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
  echo "⚠ Nenhum commit relevante (feat/fix) — versão mantida: $MAJOR.$MINOR.$PATCH" >&2
  exit 0
fi

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

sed -i "s/^VERSION=.*/VERSION=$NEW_VERSION/" .gitproject
git add .gitproject
git commit -m "chore: bump version para v$NEW_VERSION"
git tag "v$NEW_VERSION"

echo "✔ Versão atualizada: v$VERSION → v$NEW_VERSION"