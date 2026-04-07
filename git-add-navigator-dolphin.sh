#!/bin/bash
# =============================================================================
# git-add-navigator-dolphin.sh — Integração git-tools no Dolphin (KDE)
# Versão: 0.7.0
# =============================================================================

set -e

INSTALL_DIR="/usr/local/bin"
WRAPPER_DIR="$HOME/.local/share/git-tools"
SERVICE_DIR="$HOME/.local/share/kio/servicemenus"
DESKTOP_FILE="$SERVICE_DIR/git-tools.desktop"

# =============================================================================
# Pré-verificações
# =============================================================================

check_deps() {
    local missing=()
    for cmd in zenity git konsole; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "⚠ Dependências ausentes: ${missing[*]}"
        echo "  Instale com: sudo apt install ${missing[*]}"
        echo ""
    fi
}

check_scripts() {
    local missing=()
    for script in git-feat.sh git-fix.sh git-breaking.sh git-docs.sh \
                  git-changelog.sh git-ini.sh git-release.sh \
                  version-pas-inc.sh git-version.sh; do
        [ -f "$INSTALL_DIR/$script" ] || missing+=("$script")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "⚠ Scripts não encontrados em $INSTALL_DIR:"
        for s in "${missing[@]}"; do echo "    - $s"; done
        echo "  Instale os scripts git-tools antes de continuar."
        echo ""
    fi
}

# =============================================================================
# Cabeçalho comum de todos os wrappers
# =============================================================================

