#!/bin/bash
# =============================================================================
# git-install.sh — Instalação global das ferramentas Git + integrações
# Versão: 4.6.0
# =============================================================================

set -euo pipefail

INSTALL_DIR="/usr/local/bin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/git-tools.conf"
XML_FILE="$SCRIPT_DIR/lazarus.git-tools.xml"

# -----------------------------------------------------------------------------
# Arquivos extras que não estão no .conf
# -----------------------------------------------------------------------------
EXTRA_FILES=(
    git-lib.sh
    git-config.sh
    git-hook.sh
    git-add-navigator-nemo.sh
    git-add-navigator-nautilus.sh
    git-add-navigator-dolphin.sh
    git-tools.conf
)

# -----------------------------------------------------------------------------
# Utilitários internos
# -----------------------------------------------------------------------------

# Encerra com mensagem de erro
die() {
    echo "❌ $*" >&2
    exit 1
}

# Garante que o arquivo de configuração existe
assert_config() {
    [[ -f "$CONFIG_FILE" ]] || die "Configuração não encontrada: $CONFIG_FILE"
}

# Itera sobre linhas válidas do .conf e chama callback(script title_menu title_laz params)
# Uso: parse_config <menu|lazarus|all> <callback>
parse_config() {
    local filter="$1"
    local callback="$2"
    assert_config

    while IFS='|' read -r script title_menu title_laz params; do
        script=$(echo "$script" | xargs)
        title_menu=$(echo "$title_menu" | xargs)
        title_laz=$(echo "$title_laz" | xargs)
        params=$(echo "$params" | xargs)
        [[ -z "$script" || "$script" == \#* ]] && continue
        case "$filter" in
            menu)    [[ -n "$title_menu" ]] && "$callback" "$script" "$title_menu" "$title_laz" "$params" ;;
            lazarus) [[ -n "$title_laz"  ]] && "$callback" "$script" "$title_menu" "$title_laz" "$params" ;;
            all)     "$callback" "$script" "$title_menu" "$title_laz" "$params" ;;
        esac
    done < "$CONFIG_FILE"
}

# -----------------------------------------------------------------------------
# Instalação de arquivos
# -----------------------------------------------------------------------------

_install_file() {
    local file="$1"
    local src="$SCRIPT_DIR/$file"
    [[ -f "$src" ]] || die "Arquivo não encontrado: $src"
    sudo cp "$src" "$INSTALL_DIR/$file" || die "Falha ao copiar: $file"
    if [[ "$file" == *.sh ]]; then
        sudo chmod +x "$INSTALL_DIR/$file"
        echo "  ✔ $file (executável)"
    else
        echo "  ✔ $file (configuração)"
    fi
}

# Wrapper para uso como callback do parse_config (recebe 4 args, usa só o 1º)
_install_file_cb() { _install_file "$1"; }

Install_Scripts() {
    echo "🚀 Instalando arquivos em $INSTALL_DIR"

    # Autentica sudo uma única vez para evitar expiração no meio da instalação
    sudo -v || die "Falha na autenticação sudo"

    for file in "${EXTRA_FILES[@]}"; do
        _install_file "$file"
    done

    parse_config "all" _install_file_cb

    echo "✔ Todos os arquivos instalados com sucesso"
}

# -----------------------------------------------------------------------------
# Configuração do Git (usuário e email)
# Loop de retry: só avança quando ambos estiverem gravados e verificados.
# -----------------------------------------------------------------------------

