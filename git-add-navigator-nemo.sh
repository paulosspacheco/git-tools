#!/bin/bash
# =============================================================================
# git-add-navigator-nemo.sh — Integração git-tools no Nemo
# =============================================================================
# Versão: 4.0.0
# Data da versão: 2026-10-14
# Objetivo da versão: o item "Git Tools" aparece direto no menu de contexto
#   do Nemo (Nemo Action), sem passar pelo submenu "Scripts".
# Observações:
#   - Uso: ./git-add-navigator-nemo.sh
#   - O script mestre fica em ~/.local/share/nemo/actions, pasta que nenhum
#     outro instalador do git-tools apaga
# =============================================================================

set -e

INSTALL_DIR="/usr/local/bin"
CONF_FILE="$INSTALL_DIR/git-tools.conf"
NEMO_SCRIPTS_DIR="$HOME/.local/share/nemo/scripts"
NEMO_ACTIONS_DIR="$HOME/.local/share/nemo/actions"
MASTER_SCRIPT="$NEMO_ACTIONS_DIR/git-tools-nemo.sh"
ACTION_FILE="$NEMO_ACTIONS_DIR/git-tools.nemo_action"

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
    local master_script="$MASTER_SCRIPT"

    echo "  Criando script mestre..."

    cat > "$master_script" << 'MASTER_EOF'
#!/bin/bash
# =============================================================================
# Git Tools - Script mestre com submenu
# =============================================================================

INSTALL_DIR="/usr/local/bin"
CONF_FILE="$INSTALL_DIR/git-tools.conf"

# ---------------------------------------------------------------------------
# Resolve o diretório de trabalho
# $1 = pasta atual do Nemo (%P); $2... = itens selecionados (%F)
# Preferência: primeiro item selecionado; fallback: pasta atual
# ---------------------------------------------------------------------------
CURRENT_DIR="$1"
shift || true

TARGET=""
for item in "$@"; do
    [ -n "$item" ] && { TARGET="$item"; break; }
done
[ -z "$TARGET" ] && TARGET="$CURRENT_DIR"

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
    --text="Pasta: $(pwd)\n\nSelecione a operação Git desejada:" \
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
    echo "  ✔ Script mestre: $master_script"
}

# =============================================================================
# Criar Nemo Action (item "Git Tools" direto no menu de contexto)
# =============================================================================

create_action() {
    cat > "$ACTION_FILE" << EOF
[Nemo Action]
Active=true
Name=Git Tools
Comment=Operações Git do git-tools nesta pasta
Exec=bash "$MASTER_SCRIPT" %P %F
Icon-Name=git
Selection=any
Extensions=any;
Quote=double
Dependencies=zenity;git;
EOF

    echo "  ✔ Nemo Action: $ACTION_FILE"
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
    if [ -f "$scripts_base/Git Tools.sh" ]; then
        rm -f "$scripts_base/Git Tools.sh"
        echo "    🗑 Removido: $scripts_base/Git Tools.sh"
    fi

    rm -f "$MASTER_SCRIPT" 2>/dev/null || true
}

# =============================================================================
# Instalação principal
# =============================================================================

install_nemo() {
    echo "🔧 Configurando Nemo..."

    mkdir -p "$NEMO_ACTIONS_DIR"

    clean_old_installations

    echo ""
    create_master_script
    create_action

    echo ""
    echo "👉 Reinicie o Nemo: nemo -q && nemo &"
    echo ""
    echo "📌 Como usar:"
    echo "   → Clique direito em qualquer pasta"
    echo "   → Escolha 'Git Tools'"
    echo "   → Escolha a operação desejada na lista"
}

# =============================================================================
# Principal
# =============================================================================

echo "🚀 Instalando integração git-tools no Nemo"
echo ""

check_deps
check_conf
install_nemo

echo ""
echo "✔ Concluído! Botão direito em qualquer pasta → Git Tools"