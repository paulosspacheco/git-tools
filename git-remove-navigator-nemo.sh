#!/bin/bash
# =============================================================================
# git-remove-navigator-nemo.sh — Remove integração git-tools do Nemo
# =============================================================================
# Versão: 2.0.0
# Data da versão: 2026-10-14
# Objetivo da versão: remover a Nemo Action "Git Tools" e o script mestre
#   criados pelo git-add-navigator-nemo.sh 4.0.0, além das instalações
#   antigas em Scripts (inclusive o arquivo "Git Tools.sh").
# Observações:
#   - Uso: ./git-remove-navigator-nemo.sh
#   - Desabilitar o menu Scripts do Nemo é opcional (pergunta ao usuário)
# =============================================================================

set -e

SCRIPTS_BASE="$HOME/.local/share/nemo/scripts"
ACTIONS_BASE="$HOME/.local/share/nemo/actions"

# =============================================================================
# Remove a Nemo Action e o script mestre
# =============================================================================

remove_action() {
    echo "🗑  Removendo Nemo Action Git Tools..."

    local removed=0
    for f in "$ACTIONS_BASE"/git-*.nemo_action "$ACTIONS_BASE/git-tools-nemo.sh"; do
        if [ -f "$f" ]; then
            rm -f "$f"
            echo "  ✔ Removido: $f"
            removed=$((removed + 1))
        fi
    done

    if [ "$removed" -eq 0 ]; then
        echo "  ℹ Nenhuma Nemo Action Git Tools encontrada."
    fi
    echo ""
}

# =============================================================================
# Remove todas as variantes do diretório Git Tools
# =============================================================================

remove_scripts() {
    echo "🗑  Removendo wrappers Git Tools do Nemo..."

    local removed=0
    for dir in \
        "$SCRIPTS_BASE/Git Tools" \
        "$SCRIPTS_BASE/Git-Tools" \
        "$SCRIPTS_BASE/git-tools" \
        "$SCRIPTS_BASE/git tools" \
        "$SCRIPTS_BASE/GitTools"
    do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            echo "  ✔ Removido: $dir"
            removed=$((removed + 1))
        fi
    done

    if [ -f "$SCRIPTS_BASE/Git Tools.sh" ]; then
        rm -f "$SCRIPTS_BASE/Git Tools.sh"
        echo "  ✔ Removido: $SCRIPTS_BASE/Git Tools.sh"
        removed=$((removed + 1))
    fi

    if [ "$removed" -eq 0 ]; then
        echo "  ℹ Nenhum script Git Tools encontrado em Scripts — nada a remover."
    fi
}

# =============================================================================
# Desabilita o menu Scripts no Nemo (opcional)
# =============================================================================

disable_scripts_menu() {
    echo ""
    echo "🔧 Verificando menu Scripts no Nemo..."

    if command -v gsettings >/dev/null 2>&1; then
        local current
        current=$(gsettings get org.nemo.preferences show-scripts-in-context-menus 2>/dev/null || echo "not-set")
        if [ "$current" = "true" ]; then
            echo "  O menu 'Scripts' está habilitado no Nemo."
            read -p "  Deseja desabilitá-lo também? [s/N]: " RESP
            RESP=${RESP,,}  # lowercase
            if [ "$RESP" = "s" ]; then
                gsettings set org.nemo.preferences show-scripts-in-context-menus false
                echo "  ✔ Menu 'Scripts' desabilitado no Nemo."
            else
                echo "  ℹ Menu 'Scripts' mantido habilitado."
            fi
        else
            echo "  ℹ Menu 'Scripts' já estava desabilitado — nada a fazer."
        fi
    else
        echo "  ⚠ gsettings não disponível — verifique manualmente:"
        echo "     Nemo → Editar → Preferências → Comportamento → Mostrar scripts no menu de contexto"
    fi
}

# =============================================================================
# Reinicia o Nemo
# =============================================================================

restart_nemo() {
    echo ""
    echo "🔄 Reiniciando Nemo para aplicar as mudanças..."
    if command -v nemo >/dev/null 2>&1; then
        nemo -q 2>/dev/null || true
        sleep 1
        nemo & disown
        echo "  ✔ Nemo reiniciado."
    else
        echo "  ⚠ Nemo não encontrado — reinicie manualmente."
    fi
}

# =============================================================================
# Principal
# =============================================================================

echo "🚀 Removendo integração git-tools do Nemo"
echo ""

remove_action
remove_scripts
disable_scripts_menu
restart_nemo

echo ""
echo "✔ Concluído! O item Git Tools foi removido do menu de contexto do Nemo."