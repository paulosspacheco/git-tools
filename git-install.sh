#!/bin/bash
# =============================================================================
# git-install.sh — Instalação global das ferramentas Git + integração Lazarus
# =============================================================================
# Copia todos os scripts git-tools para /usr/local/bin, gera o arquivo XML
# para importação no Lazarus e, se possível, edita automaticamente o
# environmentoptions.xml para adicionar as ferramentas ao menu Tools.
# Também adiciona aliases no ~/.bashrc para acesso rápido.
#
# Uso: ./git-install.sh
#
# Versão: 3.3.0
# =============================================================================

set -e

# =============================================================================
# Dependências
# =============================================================================

install_deps() {
  local missing=()

  for cmd in zenity git pandoc; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done

  if [ ${#missing[@]} -gt 0 ]; then
    echo "⚠ Dependências ausentes: ${missing[*]}"
    echo "  Instalando..."
    sudo apt update -qq
    sudo apt install -y "${missing[@]}"
    echo "✔ Dependências instaladas"
  else
    echo "✔ Dependências OK"
  fi
}

echo "🔍 Verificando dependências..."
install_deps


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
  git-version-inc.sh
  git-generator-lcl.sh
  git-release.sh
  git-changelog.sh
  git-docs.sh
  git-reset.sh
  git-undo-reset.sh
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

# =============================================================================
# Integração com Lazarus (via geração de XML e edição automática)
# =============================================================================

echo ""
echo "🔧 Gerando arquivo de importação para o Lazarus (lazarus.git-tools.xml)..."
XML_FILE="lazarus.git-tools.xml"

TOOLS=(
  "Git Feat|git-feat.sh|\$Prompt('Descreva a funcionalidade adicionada ao projeto:')"
  "Git Fix|git-fix.sh|\$Prompt('Descreva a correção realizada:')"
  "Git Breaking|git-breaking.sh|\$Prompt('Breaking change (impacto):')"
  "Git Refactor|git-refactor.sh|\$Prompt('Descreva a refatoração:')"
  "Git Docs|git-docs.sh|\$Prompt('Descreva o documento adicionado ao projeto:')"
  "Git Release|git-release.sh|"
  "Git Version Inc|git-version-inc.sh|"
  "Git Changelog|git-changelog.sh|--write"
  "Git Changelog HTML|git-changelog.sh|--html"
  "Git Reset|git-reset.sh|"
  "Git Undo Reset|git-undo-reset.sh|"
)

echo '<?xml version="1.0" encoding="UTF-8"?>' > "$XML_FILE"
echo "<CONFIG Version=\"3\" Count=\"${#TOOLS[@]}\">" >> "$XML_FILE"

idx=1
for tool in "${TOOLS[@]}"; do
  IFS='|' read -r name script params <<< "$tool"
  echo "  <Tool$idx>" >> "$XML_FILE"
  echo "    <Title Value=\"$name\"/>" >> "$XML_FILE"
  echo "    <Filename Value=\"$INSTALL_DIR/$script\"/>" >> "$XML_FILE"
  echo "    <CmdLineParams Value=\"$params\"/>" >> "$XML_FILE"
  echo "    <WorkingDirectory Value=\"\$ProjPath()\"/>" >> "$XML_FILE"
  echo "    <Scanners Count=\"1\">" >> "$XML_FILE"
  echo "      <Item1 Value=\"FPC\"/>" >> "$XML_FILE"
  echo "    </Scanners>" >> "$XML_FILE"
  echo "  </Tool$idx>" >> "$XML_FILE"
  ((idx++))
done
echo "</CONFIG>" >> "$XML_FILE"

echo "✔ Arquivo gerado: $XML_FILE"
echo ""

# =============================================================================
# Localizar e editar automaticamente o environmentoptions.xml
# =============================================================================

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

if [ -n "$LAZ_CONFIG" ] && [ -f "$LAZ_CONFIG" ]; then
  echo "✔ Arquivo de configuração do Lazarus encontrado: $LAZ_CONFIG"
else
  echo "⚠ Não foi possível localizar automaticamente o environmentoptions.xml."
  echo ""

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

  if [ -z "$LAZ_CONFIG" ] || [ ! -f "$LAZ_CONFIG" ]; then
    echo "ℹ Para integrar com o Lazarus, importe o arquivo $XML_FILE manualmente:"
    echo "   Tools → Configure External Tools → Import"
    echo ""
  fi
fi

if [ -n "$LAZ_CONFIG" ] && [ -f "$LAZ_CONFIG" ]; then
  BACKUP="${LAZ_CONFIG}.bak"
  if [ ! -f "$BACKUP" ]; then
    cp "$LAZ_CONFIG" "$BACKUP"
    echo "✔ Backup criado: $BACKUP"
  else
    echo "⚠ Backup já existe: $BACKUP (não sobrescrito)"
  fi

  sed -i '/<ExternalTools/,/<\/ExternalTools>/d' "$LAZ_CONFIG"

  END_ENV_LINE=$(grep -n "</EnvironmentOptions>" "$LAZ_CONFIG" | head -1 | cut -d: -f1)
  if [ -z "$END_ENV_LINE" ]; then
    echo "❌ Não foi possível localizar </EnvironmentOptions>. Integração automática cancelada."
    echo "👉 Importe o arquivo $XML_FILE manualmente no Lazarus (Tools → Configure External Tools → Import)."
  else
    BLOCK="  <ExternalTools Version=\"3\" Count=\"${#TOOLS[@]}\">\n"
    idx=1
    for tool in "${TOOLS[@]}"; do
      IFS='|' read -r name script params <<< "$tool"
      params_escaped=$(echo "$params" | sed "s/'/\&apos;/g")
      BLOCK+="    <Tool$idx>\n"
      BLOCK+="      <Title Value=\"$name\"/>\n"
      BLOCK+="      <Filename Value=\"$INSTALL_DIR/$script\"/>\n"
      if [ -n "$params" ]; then
        BLOCK+="      <CmdLineParams Value=\"$params_escaped\"/>\n"
      fi
      BLOCK+="      <WorkingDirectory Value=\"\$ProjPath()\"/>\n"
      BLOCK+="      <Scanners Count=\"1\">\n"
      BLOCK+="        <Item1 Value=\"FPC\"/>\n"
      BLOCK+="      </Scanners>\n"
      BLOCK+="    </Tool$idx>\n"
      ((idx++))
    done
    BLOCK+="  </ExternalTools>\n"

    sed -i "${END_ENV_LINE}i\\${BLOCK}" "$LAZ_CONFIG"

    echo "🎯 Ferramentas adicionadas ao menu Tools do Lazarus!"
    echo "👉 Reinicie o Lazarus para ver as novas opções."
  fi
fi

# =============================================================================
# Configuração de aliases no .bashrc
# =============================================================================

echo ""
echo "🔧 Configuração de aliases no bash"

BASHRC="$HOME/.bashrc"
ALIAS_HEADER="# GIT-TOOLS ALIASES - Gerado por git-install.sh"

if grep -q "GIT-TOOLS ALIASES" "$BASHRC" 2>/dev/null; then
  echo "✔ Aliases já configurados em ~/.bashrc."
else
  declare -A ALIAS_MAP=(
    ["git-feat"]="git-feat.sh"
    ["git-fix"]="git-fix.sh"
    ["git-breaking"]="git-breaking.sh"
    ["git-refactor"]="git-refactor.sh"
    ["git-docs"]="git-docs.sh"
    ["git-release"]="git-release.sh"
    ["git-version-inc"]="git-version-inc.sh"
    ["git-version"]="git-version.sh"
    ["git-changelog"]="git-changelog.sh"
    ["git-ini"]="git-ini.sh"
    ["git-config"]="git-config.sh"
    ["git-hook"]="git-hook.sh"
    ["git-reset"]="git-reset.sh"
    ["git-undo-reset"]="git-undo-reset.sh"
  )

  {
    echo ""
    echo "# ============================================"
    echo "$ALIAS_HEADER"
    echo "# ============================================"
    for alias_name in "${!ALIAS_MAP[@]}"; do
      echo "alias $alias_name='bash \"$INSTALL_DIR/${ALIAS_MAP[$alias_name]}\"'"
    done
    echo "# ============================================"
  } >> "$BASHRC"

  echo "✔ Aliases adicionados com sucesso em ~/.bashrc"
  echo "👉 Para usar os aliases imediatamente, execute: source ~/.bashrc"
fi

# =============================================================================

echo ""
echo "✔ Ambiente pronto!"
echo ""
echo "Exemplo de uso:"
echo "  git-ini.sh"
echo "  git-feat.sh \"nova funcionalidade\""
echo "  git-fix.sh \"correção de bug\""
echo "  git-release.sh"