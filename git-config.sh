#!/bin/bash
# =============================================================================
# git-config.sh — Configuração básica do projeto Git
# =============================================================================
# Gera o arquivo .gitproject com metadados do projeto:
#   - Nome do projeto
#   - Versão inicial
#
# Uso: ./git-config.sh [nome-do-projeto]
#
# Versão: 1.0.0
# Dependências: git-lib.sh
# =============================================================================

source "$(dirname "$0")/git-lib.sh"

ask_required PROJECT_NAME "Nome do projeto (ex: meu-projeto)" "$1"

if [[ "$PROJECT_NAME" == /* || "$PROJECT_NAME" == */* ]]; then
  echo "❌ Nome do projeto não deve ser um caminho, apenas um nome simples." >&2
  exit 1
fi

cat > .gitproject <<EOF
PROJECT_NAME=$PROJECT_NAME
VERSION=0.1.0
EOF

echo "✔ .gitproject criado"