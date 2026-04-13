#!/bin/bash
# =============================================================================
# git-install.sh — Instalação global das ferramentas Git + integrações
# Versão: 4.4.0 (sem modificação automática do environmentoptions.xml)
# =============================================================================

INSTALL_DIR="/usr/local/bin"
SCRIPT_DIR="$(dirname "$0")"
CONFIG_FILE="$SCRIPT_DIR/git-tools.conf"
INSTALLED_CONFIG="$INSTALL_DIR/git-tools.conf"

# -----------------------------------------------------------------------------
# Arquivos extras que não estão no .conf
# -----------------------------------------------------------------------------
EXTRA_FILES=(
    git-lib.sh
    git-config.sh
    git-hook.sh
    git-add-navigator-nemo.sh
    git-add-navigator-nautilus.sh
    git-add-navigator-dolphin.sh
    git-tools.conf
)

# -----------------------------------------------------------------------------
# Funções auxiliares
# -----------------------------------------------------------------------------
install_one_file() {
    local file="$1"
    local src="$SCRIPT_DIR/$file"
    if [ ! -f "$src" ]; then
        echo "❌ Arquivo não encontrado: $src" >&2
        return 1
    fi
    sudo cp "$src" "$INSTALL_DIR/$file" || return 1
    if [[ "$file" == *.sh ]]; then
        sudo chmod +x "$INSTALL_DIR/$file"
        echo "  ✔ $file (executável)"
    else
        echo "  ✔ $file (configuração)"
    fi
    return 0
}

parse_config() {
    local filter="$1"
    local callback="$2"
    local config_file="${3:-$CONFIG_FILE}"
    [[ ! -f "$config_file" ]] && { echo "❌ Configuração não encontrada: $config_file" >&2; return 1; }
    while IFS='|' read -r script title_menu title_laz params; do
        script=$(echo "$script" | xargs)
        title_menu=$(echo "$title_menu" | xargs)
        title_laz=$(echo "$title_laz" | xargs)
        params=$(echo "$params" | xargs)
        [[ -z "$script" || "$script" == \#* ]] && continue
        case "$filter" in
            menu)     [[ -n "$title_menu" ]] && $callback "$script" "$title_menu" "$title_laz" "$params" ;;
            lazarus)  [[ -n "$title_laz" ]] && $callback "$script" "$title_menu" "$title_laz" "$params" ;;
            all)      $callback "$script" "$title_menu" "$title_laz" "$params" ;;
        esac
    done < "$config_file"
}

