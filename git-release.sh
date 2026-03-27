#!/bin/bash
# =============================================================================
# git-release.sh — Geração de release do projeto
# =============================================================================
# Executa o fluxo completo de release:
#   - Calcula e aplica a nova versão semântica via git-version.sh
#   - Gera o arquivo version.inc via git-version-inc.sh
#
# Uso: ./git-release.sh
#
# Versão: 1.0.0
# Dependências: git-lib.sh, git-version.sh, git-version-inc.sh, .gitproject
# =============================================================================

source "$(dirname "$0")/git-lib.sh"

echo "🚀 Gerando release"

"$(dirname "$0")/git-version.sh" || exit 1

load_config

if [ -z "$VERSION" ]; then
  echo "❌ VERSION não definida em .gitproject" >&2
  exit 1
fi

"$(dirname "$0")/git-version-inc.sh" || exit 1

echo "✔ Release criado: v$VERSION"