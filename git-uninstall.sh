#!/bin/bash
# =============================================================================
# git-uninstall.sh — Remoção global das ferramentas Git + integração Lazarus
# =============================================================================
# Reverte todas as operações do git-install.sh:
#   - Remove os scripts de /usr/local/bin
#   - Remove o arquivo lazarus.git-tools.xml (se presente no diretório atual)
#   - Reverte o environmentoptions.xml (via backup ou remoção do bloco)
#   - Remove os aliases adicionados ao ~/.bashrc
#
# Uso: ./git-uninstall.sh
#
# Versão: 1.0.2 (puramente bash)
# =============================================================================

set -e

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
  git-refactor.sh
  git-version.sh
  git-version-pas-inc.sh
  git-generator-lcl.sh
  git-release.sh
  git-changelog.sh
  git-docs.sh
  git-reset.sh
  git-undo-reset.sh
)

# =============================================================================
# Remover scripts de /usr/local/bin
# =============================================================================

echo "🗑 Removendo scripts de $INSTALL_DIR..."

removed=0
set +e  # Evita saída prematura se algum arquivo não puder ser removido
for SCRIPT in "${SCRIPTS[@]}"; do
  TARGET="$INSTALL_DIR/$SCRIPT"
  if [ -f "$TARGET" ]; then
    sudo rm -f "$TARGET"
    if [ $? -eq 0 ]; then
      echo "  ✔ Removido: $SCRIPT"
      ((removed++))
    else
      echo "  ❌ Falha ao remover: $SCRIPT (continuando...)"
    fi
  else
    echo "  ⚠ Não encontrado (ignorado): $SCRIPT"
  fi
done
set -e
echo "✔ $removed script(s) removido(s)"

# =============================================================================
# Remover lazarus.git-tools.xml do diretório atual
# =============================================================================

echo ""
XML_FILE="$SCRIPT_DIR/lazarus.git-tools.xml"
if [ -f "$XML_FILE" ]; then
  rm -f "$XML_FILE"
  echo "✔ Arquivo removido: $XML_FILE"
else
  echo "⚠ Arquivo não encontrado (ignorado): $XML_FILE"
fi

# =============================================================================
# Reverter environmentoptions.xml
# =============================================================================

echo ""
echo "🔧 Localizando environmentoptions.xml..."

CANDIDATES=(
  "$HOME/.lazarus/environmentoptions.xml"
  "/etc/lazarus/environmentoptions.xml"
  "$HOME/Lazarus/lazarus-fixe/config_lazarus/environmentoptions.xml"
  "$HOME/Lazarus/config_lazarus/environmentoptions.xml"
)

EXPANDED_CANDIDATES=()
for cand in "${CANDIDATES[@]}"; do
  [ -f "$cand" ] && EXPANDED_CANDIDATES+=("$cand")
done

if [ ${#EXPANDED_CANDIDATES[@]} -eq 0 ]; then
  while IFS= read -r file; do
    EXPANDED_CANDIDATES+=("$file")
  done < <(find "$HOME" /mnt -maxdepth 5 -name "environmentoptions.xml" 2>/dev/null \
    | grep "config_lazarus")
fi

LAZ_CONFIG="${EXPANDED_CANDIDATES[0]}"

if [ -z "$LAZ_CONFIG" ] || [ ! -f "$LAZ_CONFIG" ]; then
  echo "⚠ Não foi possível localizar automaticamente o environmentoptions.xml."

  if command -v zenity &>/dev/null || command -v kdialog &>/dev/null; then
    echo "🔍 Deseja localizar o arquivo manualmente usando uma janela gráfica? [S/n]"
    read -r answer
    if [[ ! "$answer" =~ ^[Nn]$ ]]; then
      if command -v zenity &>/dev/null; then
        LAZ_CONFIG=$(zenity --file-selection \
          --title="Selecione o arquivo environmentoptions.xml" \
          --file-filter="*.xml" 2>/dev/null)
      elif command -v kdialog &>/dev/null; then
        LAZ_CONFIG=$(kdialog --getopenfilename "$HOME" "*.xml" 2>/dev/null)
      fi
      [ -z "$LAZ_CONFIG" ] && echo "❌ Nenhum arquivo selecionado."
    fi
  else
    echo "🔍 Deseja fornecer o caminho manualmente? [s/N]"
    read -r answer
    if [[ "$answer" =~ ^[Ss]$ ]]; then
      echo "Digite o caminho completo do environmentoptions.xml:"
      read -r LAZ_CONFIG
      if [ ! -f "$LAZ_CONFIG" ]; then
        echo "❌ Arquivo não encontrado: $LAZ_CONFIG"
        LAZ_CONFIG=""
      fi
    fi
  fi
fi

if [ -n "$LAZ_CONFIG" ] && [ -f "$LAZ_CONFIG" ]; then
  echo "✔ Arquivo encontrado: $LAZ_CONFIG"
  BACKUP="${LAZ_CONFIG}.bak"

  if [ -f "$BACKUP" ]; then
    cp "$BACKUP" "$LAZ_CONFIG"
    echo "✔ Configuração restaurada a partir do backup: $BACKUP"
  else
    echo "⚠ Backup não encontrado. Removendo bloco <ExternalTools> diretamente..."
    if grep -q "<ExternalTools" "$LAZ_CONFIG"; then
      sed -i '/<ExternalTools/,/<\/ExternalTools>/d' "$LAZ_CONFIG"
      echo "✔ Bloco <ExternalTools> removido"
    else
      echo "ℹ Nenhum bloco <ExternalTools> encontrado no arquivo"
    fi
  fi

  echo "👉 Reinicie o Lazarus para aplicar as alterações."
else
  echo "ℹ Nenhum arquivo environmentoptions.xml processado."
  echo "  Remova o bloco <ExternalTools> manualmente se necessário."
fi

# =============================================================================
# Remover aliases do ~/.bashrc (versão direta e funcional)
# =============================================================================

echo ""
echo "🔧 Removendo aliases do ~/.bashrc..."

BASHRC="$HOME/.bashrc"

if [ ! -f "$BASHRC" ]; then
    echo "ℹ ~/.bashrc não encontrado"
else
    # Backup por segurança
    cp "$BASHRC" "${BASHRC}.bak-uninstall"
    
    # Remove todos os aliases que começam com 'alias git-'
    sed -i '/^alias git-/d' "$BASHRC"
    
    # Remove aliases específicos como version-pas-inc
    sed -i '/^alias version-pas-/d' "$BASHRC"
    
    # Remove a linha de cabeçalho (se existir)
    sed -i '/^# GIT-TOOLS ALIASES - Gerado por git-install.sh/d' "$BASHRC"
    
    # Remove linhas em branco duplicadas (opcional, mantém o arquivo limpo)
    sed -i '/^$/N;/^\n$/D' "$BASHRC"
    
    echo "✔ Aliases removidos de ~/.bashrc"
    echo "👉 Para aplicar imediatamente, execute: source ~/.bashrc"
fi

# =============================================================================

echo ""
echo "✔ Desinstalação concluída!"

