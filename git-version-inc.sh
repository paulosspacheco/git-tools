#!/bin/bash
# =============================================================================
# git-version-inc.sh — Geração do arquivo de versão para Pascal/Lazarus
# =============================================================================
# Gera o arquivo version.inc com defines de pré-processador contendo
# a versão atual do projeto e a data/hora do build.
# Commita o arquivo gerado automaticamente.
#
# Uso: ./git-version-inc.sh
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

DATE=$(date "+%Y-%m-%d %H:%M:%S")

cat > version.inc <<EOF
const
  VERSION_STR = '$VERSION';
  BUILD_DATE  = '$DATE';
EOF

git add version.inc
git commit -m "chore: atualiza version.inc para v$VERSION" || true

echo "✔ version.inc gerado: v$VERSION — $DATE"