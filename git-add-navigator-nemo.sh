#!/bin/bash
# =============================================================================
# git-add-navigator-nemo.sh — Integração git-tools no Nemo (com submenu)
# =============================================================================
# Instala um script mestre no Nemo que cria um submenu "Git Tools"
# com todas as opções disponíveis.
#
# Uso: ./git-add-navigator-nemo.sh
#
# Versão: 3.2.0
# =============================================================================

set -e

INSTALL_DIR="/usr/local/bin"
CONF_FILE="$INSTALL_DIR/git-tools.conf"
NEMO_SCRIPTS_DIR="$HOME/.local/share/nemo/scripts"

# =============================================================================
# Pré-verificações
# =============================================================================

check_deps() {
    local missing=()
    for cmd in zenity git; do
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

check_conf() {
    if [ ! -f "$CONF_FILE" ]; then
        echo "❌ Arquivo de configuração não encontrado: $CONF_FILE" >&2
        echo "   Execute git-install.sh primeiro." >&2
        exit 1
    fi
    echo "✔ Configuração encontrada: $CONF_FILE"
}

# =============================================================================
# Criar script mestre com submenu
# =============================================================================

create_master_script() {
    local master_script="$NEMO_SCRIPTS_DIR/Git Tools.sh"

    echo "  Criando script mestre com submenu..."

    cat > "$master_script" << 'MASTER_EOF'
#!/bin/bash
# =============================================================================
# Git Tools - Script mestre com submenu
# =============================================================================

INSTALL_DIR="/usr/local/bin"
CONF_FILE="$INSTALL_DIR/git-tools.conf"

# ---------------------------------------------------------------------------
# Resolve o diretório de trabalho
# Preferência: arquivo/pasta selecionado; fallback: URI atual do Nemo
# ---------------------------------------------------------------------------
TARGET="${NEMO_SCRIPT_SELECTED_FILE_PATHS%%$'\n'*}"

if [ -z "$TARGET" ] && [ -n "$NEMO_SCRIPT_CURRENT_URI" ]; then
    TARGET=$(python3 -c \
        "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1][7:]))" \
        "$NEMO_SCRIPT_CURRENT_URI" 2>/dev/null || echo "$HOME")
fi

if [ -d "$TARGET" ]; then
    cd "$TARGET"
elif [ -n "$TARGET" ]; then
    cd "$(dirname "$TARGET")"
else
    zenity --error --title="Git Tools" \
        --text="Não foi possível determinar o diretório de trabalho."
    exit 1
fi

# ---------------------------------------------------------------------------
# Executa um script com verificação de repositório
# ---------------------------------------------------------------------------
exec_git_script() {
    local script="$1"
    local params="$2"
    local script_path="$INSTALL_DIR/$script"

    # Verifica se o script existe
    if [ ! -f "$script_path" ]; then
        zenity --error --title="Git Tools" \
            --text="Script não encontrado:\n$script_path\n\nVerifique a instalação do git-tools."
        exit 1
    fi

    # Verifica repositório Git (exceto para git-ini)
    if [[ "$script" != "git-ini.sh" ]]; then
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
            zenity --question \
                --title="Git Tools" \
                --text="Esta pasta não é um repositório Git.\n\nDeseja inicializá-la agora?" \
                --ok-label="Inicializar" \
                --cancel-label="Cancelar" \
                --width=380 || exit 0

            bash "$INSTALL_DIR/git-ini.sh"

            if ! git rev-parse --git-dir > /dev/null 2>&1; then
                zenity --error --title="Git Tools" \
                    --text="Falha ao inicializar o repositório."
                exit 1
            fi
        fi
    fi

    # Executa o script
    if [ -n "$params" ]; then
        bash "$script_path" $params
    else
        bash "$script_path"
    fi
}

# ---------------------------------------------------------------------------
# Remove numeração do título para exibição ("01 - Foo" → "Foo")
# ---------------------------------------------------------------------------
clean_title() {
    echo "$1" | sed 's/^[0-9]\+ - //'
}

# ---------------------------------------------------------------------------
# Lê as opções do arquivo de configuração
# ---------------------------------------------------------------------------
OPTIONS=()
COMMANDS=()
PARAMS_LIST=()

while IFS='|' read -r script title_menu title_laz params; do
    script=$(echo "$script" | xargs)
    title_menu=$(echo "$title_menu" | xargs)
    params=$(echo "$params" | xargs)

    [[ "$script" == "#"* || -z "$script" || -z "$title_menu" ]] && continue

    display_title=$(clean_title "$title_menu")
    OPTIONS+=("$display_title")
    COMMANDS+=("$script")
    PARAMS_LIST+=("$params")
done < "$CONF_FILE"

# ---------------------------------------------------------------------------
# Exibe o submenu via zenity
# ---------------------------------------------------------------------------
CHOICE=$(zenity --list \
    --title="Git Tools" \
    --text="Selecione a operação Git desejada:" \
    --column="Comandos Git" \
    "${OPTIONS[@]}" \
    --width=400 \
    --height=500 \
    --cancel-label="Cancelar")

[ -z "$CHOICE" ] && exit 0

# ---------------------------------------------------------------------------
# Executa a opção escolhida
# ---------------------------------------------------------------------------
for i in "${!OPTIONS[@]}"; do
    if [ "${OPTIONS[$i]}" = "$CHOICE" ]; then
        exec_git_script "${COMMANDS[$i]}" "${PARAMS_LIST[$i]}"
        break
    fi
done
MASTER_EOF

    chmod +x "$master_script"
    echo "  ✔ Git Tools.sh (script mestre com submenu)"
}

# =============================================================================
# Limpar instalações anteriores
# =============================================================================

clean_old_installations() {
    echo "  ↻ Removendo instalações anteriores..."

    # Remove actions antigas (se existirem)
    local actions_dir="$HOME/.local/share/nemo/actions"
    if [ -d "$actions_dir" ]; then
        rm -f "$actions_dir"/git-*.nemo_action 2>/dev/null || true
        echo "    ✔ Removidas actions antigas"
    fi

    local scripts_base="$HOME/.local/share/nemo/scripts"

    # Remove pastas "Git Tools" com variações de nome
    for dir in \
        "$scripts_base/Git Tools" \
        "$scripts_base/Git-Tools" \
        "$scripts_base/git-tools" \
        "$scripts_base/git tools" \
        "$scripts_base/GitTools"
    do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            echo "    🗑 Removido: $dir"
        fi
    done

    # Remove apenas o script mestre anterior (não toca em scripts de terceiros)
    rm -f "$scripts_base/Git Tools.sh" 2>/dev/null || true
}

# =============================================================================
# Habilitar menu Scripts no Nemo
# =============================================================================

enable_scripts_menu() {
    echo ""
    echo "  🔧 Habilitando menu Scripts no Nemo..."

    if command -v gsettings >/dev/null 2>&1; then
        for key in show-scripts-in-context-menus scripts-in-context-menu show-scripts-menu; do
            if gsettings list-keys org.nemo.preferences 2>/dev/null | grep -q "$key"; then
                gsettings set org.nemo.preferences "$key" true 2>/dev/null && \
                echo "    ✔ Menu Scripts habilitado via gsettings ($key)"
                break
            fi
        done
    fi

    echo "    ℹ Se o menu 'Scripts' não aparecer, ative manualmente:"
    echo "      Nemo → Editar → Preferências → Comportamento"
    echo "      → Marque 'Mostrar scripts no menu de contexto'"
}

# =============================================================================
# Instalação principal
# =============================================================================

install_nemo() {
    echo "🔧 Configurando Nemo (com submenu Git Tools)..."

    mkdir -p "$NEMO_SCRIPTS_DIR"

    clean_old_installations

    echo ""
    echo "  Criando estrutura de menus..."

    create_master_script

    echo ""
    echo "✔ Script mestre instalado em: $NEMO_SCRIPTS_DIR/Git Tools.sh"
    echo ""

    enable_scripts_menu

    echo ""
    echo "👉 Reinicie o Nemo: nemo -q && nemo &"
    echo ""
    echo "📌 Como usar:"
    echo "   → Clique direito em qualquer pasta"
    echo "   → Vá em 'Scripts' → 'Git Tools'"
    echo "   → Escolha a operação desejada no submenu"
}

# =============================================================================
# Principal
# =============================================================================

echo "🚀 Instalando integração git-tools no Nemo (com submenu)"
echo ""

check_deps
check_conf
install_nemo

echo ""
echo "✔ Concluído! Botão direito em qualquer pasta → Scripts → Git Tools"