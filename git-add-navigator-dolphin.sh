#!/bin/bash
# =============================================================================
# git-add-navigator-dolphin.sh — Integração git-tools no Dolphin (KDE)
# Versão: 0.6.0
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
    for cmd in zenity git; do
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
                  git-version-inc.sh git-version.sh; do
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
# Geração dos wrappers
# =============================================================================

make_wrapper_simple() {
    local name="$1"
    local git_script="$2"
    local wrapper="$WRAPPER_DIR/$name"
    cat > "$wrapper" <<EOF
#!/bin/bash
set -e
export DISPLAY="\${DISPLAY:-:0}"
export WAYLAND_DISPLAY="\${WAYLAND_DISPLAY:-wayland-0}"
TARGET="\$1"
[ -z "\$TARGET" ] && { zenity --error --text="Nenhum diretório selecionado."; exit 1; }
cd "\$TARGET"
bash "$INSTALL_DIR/$git_script"
EOF
    chmod +x "$wrapper"
    echo "  ✔ $name"
}

make_wrapper_with_guard() {
    local name="$1"
    local git_script="$2"
    local zenity_block="$3"
    local wrapper="$WRAPPER_DIR/$name"

    cat > "$wrapper" <<EOF
#!/bin/bash
set -e
export DISPLAY="\${DISPLAY:-:0}"
export WAYLAND_DISPLAY="\${WAYLAND_DISPLAY:-wayland-0}"
TARGET="\$1"
[ -z "\$TARGET" ] && { zenity --error --text="Nenhum diretório selecionado."; exit 1; }
cd "\$TARGET"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    zenity --question \\
        --title="Git Tools" \\
        --text="Esta pasta não é um repositório Git.\n\nDeseja inicializá-la agora?" \\
        --ok-label="Inicializar" \\
        --cancel-label="Cancelar" \\
        --width=380 || exit 0
    bash "$INSTALL_DIR/git-ini.sh"
    git rev-parse --git-dir > /dev/null 2>&1 || exit 1
fi

EOF

    if [ -n "$zenity_block" ]; then
        printf '%s\n' "$zenity_block" >> "$wrapper"
        printf '\nbash "%s/%s" "$DESC"\n' "$INSTALL_DIR" "$git_script" >> "$wrapper"
    else
        printf 'bash "%s/%s"\n' "$INSTALL_DIR" "$git_script" >> "$wrapper"
    fi

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
Exec=bash "$WRAPPER_DIR/git-version-inc-wrapper.sh" %d

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

    make_wrapper_simple "git-ini-wrapper.sh" "git-ini.sh"

    make_wrapper_with_guard "git-feat-wrapper.sh" "git-feat.sh" \
'DESC=$(zenity --entry --title="Git feat" --text="Descrição da nova funcionalidade:" --width=400) || exit 0
[ -z "$DESC" ] && { zenity --error --text="Descrição não pode ser vazia."; exit 1; }'

    make_wrapper_with_guard "git-fix-wrapper.sh" "git-fix.sh" \
'DESC=$(zenity --entry --title="Git fix" --text="Descrição da correção:" --width=400) || exit 0
[ -z "$DESC" ] && { zenity --error --text="Descrição não pode ser vazia."; exit 1; }'

    make_wrapper_with_guard "git-breaking-wrapper.sh" "git-breaking.sh" \
'DESC=$(zenity --entry --title="Git breaking" --text="Descrição da breaking change:" --width=400) || exit 0
[ -z "$DESC" ] && { zenity --error --text="Descrição não pode ser vazia."; exit 1; }'

    make_wrapper_with_guard "git-docs-wrapper.sh" "git-docs.sh" \
'DESC=$(zenity --entry --title="Git docs" --text="Descrição da documentação:" --width=400) || exit 0
[ -z "$DESC" ] && { zenity --error --text="Descrição não pode ser vazia."; exit 1; }'

    make_wrapper_with_guard "git-release-wrapper.sh"     "git-release.sh"     ""
    make_wrapper_with_guard "git-version-inc-wrapper.sh" "git-version-inc.sh" ""
    make_wrapper_with_guard "git-version-wrapper.sh"     "git-version.sh"     ""
    make_wrapper_with_guard "git-changelog-wrapper.sh"   "git-changelog.sh"   ""

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