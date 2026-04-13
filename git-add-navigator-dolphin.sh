#!/bin/bash
# =============================================================================
# git-add-navigator-dolphin.sh — Integração git-tools no Dolphin (KDE)
# Versão: 2.3.0 (sem set -e, robusta)
# =============================================================================

INSTALL_DIR="/usr/local/bin"
CONFIG_FILE="/usr/local/bin/git-tools.conf"
WRAPPER_DIR="$HOME/.local/share/git-tools"
SERVICE_DIR="$HOME/.local/share/kio/servicemenus"
DESKTOP_FILE="$SERVICE_DIR/git-tools.desktop"

# -----------------------------------------------------------------------------
# Função parse_config (cópia local)
# -----------------------------------------------------------------------------
source "/usr/local/bin/git-lib.sh"

# -----------------------------------------------------------------------------
# Verificação de dependências
# -----------------------------------------------------------------------------
check_deps() {
    local missing=()
    for cmd in zenity git konsole; do
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

# -----------------------------------------------------------------------------
# Cabeçalho dos wrappers
# -----------------------------------------------------------------------------
_write_header() {
    cat << 'EOF'
#!/bin/bash
export DISPLAY="${DISPLAY:-:0}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

TARGET="$1"
if [ -z "$TARGET" ]; then
    zenity --error --title="Git Tools" --text="Nenhum diretório selecionado." --width=300
    exit 1
fi
cd "$TARGET"
EOF
}

_write_git_guard() {
    cat << 'EOF'
if ! git -C "$TARGET" rev-parse --git-dir > /dev/null 2>&1; then
    zenity --question \
        --title="Git Tools" \
        --text="Esta pasta não é um repositório Git.\n\nDeseja inicializá-la agora?" \
        --ok-label="Inicializar" \
        --cancel-label="Cancelar" \
        --width=380 || exit 0
    konsole --noclose -e bash -c "bash \"$INSTALL_DIR/git-ini.sh\"; echo; echo '--- Pressione qualquer tecla para fechar ---'; read -n1"
    git -C "$TARGET" rev-parse --git-dir > /dev/null 2>&1 || exit 1
fi
EOF
}

make_wrapper() {
    local name="$1"
    local script="$2"
    local params="$3"
    local file="$WRAPPER_DIR/$name"
    {
        _write_header
        echo "konsole --noclose -e bash -c \"bash \\\"$INSTALL_DIR/$script\\\" $params; echo; echo '--- Pressione qualquer tecla para fechar ---'; read -n1\""
    } > "$file"
    chmod +x "$file"
    echo "  ✔ $name"
}

make_wrapper_git() {
    local name="$1"
    local script="$2"
    local params="$3"
    local file="$WRAPPER_DIR/$name"
    {
        _write_header
        _write_git_guard
        echo "konsole --noclose -e bash -c \"bash \\\"$INSTALL_DIR/$script\\\" $params; echo; echo '--- Pressione qualquer tecla para fechar ---'; read -n1\""
    } > "$file"
    chmod +x "$file"
    echo "  ✔ $name"
}

# -----------------------------------------------------------------------------
# Criação do arquivo .desktop
# -----------------------------------------------------------------------------
_desktop_action() {
    local script="$1"
    local title_menu="$2"
    local title_laz="$3"
    local params="$4"
    local id wrapper_name
    id=$(basename "$script" .sh | sed 's/-/_/g')
    wrapper_name="$(basename "$script" .sh)-wrapper.sh"
    printf '[Desktop Action %s]\n' "$id"
    printf 'Name=%s\n' "$title_menu"
    printf 'Icon=git\n'
    printf 'Exec=bash "%s/%s" %%d\n\n' "$WRAPPER_DIR" "$wrapper_name"
}

create_desktop() {
    echo "  Criando arquivo .desktop..."
    mkdir -p "$SERVICE_DIR"

    local actions=()
    _collect_id() {
        local script="$1"
        local id
        id=$(basename "$script" .sh | sed 's/-/_/g')
        actions+=("$id")
    }
    parse_config "menu" "_collect_id"

    {
        printf '[Desktop Entry]\n'
        printf 'Type=Service\n'
        printf 'ServiceTypes=KonqPopupMenu/Plugin\n'
        printf 'MimeType=inode/directory;\n'
        printf 'X-KDE-Submenu=Git Tools\n'
        printf 'Actions=%s\n\n' "$(IFS=';'; echo "${actions[*]}")"
        parse_config "menu" "_desktop_action"
    } > "$DESKTOP_FILE"

    chmod +x "$DESKTOP_FILE"
    echo "  ✔ $DESKTOP_FILE"
}

# -----------------------------------------------------------------------------
# Instalação principal
# -----------------------------------------------------------------------------
_install_wrapper() {
    local script="$1"
    local title_menu="$2"
    local title_laz="$3"
    local params="$4"
    local wrapper_name
    wrapper_name="$(basename "$script" .sh)-wrapper.sh"

    if [[ "$script" == "git-ini.sh" ]]; then
        make_wrapper "$wrapper_name" "$script" "$params"
    else
        make_wrapper_git "$wrapper_name" "$script" "$params"
    fi
}

install_dolphin() {
    echo "🔧 Configurando Dolphin..."

    # Conta quantas entradas com título serão processadas
    local count=0
    _count() { count=$((count + 1)); }
    parse_config "menu" "_count"
    echo "  → Encontradas $count entradas no $CONFIG_FILE"

    echo "  ↻ Removendo instalações anteriores..."
    rm -rf "$WRAPPER_DIR"
    rm -f "$DESKTOP_FILE"
    mkdir -p "$WRAPPER_DIR"

    echo "  Criando wrappers..."
    parse_config "menu" "_install_wrapper"

    create_desktop

    echo ""
    echo "✔ Wrappers instalados em: $WRAPPER_DIR"
    echo "✔ Arquivo .desktop instalado em: $DESKTOP_FILE"
    echo ""

    if command -v kbuildsycoca5 >/dev/null 2>&1; then
        kbuildsycoca5
        echo "✔ Cache de serviços KDE atualizado."
    else
        echo "⚠ kbuildsycoca5 não encontrado. Reinicie o Dolphin manualmente."
    fi

    echo ""
    echo "👉 Para que as alterações tenham efeito, reinicie o Dolphin:"
    echo "   dolphin --quit && dolphin &"
}

# -----------------------------------------------------------------------------
# Principal
# -----------------------------------------------------------------------------
echo "🚀 Instalando integração git-tools no Dolphin"
echo ""

check_deps
install_dolphin

echo ""
echo "✔ Concluído! Clique com o botão direito em uma pasta → Git Tools"