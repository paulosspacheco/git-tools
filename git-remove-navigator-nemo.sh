#!/bin/bash
# =============================================================================
# git-remove-navigator-nemo.sh — Remove integração git-tools do Nemo
# =============================================================================
# Desfaz tudo que foi feito pelo git-add-navigator-nemo.sh:
#   - Remove os wrappers do menu de contexto do Nemo
#   - Desabilita o menu Scripts no Nemo (opcional)
#
# Uso: ./git-remove-navigator-nemo.sh
#
# Versão: 1.0.0
# =============================================================================

set -e

SCRIPTS_BASE="$HOME/.local/share/nemo/scripts"

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

    if [ "$removed" -eq 0 ]; then
        echo "  ℹ Nenhum diretório Git Tools encontrado — nada a remover."
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

remove_scripts
disable_scripts_menu
restart_nemo

echo ""
echo "✔ Concluído! Os scripts Git Tools foram removidos do menu de contexto do Nemo."