# Valida formato mínimo de email: deve conter @ e pelo menos um ponto depois dele
_is_valid_email() {
    local email="$1"
    [[ "$email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]
}

# Lê um campo obrigatório com loop até o usuário digitar algo não-vazio
# Uso: _read_required <prompt> <var_name>
_read_required() {
    local prompt="$1"
    local -n _ref="$2"   # nameref — grava diretamente na variável do chamador
    local input=""
    while [[ -z "$input" ]]; do
        read -rp "$prompt" input
        [[ -z "$input" ]] && echo "  ⚠ Campo obrigatório, tente novamente."
    done
    _ref="$input"
}

Configure_Git_User() {
    echo ""
    echo "🔧 Verificando configuração do Git..."

    local git_name git_email
    git_name=$(git config --global user.name  2>/dev/null || true)
    git_email=$(git config --global user.email 2>/dev/null || true)

    # Se ambos já estão configurados, só exibe e sai
    if [[ -n "$git_name" && -n "$git_email" ]]; then
        echo "✔ Git já configurado:"
        echo "   user.name  = $git_name"
        echo "   user.email = $git_email"
        return 0
    fi

    echo ""
    [[ -z "$git_name"  ]] && echo "⚠ 'user.name' não configurado"
    [[ -z "$git_email" ]] && echo "⚠ 'user.email' não configurado"
    echo ""
    echo "📝 Para fazer commits é necessário configurar nome e email no Git."
    echo "   (Pressione Ctrl+C para cancelar a instalação)"
    echo ""

    # Sugestão de nome: GECOS do /etc/passwd, sem campos extras
    local sys_name
    sys_name=$(getent passwd "$USER" 2>/dev/null | cut -d: -f5 | cut -d, -f1 | xargs)

    # Loop principal: repete até ambos estarem gravados e verificados
    while true; do

        # ── Nome ──────────────────────────────────────────────────────────────
        if [[ -z "$git_name" ]]; then
            local default_name="${sys_name:-$USER}"
            local input_name=""
            while [[ -z "$input_name" ]]; do
                read -rp "Nome completo [$default_name]: " input_name
                input_name="${input_name:-$default_name}"
                # default_name nunca é vazio, então isso é seguro
            done
            git_name="$input_name"
        fi

        # ── Email ─────────────────────────────────────────────────────────────
        if [[ -z "$git_email" ]]; then
            local input_email=""
            while true; do
                read -rp "Email: " input_email
                if [[ -z "$input_email" ]]; then
                    echo "  ⚠ Email obrigatório."
                elif ! _is_valid_email "$input_email"; then
                    echo "  ⚠ Formato inválido (esperado: usuario@dominio.tld)."
                    input_email=""
                else
                    break
                fi
            done
            git_email="$input_email"
        fi

        # ── Confirmação ───────────────────────────────────────────────────────
        echo ""
        echo "   user.name  = $git_name"
        echo "   user.email = $git_email"
        read -rp "Confirmar? [S/n]: " confirm
        confirm="${confirm,,}"   # lowercase
        if [[ "$confirm" == "n" || "$confirm" == "nao" || "$confirm" == "não" ]]; then
            echo "↩ Reiniciando configuração..."
            git_name=""
            git_email=""
            continue
        fi

        # ── Grava ─────────────────────────────────────────────────────────────
        echo ""
        if ! git config --global user.name  "$git_name"; then
            echo "❌ Falha ao gravar user.name — tente novamente."
            git_name=""
            continue
        fi
        if ! git config --global user.email "$git_email"; then
            echo "❌ Falha ao gravar user.email — tente novamente."
            git_email=""
            continue
        fi

        # ── Verificação ───────────────────────────────────────────────────────
        local saved_name saved_email
        saved_name=$(git config --global user.name  2>/dev/null || true)
        saved_email=$(git config --global user.email 2>/dev/null || true)

        if [[ "$saved_name" == "$git_name" && "$saved_email" == "$git_email" ]]; then
            echo "✔ Configuração do Git verificada com sucesso!"
            break
        else
            echo "❌ Verificação falhou (valor lido não bate com o gravado)."
            echo "   Gravado : name='$saved_name'  email='$saved_email'"
            echo "   Esperado: name='$git_name'  email='$git_email'"
            echo "↩ Tente novamente."
            git_name=""
            git_email=""
        fi

    done
}

# -----------------------------------------------------------------------------
# Aliases no ~/.bashrc
# -----------------------------------------------------------------------------
Configure_Aliases() {
    echo ""
    echo "🔧 Configurando aliases no bash"

    local BASHRC="$HOME/.bashrc"
    local ALIAS_START="# >>> git-tools start >>>"
    local ALIAS_END="# <<< git-tools end <<<"

    assert_config

    # Remove bloco anterior caso exista
    sed -i "/$ALIAS_START/,/$ALIAS_END/d" "$BASHRC"

    {
        echo ""
        echo "$ALIAS_START"

        while IFS='|' read -r script title_menu title_laz params; do
            script=$(echo "$script"     | xargs)
            title_menu=$(echo "$title_menu" | xargs)
            title_laz=$(echo "$title_laz"   | xargs)
            params=$(echo "$params"     | xargs)
            [[ -z "$script" || "$script" == \#* ]] && continue
            [[ -z "$title_menu" && -z "$title_laz" ]] && continue

            local alias_name="${script%.sh}"
            local params_part=""
            [[ -n "$params" ]] && params_part=" $params"
            echo "alias $alias_name='bash \"$INSTALL_DIR/$script\"$params_part'"
        done < "$CONFIG_FILE"

        echo "$ALIAS_END"
    } >> "$BASHRC"

    echo "✔ Aliases adicionados em ~/.bashrc"
    echo "👉 Execute 'source ~/.bashrc' para usar imediatamente."
}

# -----------------------------------------------------------------------------
# Integração Lazarus — geração do XML
# -----------------------------------------------------------------------------
Generate_Lazarus_XML() {
    echo ""
    echo "🔧 Gerando arquivo de importação para o Lazarus: $XML_FILE"

    assert_config

    local tool_count=0
    local tools_list=()

    while IFS='|' read -r script title_menu title_laz params; do
        script=$(echo "$script"   | xargs)
        title_laz=$(echo "$title_laz" | xargs)
        params=$(echo "$params"   | xargs)
        [[ -z "$script" || "$script" == \#* || -z "$title_laz" ]] && continue
        tools_list+=("$title_laz|$script|$params")
        tool_count=$((tool_count + 1))
    done < "$CONFIG_FILE"

    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo "<CONFIG Version=\"3\" Count=\"$tool_count\">"

        local idx=1
        for tool in "${tools_list[@]}"; do
            IFS='|' read -r name script params <<< "$tool"
            echo "  <Tool$idx>"
            echo "    <Title Value=\"$name\"/>"
            echo "    <Filename Value=\"$INSTALL_DIR/$script\"/>"
            [[ -n "$params" ]] && echo "    <CmdLineParams Value=\"$params\"/>"
            echo "    <WorkingDirectory Value=\"\$ProjPath()\"/>"
            echo "    <Scanners Count=\"1\">"
            echo "      <Item1 Value=\"FPC\"/>"
            echo "    </Scanners>"
            echo "  </Tool$idx>"
            idx=$((idx + 1))
        done

        echo "</CONFIG>"
    } > "$XML_FILE"

    echo "✔ Arquivo gerado: $XML_FILE"
}

Integrate_Lazarus() {
    echo ""
    echo "🔧 Integração com Lazarus (modo manual seguro)"
    echo "⚠ Para evitar corrupção do environmentoptions.xml, a modificação é manual."
    echo ""
    echo "👉 Para adicionar as ferramentas no menu Tools do Lazarus:"
    echo "   1. Abra o Lazarus"
    echo "   2. Acesse Tools → Configure External Tools..."
    echo "   3. Clique em 'Import' e selecione: $XML_FILE"
    echo "   4. Clique em 'OK' e reinicie o Lazarus"
}

# -----------------------------------------------------------------------------
# Integração com gerenciadores de arquivos
# -----------------------------------------------------------------------------
Git_Add_Navigator() {
    echo ""
    echo "🔧 Configurando integração com gerenciador de arquivos"

    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        echo "⚠ SO não suportado para integração com gerenciador de arquivos."
        return 0
    fi

    local managers=("nemo" "nautilus" "dolphin")
    local scripts=("git-add-navigator-nemo.sh" "git-add-navigator-nautilus.sh" "git-add-navigator-dolphin.sh")
    local ran=0

    for i in "${!managers[@]}"; do
        local manager="${managers[$i]}"
        local scr="${scripts[$i]}"
        if command -v "$manager" >/dev/null 2>&1; then
            local scr_path="$INSTALL_DIR/$scr"
            if [[ -f "$scr_path" ]]; then
                echo "  → $manager detectado, executando $scr..."
                bash "$scr_path" || echo "⚠ $scr terminou com erro (ignorado)"
                ran=$((ran + 1))
            else
                echo "⚠ $manager detectado mas $scr não encontrado em $INSTALL_DIR"
            fi
        fi
    done

    if [[ "$ran" -eq 0 ]]; then
        echo "⚠ Nenhum gerenciador suportado encontrado (nemo, nautilus, dolphin)."
    fi
}

# -----------------------------------------------------------------------------
# Mensagem final
# -----------------------------------------------------------------------------
Print_Usage() {
    echo ""
    echo "✔ Ambiente pronto!"
    echo ""
    echo "Exemplo de uso:"
    echo "  git-ini"
    echo "  git-feat \"nova funcionalidade\""
    echo "  git-fix \"correção de bug\""
    echo "  git-refactor \"renomear variável\""
    echo "  git-reset"
    echo "  git-undo-reset"
    echo "  git-release"
    echo ""
    echo "Aliases disponíveis (via ~/.bashrc):"
    assert_config
    while IFS='|' read -r script title_menu title_laz params; do
        script=$(echo "$script"     | xargs)
        title_menu=$(echo "$title_menu" | xargs)
        title_laz=$(echo "$title_laz"   | xargs)
        [[ -z "$script" || "$script" == \#* ]] && continue
        [[ -z "$title_menu" && -z "$title_laz" ]] && continue
        echo "  ${script%.sh}"
    done < "$CONFIG_FILE"
}

# -----------------------------------------------------------------------------
# Execução principal
# -----------------------------------------------------------------------------
main_install() {
    # Guard: detecta execução incorreta com sudo
    # sudo interno nos cp/chmod é ok; sudo bash git-install.sh não é.
    if [[ -n "${SUDO_USER:-}" ]]; then
        die "Não execute com 'sudo bash git-install.sh'.\nUso correto: bash git-install.sh\n(O script solicita sudo internamente só onde necessário)"
    fi
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
        die "Não execute como root.\nUso correto: bash git-install.sh"
    fi

    Install_Scripts
    Generate_Lazarus_XML
    Integrate_Lazarus
    Configure_Git_User
    Configure_Aliases
    Git_Add_Navigator
    Print_Usage
}

main_install