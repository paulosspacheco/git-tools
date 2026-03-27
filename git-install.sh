#!/bin/bash
# =============================================================================
# git-install.sh — Instalação global das ferramentas Git
# =============================================================================
# Copia todos os scripts git-tools para /usr/local/bin, tornando-os
# disponíveis em qualquer pasta do sistema.
#
# Uso: ./git-install.sh
#
# Versão: 1.0.0
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
  git-release.sh
  git-generator-lcl.sh
)

echo "🚀 Instalando git-tools em $INSTALL_DIR"

for SCRIPT in "${SCRIPTS[@]}"; do
  SRC="$SCRIPT_DIR/$SCRIPT"
  DST="$INSTALL_DIR/$SCRIPT"

  if [ ! -f "$SRC" ]; then
    echo "❌ Arquivo não encontrado: $SRC" >&2
    exit 1
  fi

  sudo cp "$SRC" "$DST"
  sudo chmod +x "$DST"
  echo "  ✔ $SCRIPT"
done

echo "✔ Instalação concluída — scripts disponíveis em qualquer pasta"