write_wrapper_header() {
    local wrapper="$1"
    cat > "$wrapper" <<'EOF'
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

# =============================================================================
# Geração dos wrappers
# =============================================================================

make_wrapper_simple() {
    local name="$1"
    local git_script="$2"
    local wrapper="$WRAPPER_DIR/$name"

    write_wrapper_header "$wrapper"
    printf '\nkonsole --noclose -e bash -c "bash %q; echo; echo '"'"'--- Pressione qualquer tecla para fechar ---'"'"'; read -n1"\n' \
        "$INSTALL_DIR/$git_script" >> "$wrapper"

    chmod +x "$wrapper"
    echo "  ✔ $name"
}

make_wrapper_with_desc() {
    local name="$1"
    local git_script="$2"
    local zenity_title="$3"
    local zenity_text="$4"
    local wrapper="$WRAPPER_DIR/$name"

    write_wrapper_header "$wrapper"

    cat >> "$wrapper" <<EOF

if ! git -C "\$TARGET" rev-parse --git-dir > /dev/null 2>&1; then
    zenity --question \\
        --title="Git Tools" \\
        --text="Esta pasta não é um repositório Git.\n\nDeseja inicializá-la agora?" \\
        --ok-label="Inicializar" \\
        --cancel-label="Cancelar" \\
        --width=380 || exit 0
    konsole --noclose -e bash -c "bash '$INSTALL_DIR/git-ini.sh'; echo; echo '--- Pressione qualquer tecla para fechar ---'; read -n1"
    git -C "\$TARGET" rev-parse --git-dir > /dev/null 2>&1 || exit 1
fi

DESC=\$(zenity --entry \\
    --title="$zenity_title" \\
    --text="$zenity_text" \\
    --width=450) || exit 0

if [ -z "\$DESC" ]; then
    zenity --error --title="Git Tools" --text="Descrição não pode ser vazia." --width=300
    exit 1
fi

konsole --noclose -e bash -c "bash '$INSTALL_DIR/$git_script' \"\$DESC\"; echo; echo '--- Pressione qualquer tecla para fechar ---'; read -n1"
EOF

    chmod +x "$wrapper"
    echo "  ✔ $name"
}

make_wrapper_no_desc() {
    local name="$1"
    local git_script="$2"
    local wrapper="$WRAPPER_DIR/$name"

    write_wrapper_header "$wrapper"

    cat >> "$wrapper" <<EOF

if ! git -C "\$TARGET" rev-parse --git-dir > /dev/null 2>&1; then
    zenity --question \\
        --title="Git Tools" \\
        --text="Esta pasta não é um repositório Git.\n\nDeseja inicializá-la agora?" \\
        --ok-label="Inicializar" \\
        --cancel-label="Cancelar" \\
        --width=380 || exit 0
    konsole --noclose -e bash -c "bash '$INSTALL_DIR/git-ini.sh'; echo; echo '--- Pressione qualquer tecla para fechar ---'; read -n1"
    git -C "\$TARGET" rev-parse --git-dir > /dev/null 2>&1 || exit 1
fi

konsole --noclose -e bash -c "bash '$INSTALL_DIR/$git_script'; echo; echo '--- Pressione qualquer tecla para fechar ---'; read -n1"
EOF

    chmod +x "$wrapper"
    echo "  ✔ $name"
}

# =============================================================================
# Criação do arquivo .desktop
# =============================================================================

create_desktop() {
    echo "  Criando arquivo .desktop..."
    mkdir -p "$SERVICE_DIR"
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Service
ServiceTypes=KonqPopupMenu/Plugin
MimeType=inode/directory;
X-KDE-Submenu=Git Tools
Actions=Ini;Feat;Fix;Breaking;Docs;Release;VersionInc;Version;Changelog

[Desktop Action Ini]
Name=01 - Inicializar repositório (ini)
Icon=git
Exec=bash "$WRAPPER_DIR/git-ini-wrapper.sh" %d

[Desktop Action Feat]
Name=02 - Nova funcionalidade (feat)
Icon=git
Exec=bash "$WRAPPER_DIR/git-feat-wrapper.sh" %d

[Desktop Action Fix]
Name=03 - Correção (fix)
Icon=git
Exec=bash "$WRAPPER_DIR/git-fix-wrapper.sh" %d

[Desktop Action Breaking]
Name=04 - Breaking change
Icon=git
Exec=bash "$WRAPPER_DIR/git-breaking-wrapper.sh" %d

[Desktop Action Docs]
Name=05 - Commit de documentação (docs)
Icon=git
Exec=bash "$WRAPPER_DIR/git-docs-wrapper.sh" %d

[Desktop Action Release]
Name=06 - Fazer release
Icon=git
Exec=bash "$WRAPPER_DIR/git-release-wrapper.sh" %d

[Desktop Action VersionInc]
Name=07 - Incrementar versão
Icon=git
Exec=bash "$WRAPPER_DIR/version-pas-inc-wrapper.sh" %d

[Desktop Action Version]
Name=08 - Calcular próxima versão
Icon=git
Exec=bash "$WRAPPER_DIR/git-version-wrapper.sh" %d

[Desktop Action Changelog]
Name=09 - Gerar CHANGELOG
Icon=git
Exec=bash "$WRAPPER_DIR/git-changelog-wrapper.sh" %d
EOF
    chmod +x "$DESKTOP_FILE"
    echo "  ✔ $DESKTOP_FILE"
}

# =============================================================================
# Instalação principal
# =============================================================================

install_dolphin() {
    echo "🔧 Configurando Dolphin..."
    echo "  ↻ Removendo instalações anteriores..."
    rm -rf "$WRAPPER_DIR"
    rm -f "$DESKTOP_FILE"

    mkdir -p "$WRAPPER_DIR"
    echo "  Criando wrappers..."

    make_wrapper_simple    "git-ini-wrapper.sh"      "git-ini.sh"

    make_wrapper_with_desc "git-feat-wrapper.sh"     "git-feat.sh"     \
        "Git feat"     "Descrição da nova funcionalidade:"

    make_wrapper_with_desc "git-fix-wrapper.sh"      "git-fix.sh"      \
        "Git fix"      "Descrição da correção:"

    make_wrapper_with_desc "git-breaking-wrapper.sh" "git-breaking.sh" \
        "Git breaking" "Descrição da breaking change:"

    make_wrapper_with_desc "git-docs-wrapper.sh"     "git-docs.sh"     \
        "Git docs"     "Descrição da documentação:"

    make_wrapper_no_desc   "git-release-wrapper.sh"     "git-release.sh"
    make_wrapper_no_desc   "version-pas-inc-wrapper.sh" "version-pas-inc.sh"
    make_wrapper_no_desc   "git-version-wrapper.sh"     "git-version.sh"
    make_wrapper_no_desc   "git-changelog-wrapper.sh"   "git-changelog.sh"

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

# =============================================================================
# Principal
# =============================================================================

echo "🚀 Instalando integração git-tools no Dolphin"
echo ""

check_deps
check_scripts
install_dolphin

echo ""
echo "✔ Concluído! Clique com o botão direito em uma pasta → Git Tools"