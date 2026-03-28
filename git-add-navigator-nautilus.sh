#!/bin/bash
# =============================================================================
# git-add-navigator-nautilus.sh — Integração git-tools no Nautilus
# Versão: 0.4.0
# =============================================================================

set -e

INSTALL_DIR="/usr/local/bin"
NAUTILUS_SCRIPTS_DIR="$HOME/.local/share/nautilus/scripts/Git Tools"

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
# Helpers de geração de wrappers
# =============================================================================

# Cabeçalho comum: resolve TARGET a partir da variável do Nautilus e faz cd
_write_header() {
    printf '#!/bin/bash\nset -e\n\n'
    printf '%s\n' 'TARGET="${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS%%$'"'"'\n'"'"'*}"'
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
    # $INSTALL_DIR expande aqui (tempo de instalação)
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
    local file="$NAUTILUS_SCRIPTS_DIR/$name"
    { _write_header; printf '%s\n' "$body"; } > "$file"
    chmod +x "$file"
    echo "  ✔ $name"
}

# Wrapper com guarda git — exige ou oferece inicializar repositório
make_wrapper_git() {
    local name="$1"
    local body="$2"
    local file="$NAUTILUS_SCRIPTS_DIR/$name"
    { _write_header; _write_git_guard; printf '%s\n' "$body"; } > "$file"
    chmod +x "$file"
    echo "  ✔ $name"
}

# =============================================================================
# Instalação no Nautilus
# =============================================================================

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

    make_wrapper_git "05 - Commit de documentação (docs).sh" \
'DESC=$(zenity --entry \
    --title="Git docs" \
    --text="Descrição da documentação:" \
    --width=400) || exit 0
[ -z "$DESC" ] && { zenity --error --text="Descrição não pode ser vazia."; exit 1; }
bash "'"$INSTALL_DIR"'/git-docs.sh" "$DESC"'

    # ── Com guarda git, sem input ─────────────────────────────────────────────

    make_wrapper_git "06 - Fazer release.sh" \
        "bash \"$INSTALL_DIR/git-release.sh\""

    make_wrapper_git "07 - Incrementar versão.sh" \
        "bash \"$INSTALL_DIR/git-version-inc.sh\""

    make_wrapper_git "08 - Calcular próxima versão.sh" \
        "bash \"$INSTALL_DIR/git-version.sh\""

    make_wrapper_git "09 - Gerar CHANGELOG.sh" \
        "bash \"$INSTALL_DIR/git-changelog.sh\" --write"

    echo ""
    echo "✔ Scripts instalados em: $NAUTILUS_SCRIPTS_DIR"
    echo ""
    echo "👉 Reinicie o Nautilus (ou faça logout/login) para que as alterações tenham efeito."
    echo "   Para recarregar rapidamente: nautilus -q && nautilus &"
}

# =============================================================================
# Principal
# =============================================================================

echo "🚀 Instalando integração git-tools no Nautilus"
echo ""

check_deps
check_scripts
install_nautilus

echo ""
echo "✔ Concluído! Botão direito em qualquer pasta → Scripts → Git Tools"