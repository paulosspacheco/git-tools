#!/bin/bash
# =============================================================================
# git-add-navigator-nemo.sh — Integração git-tools no Nemo
# =============================================================================
# Instala wrappers dos scripts git-tools no menu de contexto do Nemo,
# permitindo uso direto pelo botão direito em qualquer pasta.
#
# Uso: ./git-add-navigator-nemo.sh
#
# Versão: 1.1.0
# Dependências: git-lib.sh, zenity, git, pandoc
# =============================================================================

set -e

INSTALL_DIR="/usr/local/bin"
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

check_scripts() {
    local missing=()
    for script in git-feat.sh git-fix.sh git-breaking.sh git-refactor.sh \
                  git-docs.sh git-changelog.sh git-ini.sh git-release.sh \
                  git-version-pas-inc.sh git-version.sh \
                  git-reset.sh git-undo-reset.sh; do
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
# Helpers de geração de wrappers
# Todas as variáveis do runtime ($DESC, $TARGET, etc.) são gravadas literalmente
# via printf '%s\n'. Somente $INSTALL_DIR expande em tempo de instalação.
# =============================================================================

# Cabeçalho comum: resolve TARGET e faz cd
# _write_header() {
#     printf '#!/bin/bash\nset -e\n\n'
#     printf '%s\n' 'TARGET="${NEMO_SCRIPT_SELECTED_FILE_PATHS%%$'"'"'\n'"'"'*}"'
#     printf 'if [ -d "$TARGET" ]; then\n    cd "$TARGET"\nelse\n    cd "$(dirname "$TARGET")"\nfi\n\n'
# }

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

# Guarda git: se a pasta não for repositório, oferece inicializar
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

    # ── git-ini: sem guarda (é ele próprio que inicializa) ───────────────────

    make_wrapper "01 - Inicializar repositório (ini).sh" \
        "bash \"$INSTALL_DIR/git-ini.sh\""

    # ── Com guarda git + input via zenity ────────────────────────────────────

    make_wrapper_git "02 - Nova funcionalidade (feat).sh" \
'DESC=$(zenity --entry \
    --title="Git feat" \
    --text="Descrição da nova funcionalidade:" \
    --width=400) || exit 0
[ -z "$DESC" ] && { zenity --error --text="Descrição não pode ser vazia."; exit 1; }
bash "'"$INSTALL_DIR"'/git-feat.sh" "$DESC"'

    make_wrapper_git "03 - Correção (fix).sh" \
'DESC=$(zenity --entry \
    --title="Git fix" \
    --text="Descrição da correção:" \
    --width=400) || exit 0
[ -z "$DESC" ] && { zenity --error --text="Descrição não pode ser vazia."; exit 1; }
bash "'"$INSTALL_DIR"'/git-fix.sh" "$DESC"'

    make_wrapper_git "04 - Breaking change.sh" \
'DESC=$(zenity --entry \
    --title="Git breaking" \
    --text="Descrição da breaking change:" \
    --width=400) || exit 0
[ -z "$DESC" ] && { zenity --error --text="Descrição não pode ser vazia."; exit 1; }
bash "'"$INSTALL_DIR"'/git-breaking.sh" "$DESC"'

    make_wrapper_git "05 - Refatoração (refactor).sh" \
'DESC=$(zenity --entry \
    --title="Git refactor" \
    --text="Descrição da refatoração:" \
    --width=400) || exit 0
[ -z "$DESC" ] && { zenity --error --text="Descrição não pode ser vazia."; exit 1; }
bash "'"$INSTALL_DIR"'/git-refactor.sh" "$DESC"'

    make_wrapper_git "06 - Commit de documentação (docs).sh" \
'DESC=$(zenity --entry \
    --title="Git docs" \
    --text="Descrição da documentação:" \
    --width=400) || exit 0
[ -z "$DESC" ] && { zenity --error --text="Descrição não pode ser vazia."; exit 1; }
bash "'"$INSTALL_DIR"'/git-docs.sh" "$DESC"'

    # ── Com guarda git, sem input ─────────────────────────────────────────────

    make_wrapper_git "07 - Fazer release.sh" \
        "bash \"$INSTALL_DIR/git-release.sh\""

    make_wrapper_git "08 - Incrementar versão.sh" \
        "bash \"$INSTALL_DIR/git-version-pas-inc.sh\""

    make_wrapper_git "09 - Calcular próxima versão.sh" \
        "bash \"$INSTALL_DIR/git-version.sh\""

    make_wrapper_git "10 - Gerar CHANGELOG.sh" \
        "bash \"$INSTALL_DIR/git-changelog.sh\" "

    make_wrapper_git "11 - Gerar CHANGELOG HTML.sh" \
        "bash \"$INSTALL_DIR/git-changelog.sh\" --html"

    # ── Recuperação ──────────────────────────────────────────────────────────

    make_wrapper_git "12 - Desfazer último commit (reset).sh" \
        "bash \"$INSTALL_DIR/git-reset.sh\""

    make_wrapper_git "13 - Recuperar commit desfeito (undo reset).sh" \
        "bash \"$INSTALL_DIR/git-undo-reset.sh\""

    echo ""
    echo "✔ Scripts instalados em: $NEMO_SCRIPTS_DIR"
    echo ""

    # Garante que o menu Scripts está habilitado no Nemo
    if command -v gsettings >/dev/null 2>&1; then
        local current
        current=$(gsettings get org.nemo.preferences show-scripts-in-context-menus 2>/dev/null || echo "not-set")
        if [ "$current" != "true" ]; then
            gsettings set org.nemo.preferences show-scripts-in-context-menus true 2>/dev/null || true
            echo "✔ Menu 'Scripts' habilitado no Nemo via gsettings (ou chave inexistente, ignorado)"
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
check_scripts
install_nemo

echo ""
echo "✔ Concluído! Botão direito em qualquer pasta → Scripts → Git Tools"