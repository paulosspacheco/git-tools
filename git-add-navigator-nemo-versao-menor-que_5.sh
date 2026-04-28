#!/bin/bash
# =============================================================================
# git-add-navigator-nemo.sh — Integração git-tools no Nemo
# =============================================================================
# Instala wrappers dos scripts git-tools no menu de contexto do Nemo,
# permitindo uso direto pelo botão direito em qualquer pasta.
# Lê a lista de scripts e títulos do arquivo git-tools.conf.
#
# Uso: ./git-add-navigator-nemo.sh
#
# Versão: 2.0.0
# Dependências: git-lib.sh, git-tools.conf, zenity, git, pandoc
# =============================================================================

set -e

INSTALL_DIR="/usr/local/bin"
CONF_FILE="$INSTALL_DIR/git-tools.conf"
NEMO_SCRIPTS_DIR="$HOME/.local/share/nemo/scripts/Git Tools"

# =============================================================================
# Pré-verificações
# =============================================================================

check_deps() {
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

check_conf() {
    if [ ! -f "$CONF_FILE" ]; then
        echo "❌ Arquivo de configuração não encontrado: $CONF_FILE" >&2
        echo "   Execute git-install.sh primeiro." >&2
        exit 1
    fi
    echo "✔ Configuração encontrada: $CONF_FILE"
}

check_scripts() {
    local missing=()
    while IFS='|' read -r script title_menu title_laz params; do
        [[ "$script" == "#"* || -z "$script" || -z "$title_menu" ]] && continue
        [ -f "$INSTALL_DIR/$script" ] || missing+=("$script")
    done < "$CONF_FILE"

    if [ ${#missing[@]} -gt 0 ]; then
        echo "⚠ Scripts não encontrados em $INSTALL_DIR:"
        for s in "${missing[@]}"; do echo "    - $s"; done
        echo "  Execute git-install.sh antes de continuar."
        echo ""
    fi
}

# =============================================================================
# Helpers de geração de wrappers
# =============================================================================

_write_header() {
    printf '#!/bin/bash\nset -e\n\n'
    printf '%s\n' \
        '# Garante variáveis de display para zenity (Nemo não as propaga)' \
        "export DISPLAY=\"${DISPLAY:-:0}\"" \
        "export DBUS_SESSION_BUS_ADDRESS=\"${DBUS_SESSION_BUS_ADDRESS}\"" \
        "export XDG_RUNTIME_DIR=\"${XDG_RUNTIME_DIR}\"" \
        ''
    printf '%s\n' 'TARGET="${NEMO_SCRIPT_SELECTED_FILE_PATHS%%$'"'"'\n'"'"'*}"'
    printf 'if [ -d "$TARGET" ]; then\n    cd "$TARGET"\nelse\n    cd "$(dirname "$TARGET")"\nfi\n\n'
}

_write_git_guard() {
    printf '%s\n' \
        'if ! git -C "$TARGET" rev-parse --git-dir > /dev/null 2>&1; then' \
        '    zenity --question \' \
        '        --title="Git Tools" \' \
        '        --text="Esta pasta não é um repositório Git.\n\nDeseja inicializá-la agora?" \' \
        '        --ok-label="Inicializar" \' \
        '        --cancel-label="Cancelar" \' \
        '        --width=380 || exit 0'
    printf '    bash "%s/git-ini.sh"\n' "$INSTALL_DIR"
    printf '%s\n' \
        '    git -C "$TARGET" rev-parse --git-dir > /dev/null 2>&1 || exit 1' \
        'fi' \
        ''
}

# Wrapper simples — sem guarda git (para o próprio git-ini)
make_wrapper() {
    local name="$1"
    local body="$2"
    local file="$NEMO_SCRIPTS_DIR/$name"
    { _write_header; printf '%s\n' "$body"; } > "$file"
    chmod +x "$file"
    echo "  ✔ $name"
}

# Wrapper com guarda git — exige ou oferece inicializar repositório
make_wrapper_git() {
    local name="$1"
    local body="$2"
    local file="$NEMO_SCRIPTS_DIR/$name"
    { _write_header; _write_git_guard; printf '%s\n' "$body"; } > "$file"
    chmod +x "$file"
    echo "  ✔ $name"
}

# =============================================================================
# Instalação no Nemo
# =============================================================================

install_nemo() {
    echo "🔧 Configurando Nemo..."

    # Remove TODAS as variantes anteriores (idempotente)
    echo "  ↻ Removendo instalações anteriores..."
    local SCRIPTS_BASE="$HOME/.local/share/nemo/scripts"
    for dir in \
        "$SCRIPTS_BASE/Git Tools" \
        "$SCRIPTS_BASE/Git-Tools" \
        "$SCRIPTS_BASE/git-tools" \
        "$SCRIPTS_BASE/git tools" \
        "$SCRIPTS_BASE/GitTools"
    do
        [ -d "$dir" ] && rm -rf "$dir" && echo "    🗑 Removido: $dir"
    done
    mkdir -p "$NEMO_SCRIPTS_DIR"

    echo "  Criando wrappers..."

    while IFS='|' read -r script title_menu title_laz params; do
        # Ignora comentários e linhas sem título de menu
        [[ "$script" == "#"* || -z "$script" || -z "$title_menu" ]] && continue

        local body="bash \"$INSTALL_DIR/$script\""
        [ -n "$params" ] && body="bash \"$INSTALL_DIR/$script\" $params"

        # git-ini não precisa de guarda git — é ele que inicializa
        if [[ "$script" == "git-ini.sh" ]]; then
            make_wrapper "${title_menu}.sh" "$body"
        else
            make_wrapper_git "${title_menu}.sh" "$body"
        fi
    done < "$CONF_FILE"

    echo ""
    echo "✔ Scripts instalados em: $NEMO_SCRIPTS_DIR"
    echo ""

    # Garante que o menu Scripts está habilitado no Nemo
    if command -v gsettings >/dev/null 2>&1; then
        local current
        current=$(gsettings get org.nemo.preferences show-scripts-in-context-menus 2>/dev/null || echo "not-set")
        if [ "$current" != "true" ]; then
            gsettings set org.nemo.preferences show-scripts-in-context-menus true 2>/dev/null || true
            echo "✔ Menu 'Scripts' habilitado no Nemo via gsettings"
        else
            echo "✔ Menu 'Scripts' já estava habilitado"
        fi
    else
        echo "⚠ gsettings não disponível — habilite manualmente:"
        echo "   Nemo → Editar → Preferências → Comportamento → Mostrar scripts no menu de contexto"
    fi

    echo ""
    echo "👉 Reinicie o Nemo: nemo -q && nemo &"
}

# =============================================================================
# Principal
# =============================================================================

echo "🚀 Instalando integração git-tools no Nemo"
echo ""

check_deps
check_conf
check_scripts
install_nemo

echo ""
echo "✔ Concluído! Botão direito em qualquer pasta → Scripts → Git Tools"