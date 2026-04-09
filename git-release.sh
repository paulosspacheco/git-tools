#!/bin/bash
# =============================================================================
# git-release.sh — Geração de release do projeto
# =============================================================================
# Executa o fluxo completo de release:
#   - Calcula e aplica a nova versão semântica via git-version.sh

#   - Gera o arquivo version-pas-inc via git-version-pas-inc.sh
#
# Uso: ./git-release.sh
#


# Versão: 1.1.0
# Dependências: git-lib.sh, git-version.sh, git-version-pas-inc.sh, .gitproject
# =============================================================================

source "$(dirname "$0")/git-lib.sh"

echo "🚀 Gerando release"

# Executa o cálculo de versão
"$(dirname "$0")/git-version.sh" || exit 1

# Carrega a nova versão
load_config

if [ -z "$VERSION" ]; then

  notify_info "❌ VERSION não definida em .gitproject"
  exit 1
fi

# Gera o arquivo version-pas-inc
"$(dirname "$0")/git-version-pas-inc.sh" || exit 1


# Mostra mensagem de sucesso
notify_info "✅ Release criado com sucesso!\n\nVersão: v$VERSION\n\nO projeto foi atualizado e a tag v$VERSION foi criada."

# Pausa para o usuário ver a mensagem (apenas em modo terminal)
if ! _has_display || ! command -v zenity >/dev/null; then
  echo ""
  read -rp "Pressione Enter para continuar..."
fi
