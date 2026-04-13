#!/bin/bash
# =============================================================================
# git-add-navigator-nautilus.sh — Integração git-tools no Nautilus
# Versão: 1.1.0 (usa parse_config do git-lib.sh)
# =============================================================================
# Gera wrappers no diretório ~/.local/share/nautilus/scripts/Git Tools
# baseados nas entradas do arquivo /usr/local/bin/git-tools.conf
# =============================================================================

set -e

INSTALL_DIR="/usr/local/bin"
CONFIG_FILE="$INSTALL_DIR/git-tools.conf"
NAUTILUS_SCRIPTS_DIR="$HOME/.local/share/nautilus/scripts/Git Tools"

# -----------------------------------------------------------------------------
# Carrega funções comuns do git-lib.sh (parse_config, etc.)
# -----------------------------------------------------------------------------
if [ -f "$INSTALL_DIR/git-lib.sh" ]; then
    source "$INSTALL_DIR/git-lib.sh"
else
    echo "❌ git-lib.sh não encontrado em $INSTALL_DIR"
    echo "   Execute o git-install.sh primeiro."
    exit 1
fi

# -----------------------------------------------------------------------------
# Gera um wrapper (script) para o Nautilus
# -----------------------------------------------------------------------------
create_nautilus_wrapper() {
    local script="$1"
    local title_menu="$2"
    local title_laz="$3"
    local params="$4"

    local wrapper_name="${title_menu}.sh"
    local wrapper_path="$NAUTILUS_SCRIPTS_DIR/$wrapper_name"

    # Cabeçalho com variáveis de ambiente para Zenity (Nautilus não as propaga)
    cat > "$wrapper_path" <<EOF
#!/bin/bash
# Wrapper gerado automaticamente para $script
# Título: $title_menu

# Garante variáveis de display (Nautilus não as propaga)
export DISPLAY="\${DISPLAY:-:0}"
export DBUS_SESSION_BUS_ADDRESS="\${DBUS_SESSION_BUS_ADDRESS}"
export XDG_RUNTIME_DIR="\${XDG_RUNTIME_DIR}"

# O Nautilus fornece a variável NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
# com o caminho do arquivo/pasta selecionado (pode conter múltiplas linhas)
TARGET="\${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS%%\$'\\n'*}"
if [ -d "\$TARGET" ]; then
    cd "\$TARGET"
else
    cd "\$(dirname "\$TARGET")"
fi

# Verifica se é um repositório Git (exceto para o script de inicialização)
if [[ "$script" != "git-ini.sh" ]]; then
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        if zenity --question \\
            --title="Git Tools" \\
            --text="Esta pasta não é um repositório Git.\\n\\nDeseja inicializá-la agora?" \\
            --ok-label="Inicializar" \\
            --cancel-label="Cancelar" \\
            --width=380 2>/dev/null; then
            bash "$INSTALL_DIR/git-ini.sh"
            # Após inicializar, verifica novamente
            if ! git rev-parse --git-dir > /dev/null 2>&1; then
                zenity --error --text="Falha ao inicializar repositório." 2>/dev/null
                exit 1
            fi
        else
            exit 0
        fi
    fi
fi

# Executa o script com os parâmetros definidos no git-tools.conf
exec bash "$INSTALL_DIR/$script" $params
EOF

    chmod +x "$wrapper_path"
    echo "  ✔ $wrapper_name"
}

# -----------------------------------------------------------------------------
# Instalação principal
# -----------------------------------------------------------------------------
install_nautilus() {
    echo "🔧 Configurando Nautilus..."

    # Remove instalações anteriores (idempotente)
    echo "  ↻ Removendo instalações anteriores..."
    local SCRIPTS_BASE="$HOME/.local/share/nautilus/scripts"
    for dir in \
        "$SCRIPTS_BASE/Git Tools" \
        "$SCRIPTS_BASE/Git-Tools" \
        "$SCRIPTS_BASE/git-tools" \
        "$SCRIPTS_BASE/git tools" \
        "$SCRIPTS_BASE/GitTools"
    do
        [ -d "$dir" ] && rm -rf "$dir" && echo "    🗑 Removido: $dir"
    done

    mkdir -p "$NAUTILUS_SCRIPTS_DIR"

    echo "  Criando wrappers a partir de $CONFIG_FILE..."

    # Gera wrappers para todas as entradas com TITULO_MENU preenchido
    parse_config "menu" create_nautilus_wrapper "$CONFIG_FILE"

    echo ""
    echo "✔ Scripts instalados em: $NAUTILUS_SCRIPTS_DIR"
    echo ""
    echo "👉 Reinicie o Nautilus (ou faça logout/login) para que as alterações tenham efeito."
    echo "   Para recarregar rapidamente: nautilus -q && nautilus &"
}

# -----------------------------------------------------------------------------
# Verificação de dependências (opcional, mas útil)
# -----------------------------------------------------------------------------
check_deps() {
    local missing=()
    for cmd in zenity git; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "⚠ Dependências ausentes: ${missing[*]}"
        echo "  Instale com: sudo apt install ${missing[*]}"
        echo ""
    fi
}

# -----------------------------------------------------------------------------
# Execução principal
# -----------------------------------------------------------------------------
main() {
    echo "🚀 Instalando integração git-tools no Nautilus"
    echo ""
    check_deps
    install_nautilus
    echo ""
    echo "✔ Concluído! Botão direito em qualquer pasta → Scripts → Git Tools"
}

main