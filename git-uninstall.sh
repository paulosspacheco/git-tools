#!/bin/bash
# =============================================================================
# git-uninstall.sh — Remoção global das ferramentas Git + integrações
# Versão: 2.1.0 (corrige ordem de remoção)
# =============================================================================

set -e

INSTALL_DIR="/usr/local/bin"
CONFIG_FILE="$INSTALL_DIR/git-tools.conf"
SCRIPT_DIR="$(dirname "$0")"

# -----------------------------------------------------------------------------
# Arquivos extras que NÃO estão no git-tools.conf (mesma lista do instalador)
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
# Função para ler o arquivo de configuração (cópia local)
# -----------------------------------------------------------------------------
parse_config() {
    local filter="$1"
    local callback="$2"
    local config_file="${3:-$CONFIG_FILE}"

    [[ ! -f "$config_file" ]] && return 1

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

# -----------------------------------------------------------------------------
# Remove um único arquivo de $INSTALL_DIR
# -----------------------------------------------------------------------------
remove_one_file() {
    local file="$1"
    local target="$INSTALL_DIR/$file"
    if [ -f "$target" ]; then
        sudo rm -f "$target"
        echo "  ✔ Removido: $file"
    else
        echo "  ⚠ Não encontrado (ignorado): $file"
    fi
}

# -----------------------------------------------------------------------------
# 1. Coletar todos os scripts a remover (sem remover ainda)
# -----------------------------------------------------------------------------
collect_scripts() {
    local scripts_to_remove=("${EXTRA_FILES[@]}")

    # Se o arquivo de configuração existir, adiciona os scripts listados
    if [ -f "$CONFIG_FILE" ]; then
        # Usa um callback que adiciona o script ao array
        add_script_to_list() {
            local script="$1"
            scripts_to_remove+=("$script")
        }
        parse_config "all" add_script_to_list "$CONFIG_FILE"
    else
        echo "⚠ $CONFIG_FILE não encontrado. Removendo apenas scripts extras."
    fi

    # Remove duplicatas (caso algum script apareça nas duas listas)
    # Isso não é estritamente necessário, mas evita mensagens duplicadas
    printf '%s\n' "${scripts_to_remove[@]}" | sort -u
}

# -----------------------------------------------------------------------------
# 2. Remover todos os scripts coletados
# -----------------------------------------------------------------------------
remove_scripts() {
    echo "🗑 Coletando scripts a remover de $INSTALL_DIR..."
    local scripts_list
    scripts_list=$(collect_scripts)

    echo "🗑 Removendo scripts..."
    while IFS= read -r script; do
        [ -z "$script" ] && continue
        remove_one_file "$script"
    done <<< "$scripts_list"

    echo "✔ Scripts removidos"
}

# -----------------------------------------------------------------------------
# 3. Remover lazarus.git-tools.xml do diretório atual
# -----------------------------------------------------------------------------
remove_lazarus_xml() {
    echo ""
    local XML_FILE="$SCRIPT_DIR/lazarus.git-tools.xml"
    if [ -f "$XML_FILE" ]; then
        rm -f "$XML_FILE"
        echo "✔ Arquivo removido: $XML_FILE"
    else
        echo "⚠ Arquivo não encontrado (ignorado): $XML_FILE"
    fi
}

# -----------------------------------------------------------------------------
# 4. Reverter environmentoptions.xml (restaurar backup ou remover bloco)
# -----------------------------------------------------------------------------
revert_environment() {
    echo ""
    echo "🔧 Localizando environmentoptions.xml..."

    local candidates=(
        "$HOME/.lazarus/environmentoptions.xml"
        "/etc/lazarus/environmentoptions.xml"
        "$HOME/Lazarus/lazarus-fixe/config_lazarus/environmentoptions.xml"
        "$HOME/Lazarus/config_lazarus/environmentoptions.xml"
    )
    local expanded=()
    for cand in "${candidates[@]}"; do
        [ -f "$cand" ] && expanded+=("$cand")
    done

    if [ ${#expanded[@]} -eq 0 ]; then
        while IFS= read -r file; do
            expanded+=("$file")
        done < <(find "$HOME" /mnt -maxdepth 5 -name "environmentoptions.xml" 2>/dev/null | grep "config_lazarus")
    fi

    local laz_config="${expanded[0]}"

    if [ -z "$laz_config" ] || [ ! -f "$laz_config" ]; then
        echo "⚠ Não foi possível localizar automaticamente o environmentoptions.xml."
        if command -v zenity &>/dev/null || command -v kdialog &>/dev/null; then
            echo "🔍 Deseja localizar o arquivo manualmente? [S/n]"
            read -r answer
            if [[ ! "$answer" =~ ^[Nn]$ ]]; then
                if command -v zenity &>/dev/null; then
                    laz_config=$(zenity --file-selection --title="Selecione environmentoptions.xml" --file-filter="*.xml" 2>/dev/null)
                elif command -v kdialog &>/dev/null; then
                    laz_config=$(kdialog --getopenfilename "$HOME" "*.xml" 2>/dev/null)
                fi
                [ -z "$laz_config" ] && echo "❌ Nenhum arquivo selecionado."
            fi
        else
            echo "🔍 Deseja fornecer o caminho manualmente? [s/N]"
            read -r answer
            if [[ "$answer" =~ ^[Ss]$ ]]; then
                echo "Digite o caminho completo:"
                read -r laz_config
                [ ! -f "$laz_config" ] && echo "❌ Arquivo não encontrado" && laz_config=""
            fi
        fi
    fi

    if [ -n "$laz_config" ] && [ -f "$laz_config" ]; then
        echo "✔ Arquivo encontrado: $laz_config"
        local backup="${laz_config}.bak"
        if [ -f "$backup" ]; then
            cp "$backup" "$laz_config"
            echo "✔ Configuração restaurada a partir do backup: $backup"
        else
            echo "⚠ Backup não encontrado. Removendo bloco <ExternalTools> diretamente..."
            if grep -q "<ExternalTools" "$laz_config"; then
                sed -i '/<ExternalTools/,/<\/ExternalTools>/d' "$laz_config"
                echo "✔ Bloco <ExternalTools> removido"
            else
                echo "ℹ Nenhum bloco <ExternalTools> encontrado"
            fi
        fi
        echo "👉 Reinicie o Lazarus para aplicar as alterações."
    else
        echo "ℹ Nenhum arquivo environmentoptions.xml processado."
    fi
}

# -----------------------------------------------------------------------------
# 5. Remover aliases do ~/.bashrc (formato novo e antigo)
# -----------------------------------------------------------------------------
remove_aliases() {
    echo ""
    echo "🔧 Removendo aliases do ~/.bashrc..."

    local BASHRC="$HOME/.bashrc"
    if [ ! -f "$BASHRC" ]; then
        echo "ℹ ~/.bashrc não encontrado"
        return
    fi

    cp "$BASHRC" "${BASHRC}.bak-uninstall"

    # Remove bloco com marcadores específicos (novo formato)
    sed -i '/^# >>> git-tools start >>>$/,/^# <<< git-tools end <<<$/d' "$BASHRC"

    # Remove bloco antigo
    sed -i '/^# GIT-TOOLS ALIASES - Gerado por git-install.sh$/,/^# ============================================$/d' "$BASHRC"

    # Remove quaisquer aliases git-* ou version-pas-* que porventura tenham sobrado
    sed -i '/^alias git-/d' "$BASHRC"
    sed -i '/^alias version-pas-/d' "$BASHRC"

    echo "✔ Aliases removidos"
    echo "👉 Execute 'source ~/.bashrc' para limpar a sessão atual."
}

# -----------------------------------------------------------------------------
# 6. Remover wrappers dos gerenciadores de arquivos (Nemo, Nautilus, Dolphin)
# -----------------------------------------------------------------------------
remove_navigator_integrations() {
    echo ""
    echo "🗑 Removendo integrações com gerenciadores de arquivos..."

    # Nemo
    local nemo_dir="$HOME/.local/share/nemo/scripts/Git Tools"
    if [ -d "$nemo_dir" ]; then
        rm -rf "$nemo_dir"
        echo "  ✔ Removido: $nemo_dir"
    else
        echo "  ⚠ Nemo: pasta não encontrada (ignorado)"
    fi

    # Nautilus
    local nautilus_dir="$HOME/.local/share/nautilus/scripts/Git Tools"
    if [ -d "$nautilus_dir" ]; then
        rm -rf "$nautilus_dir"
        echo "  ✔ Removido: $nautilus_dir"
    else
        echo "  ⚠ Nautilus: pasta não encontrada (ignorado)"
    fi

    # Dolphin
    local dolphin_wrappers="$HOME/.local/share/git-tools"
    local dolphin_desktop="$HOME/.local/share/kio/servicemenus/git-tools.desktop"
    if [ -d "$dolphin_wrappers" ]; then
        rm -rf "$dolphin_wrappers"
        echo "  ✔ Removido: $dolphin_wrappers"
    fi
    if [ -f "$dolphin_desktop" ]; then
        rm -f "$dolphin_desktop"
        echo "  ✔ Removido: $dolphin_desktop"
        # Atualiza cache do KDE
        if command -v kbuildsycoca5 &>/dev/null; then
            kbuildsycoca5 &>/dev/null
            echo "  ✔ Cache do KDE atualizado"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Execução principal
# -----------------------------------------------------------------------------
main() {
    echo "🚀 Iniciando desinstalação do git-tools"
    echo ""
    remove_scripts
    remove_lazarus_xml
    revert_environment
    remove_aliases
    remove_navigator_integrations

    echo ""
    echo "✔ Desinstalação concluída!"
}

main