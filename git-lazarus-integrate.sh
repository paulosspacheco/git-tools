#!/bin/bash
# =============================================================================
# git-lazarus-integrate.sh — Integração dos scripts git-tools ao Lazarus
# =============================================================================
# Gera um arquivo XML que pode ser importado diretamente no Lazarus
# (Tools → Configure External Tools → Import). Opcionalmente, também pode
# modificar o environmentoptions.xml diretamente.
#
# Uso: ./git-lazarus-integrate.sh [--export] [--path /caminho/para/arquivo]
#       ./git-lazarus-integrate.sh --export > git-tools.xml
#
# Versão: 1.2.0
# =============================================================================

set -e

# Caminho padrão onde os scripts git-tools devem estar instalados
GIT_TOOLS_DIR="/usr/local/bin"

# Lista das ferramentas a serem integradas
# Formato: "Título|nome_do_script|parâmetros"
# Os parâmetros usam a sintaxe correta $Prompt('mensagem')
# TOOLS=(
#   "Git Feat|git-feat.sh|\$Prompt('Descreva a funcionalidade adicionada:')"
#   "Git Fix|git-fix.sh|\$Prompt('Descreva a correção realizada:')"
#   "Git Breaking|git-breaking.sh|\$Prompt('Breaking change (impacto):')"
#   "Git Release|git-release.sh|"
#   "Git Version Inc|git-version-inc.sh|"
# )

TOOLS=(
  "Adicionar funcionalidade|git-feat.sh|\$Prompt('Descreva o que foi adicionado ao sistema:')"
  "Corrigir problema|git-fix.sh|\$Prompt('Descreva o problema que foi corrigido:')"
  "Alteração importante|git-breaking.sh|\$Prompt('Descreva a mudança que pode afetar versões anteriores:')"
  "Gerar versão do sistema|git-release.sh|"
  "Atualizar informações da versão|git-version-inc.sh|"
)


# Função para exibir ajuda
show_help() {
  cat << EOF
Integração dos scripts git-tools ao Lazarus.

Uso: $0 [opções]

Opções:
  --export           Exporta as definições para stdout no formato de importação do Lazarus.
  --path <arquivo>   Caminho do arquivo environmentoptions.xml (para edição direta).
  --help             Exibe esta ajuda.

Sem opções, o script tenta localizar automaticamente o arquivo environmentoptions.xml
e edita diretamente (após criar backup). Use --export para gerar o arquivo de importação.
EOF
  exit 0
}

# Função para exportar XML no formato de importação do Lazarus
export_xml() {
  local count=${#TOOLS[@]}
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo "<CONFIG Version=\"3\" Count=\"$count\">"

  local idx=1
  for tool in "${TOOLS[@]}"; do
    IFS='|' read -r name script params <<< "$tool"
    echo "  <Tool$idx>"
    echo "    <Title Value=\"$name\"/>"
    echo "    <Filename Value=\"$GIT_TOOLS_DIR/$script\"/>"
    echo "    <CmdLineParams Value=\"$params\"/>"
    echo "    <WorkingDirectory Value=\"\$ProjPath()\"/>"
    echo "    <Scanners Count=\"1\">"
    echo "      <Item1 Value=\"FPC\"/>"
    echo "    </Scanners>"
    echo "  </Tool$idx>"
    ((idx++))
  done
  echo "</CONFIG>"
}

# Função para adicionar ferramentas diretamente ao environmentoptions.xml
add_to_xml() {
  local config_file="$1"

  echo "✔ Arquivo de configuração encontrado: $config_file"

  # Cria backup
  BACKUP="${config_file}.bak"
  if [ ! -f "$BACKUP" ]; then
    cp "$config_file" "$BACKUP"
    echo "✔ Backup criado: $BACKUP"
  else
    echo "⚠ Backup já existe: $BACKUP (não sobrescrito)"
  fi

  echo ""
  echo "🔧 Configurando integração no Lazarus..."

  # Função para adicionar uma ferramenta (formato environmentoptions.xml)
  add_tool() {
    local NAME="$1"
    local SCRIPT="$2"
    local PARAMS="$3"

    if grep -q "<Title Value=\"$NAME\"/>" "$config_file"; then
      echo "  ✔ $NAME já configurado"
      return 0
    fi

    sed -i "/<Tools>/a\\
<Tool>\\
  <Title Value=\"$NAME\"/>\\
  <Program Value=\"$SCRIPT\"/>\\
  <Parameters Value=\"$PARAMS\"/>\\
  <WorkingDirectory Value=\"\$ProjPath()\"/>\\
</Tool>" "$config_file"

    echo "  ✔ $NAME adicionado"
  }

  for tool in "${TOOLS[@]}"; do
    IFS='|' read -r name script params <<< "$tool"
    add_tool "$name" "$GIT_TOOLS_DIR/$script" "$params"
  done

  echo ""
  echo "🎯 Integração concluída!"
  echo "👉 Reinicie o Lazarus para ver os novos comandos no menu Tools."
  echo ""
  echo "Lembre-se: os scripts devem estar em $GIT_TOOLS_DIR e ter permissão de execução."
}

# Processa argumentos
CONFIG_FILE=""
EXPORT_MODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --export)
      EXPORT_MODE=true
      shift
      ;;
    --path)
      CONFIG_FILE="$2"
      shift 2
      ;;
    --help)
      show_help
      ;;
    *)
      echo "Opção inválida: $1" >&2
      show_help
      ;;
  esac
done

# Modo exportação
if [ "$EXPORT_MODE" = true ]; then
  export_xml
  exit 0
fi

# Modo edição direta
if [ -z "$CONFIG_FILE" ]; then
  # Locais comuns do environmentoptions.xml
  CANDIDATES=(
    "$HOME/.lazarus/environmentoptions.xml"
    "/etc/lazarus/environmentoptions.xml"
  )

  for cand in "${CANDIDATES[@]}"; do
    if [ -f "$cand" ]; then
      CONFIG_FILE="$cand"
      break
    fi
  done

  if [ -z "$CONFIG_FILE" ]; then
    echo "⚠ Arquivo environmentoptions.xml não encontrado nos locais padrão."
    read -rp "Digite o caminho completo do arquivo (ou pressione Enter para sair): " CONFIG_FILE
    if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
      echo "❌ Arquivo não encontrado. Integração cancelada."
      exit 1
    fi
  fi
fi

# Verifica se os scripts estão instalados
MISSING=()
for tool in "${TOOLS[@]}"; do
  IFS='|' read -r name script params <<< "$tool"
  if [ -n "$script" ] && [ ! -x "$GIT_TOOLS_DIR/$script" ]; then
    MISSING+=("$GIT_TOOLS_DIR/$script")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "⚠ Atenção: os seguintes scripts não foram encontrados ou não são executáveis em $GIT_TOOLS_DIR:"
  printf '  %s\n' "${MISSING[@]}"
  echo "A integração será adicionada mesmo assim, mas poderá não funcionar."
  read -rp "Continuar mesmo assim? [s/N] " CONTINUE
  if [[ ! "$CONTINUE" =~ ^[Ss]$ ]]; then
    echo "Integração cancelada."
    exit 0
  fi
fi

add_to_xml "$CONFIG_FILE"