Install_Scripts() {
    echo "🚀 Instalando arquivos em $INSTALL_DIR"
    for file in "${EXTRA_FILES[@]}"; do
        install_one_file "$file" || exit 1
    done
    parse_config "all" install_one_file || exit 1
    echo "✔ Todos os arquivos instalados com sucesso"
}

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
generate_aliases() {
    local aliases=""
    while IFS='|' read -r script title_menu title_laz params; do
        script=$(echo "$script" | xargs)
        title_menu=$(echo "$title_menu" | xargs)
        title_laz=$(echo "$title_laz" | xargs)
        [[ -z "$script" || "$script" == \#* ]] && continue
        if [[ -n "$title_menu" || -n "$title_laz" ]]; then
            local alias_name="${script%.sh}"
            aliases+="alias $alias_name='bash \"$INSTALL_DIR/$script\"'\n"
        fi
    done < "$CONFIG_FILE"
    echo -e "$aliases"
}
 
Configure_Aliases() {
    echo ""
    echo "🔧 Configurando aliases no bash"
    local BASHRC="$HOME/.bashrc"
    local ALIAS_START="# >>> git-tools start >>>"
    local ALIAS_END="# <<< git-tools end <<<"

    # Remove bloco anterior
    sed -i "/$ALIAS_START/,/$ALIAS_END/d" "$BASHRC"

    # Abre o bloco
    echo "" >> "$BASHRC"
    echo "$ALIAS_START" >> "$BASHRC"

    # Grava cada alias diretamente, um por linha
    while IFS='|' read -r script title_menu title_laz params; do
        script=$(echo "$script" | xargs)
        title_menu=$(echo "$title_menu" | xargs)
        title_laz=$(echo "$title_laz" | xargs)
        [[ -z "$script" || "$script" == \#* ]] && continue
        if [[ -n "$title_menu" || -n "$title_laz" ]]; then
            local alias_name="${script%.sh}"
            echo "alias $alias_name='bash \"$INSTALL_DIR/$script\"'" >> "$BASHRC"
        fi
    done < "$CONFIG_FILE"

    # Fecha o bloco
    echo "$ALIAS_END" >> "$BASHRC"

    echo "✔ Aliases adicionados em ~/.bashrc"
    echo "👉 Execute 'source ~/.bashrc' para usar imediatamente."
}

# -----------------------------------------------------------------------------
# Integração Lazarus (somente geração do XML, sem modificação automática)
# -----------------------------------------------------------------------------
Generate_Lazarus_XML() {
    echo ""
    echo "🔧 Gerando arquivo de importação para o Lazarus: lazarus.git-tools.xml"

    local XML_FILE="lazarus.git-tools.xml"
    local tool_count=0
    local tools_list=()

    while IFS='|' read -r script title_menu title_laz params; do
        script=$(echo "$script" | xargs)
        title_laz=$(echo "$title_laz" | xargs)
        [[ -z "$script" || "$script" == \#* || -z "$title_laz" ]] && continue
        tools_list+=("$title_laz|$script|$params")
        tool_count=$((tool_count + 1))
    done < "$CONFIG_FILE"

    # Gera XML com quebras de linha reais (usando $'\n')
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo "<CONFIG Version=\"3\" Count=\"$tool_count\">"
        local idx=1
        for tool in "${tools_list[@]}"; do
            IFS='|' read -r name script params <<< "$tool"
            echo "  <Tool$idx>"
            echo "    <Title Value=\"$name\"/>"
            echo "    <Filename Value=\"$INSTALL_DIR/$script\"/>"
            [[ -n "$params" ]] && echo "    <CmdLineParams Value=\"$params\"/>"
            echo "    <WorkingDirectory Value=\"\$ProjPath()\"/>"
            echo "    <Scanners Count=\"1\">"
            echo "      <Item1 Value=\"FPC\"/>"
            echo "    </Scanners>"
            echo "  </Tool$idx>"
            idx=$((idx + 1))
        done
        echo "</CONFIG>"
    } > "$XML_FILE"

    echo "✔ Arquivo gerado: $XML_FILE"
}

Integrate_Lazarus() {
    echo ""
    echo "🔧 Integração com Lazarus (modo manual seguro)"
    echo "⚠ Para evitar corrupção do arquivo de configuração, o instalador não modifica o environmentoptions.xml automaticamente."
    echo ""
    echo "👉 Para adicionar as ferramentas no menu Tools do Lazarus:"
    echo "   1. Abra o Lazarus"
    echo "   2. Acesse Tools → Configure External Tools..."
    echo "   3. Clique em 'Import' e selecione o arquivo: $(pwd)/lazarus.git-tools.xml"
    echo "   4. Clique em 'OK' e reinicie o Lazarus"
    echo ""
    echo "✔ O arquivo de importação está pronto e pode ser usado a qualquer momento."
}

# -----------------------------------------------------------------------------
# Gerenciadores de arquivos
# -----------------------------------------------------------------------------
Git_Add_Navigator() {
    echo ""
    echo "🔧 Configurando integração com gerenciador de arquivos"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        local ran=0
        local managers=("nemo" "nautilus" "dolphin")
        local scripts=("git-add-navigator-nemo.sh" "git-add-navigator-nautilus.sh" "git-add-navigator-dolphin.sh")
        for i in "${!managers[@]}"; do
            local manager="${managers[$i]}"
            local scr="${scripts[$i]}"
            if command -v "$manager" >/dev/null 2>&1; then
                if [ -f "$INSTALL_DIR/$scr" ]; then
                    echo "  → $manager detectado, executando $scr..."
                    bash "$INSTALL_DIR/$scr" || echo "⚠ $scr terminou com erro (ignorado)"
                    ran=$((ran + 1))
                else
                    echo "⚠ $manager detectado mas $scr não encontrado"
                fi
            fi
        done
        if [ "$ran" -eq 0 ]; then
            echo "⚠ Nenhum gerenciador suportado encontrado (nemo, nautilus, dolphin)."
        fi
    else
        echo "⚠ SO não suportado para integração com gerenciador de arquivos."
    fi
}

# -----------------------------------------------------------------------------
# Mensagem final
# -----------------------------------------------------------------------------
Print_Usage() {
    echo ""
    echo "✔ Ambiente pronto!"
    echo ""
    echo "Exemplo de uso:"
    echo "  git-ini.sh"
    echo "  git-feat.sh \"nova funcionalidade\""
    echo "  git-fix.sh \"correção de bug\""
    echo "  git-refactor.sh \"renomear variável\""
    echo "  git-reset.sh"
    echo "  git-undo-reset.sh"
    echo "  git-release.sh"
    echo ""
    echo "Aliases disponíveis: git-feat, git-fix, git-breaking, git-refactor,"
    echo "  git-docs, git-version, git-version-pas-inc, git-generator-lcl,"
    echo "  git-release, git-changelog, git-changelog-summary, git-reset,"
    echo "  git-undo-reset, git-ini"
}

# -----------------------------------------------------------------------------
# Execução principal
# -----------------------------------------------------------------------------
main_install() {
    Install_Scripts
    Generate_Lazarus_XML
    Integrate_Lazarus
    Configure_Aliases
    Git_Add_Navigator
    Print_Usage
}

main_install