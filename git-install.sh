#!/bin/bash
# =============================================================================
# git-install.sh — Instalação global das ferramentas Git + integração Lazarus
# =============================================================================
# Copia todos os scripts git-tools para /usr/local/bin, tornando-os
# disponíveis em qualquer pasta do sistema. Opcionalmente configura
# o menu Tools do Lazarus com acesso direto aos scripts.
#
# Uso: ./git-install.sh
#
# Versão: 2.1.0
# =============================================================================

INSTALL_DIR="/usr/local/bin"
SCRIPT_DIR="$(dirname "$0")"

SCRIPTS=(
  git-lib.sh
  git-ini.sh
  git-config.sh
  git-hook.sh
  git-feat.sh
  git-fix.sh
  git-breaking.sh
  git-version.sh
  git-version-inc.sh
  git-generator-lcl.sh
  git-changelog.sh
  git-release.sh
)

echo "🚀 Instalando git-tools em $INSTALL_DIR"

for SCRIPT in "${SCRIPTS[@]}"; do
  SRC="$SCRIPT_DIR/$SCRIPT"

  if [ ! -f "$SRC" ]; then
    echo "❌ Arquivo não encontrado: $SRC" >&2
    exit 1
  fi

  sudo cp "$SRC" "$INSTALL_DIR/$SCRIPT"
  sudo chmod +x "$INSTALL_DIR/$SCRIPT"
  echo "  ✔ $SCRIPT"
done

echo "✔ Scripts instalados com sucesso"
