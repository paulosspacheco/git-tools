#!/usr/bin/env bash

set -euo pipefail

# Carrega a biblioteca compartilhada (git-lib.sh fornecida)
source "/usr/local/bin/git-lib.sh"

# ------------------------------
# Função de ajuda
# ------------------------------
usage() {
    cat <<EOF
Uso: $0 [OPÇÕES]

Opções:
  -s, --since DATA  Inclui apenas commits a partir de DATA (formato YYYY-MM-DD)
  -h, --help        Exibe esta ajuda

Quando executado sem argumentos (especialmente via gerenciador de arquivos),
o script solicitará interativamente a data. Se a data for deixada em branco,
mostrará todo o histórico.

Exemplo:
  $0 --since 2026-04-01
EOF
    exit 0
}

# ------------------------------
# Parsing de argumentos com fallback interativo
# ------------------------------
parse_args() {
    SINCE=""
    
    if [[ $# -eq 0 ]]; then
        echo "Modo interativo ativado (sem argumentos)."
        local user_input
        # ATENÇÃO: ask_optional NÃO EXISTE na git-lib.sh fornecida!
        # Isso causará um erro. Adicione ask_optional à biblioteca ou remova esta linha.
        if ask_optional user_input "Data inicial (YYYY-MM-DD) — deixe em branco para todo o histórico" ""; then
            SINCE="$user_input"
        else
            echo "Operação cancelada."
            exit 0
        fi
        return
    fi
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--since)
                if [[ -z "$2" ]]; then
                    SINCE=""
                else
                    SINCE="$2"
                fi
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Argumento desconhecido: $1"
                usage
                ;;
        esac
    done
}

# ------------------------------
# Verifica se está dentro de um repositório git
# ------------------------------
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local msg="Erro: Este não é um repositório Git."
        echo "$msg" >&2
        notify_info "$msg"
        exit 1
    fi
}

# ------------------------------
# Gera o log git e salva em um arquivo temporário
# ------------------------------
generate_git_log() {
    local tmp_file
    tmp_file=$(mktemp)
    local git_cmd=("git" "log" "--pretty=format:%ad|%D|%s" "--date=format:%Y-%m-%d %H:%M")
    
    if [[ -n "$SINCE" ]]; then
        git_cmd+=("--after=$SINCE")
    fi
    
    "${git_cmd[@]}" > "$tmp_file"
    echo "$tmp_file"
}

# ------------------------------
# Processa o arquivo de log e preenche arrays globais
# ------------------------------
process_log() {
    local log_file="$1"
    
    versions=()
    tag_dates=()
    all_commits=()
    
    local current_version=""
    local current_tag_date=""
    local current_commits=()
    
    while IFS= read -r line; do
        line="${line//\'/}"
        IFS='|' read -r date refs msg <<< "$line"
        
        if [[ "$refs" =~ tag:\ (v[0-9]+\.[0-9]+\.[0-9]+) ]]; then
            version="${BASH_REMATCH[1]}"
            
            if [[ -n "$current_version" ]]; then
                versions+=("$current_version")
                tag_dates+=("$current_tag_date")
                commits_str=$(printf '%s\n' "${current_commits[@]}")
                all_commits+=("$commits_str")
            fi
            
            current_version="$version"
            current_tag_date="$date"
            current_commits=("$date|$msg")
            
        elif [[ "$msg" =~ chore:\ bump\ version\ para\ (v[0-9]+\.[0-9]+\.[0-9]+) ]]; then
            version="${BASH_REMATCH[1]}"
            
            if [[ -n "$current_version" ]]; then
                versions+=("$current_version")
                tag_dates+=("$current_tag_date")
                commits_str=$(printf '%s\n' "${current_commits[@]}")
                all_commits+=("$commits_str")
            fi
            
            current_version="$version"
            current_tag_date="$date"
            current_commits=("$date|$msg")
            
        else
            current_commits+=("$date|$msg")
        fi
    done < "$log_file"
    
    if [[ -n "$current_version" ]]; then
        versions+=("$current_version")
        tag_dates+=("$current_tag_date")
        commits_str=$(printf '%s\n' "${current_commits[@]}")
        all_commits+=("$commits_str")
    fi
    
    if [[ ${#versions[@]} -eq 0 ]] && [[ ${#current_commits[@]} -gt 0 ]]; then
        versions+=("versão não definida")
        tag_dates+=("")
        commits_str=$(printf '%s\n' "${current_commits[@]}")
        all_commits+=("$commits_str")
    fi
}

# ------------------------------
# Funções auxiliares para extrair tipo e descrição
# ------------------------------
extract_type() {
    local msg="$1"
    if [[ "$msg" =~ ^([a-z]+): ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "outro"
    fi
}

extract_description() {
    local msg="$1"
    echo "$msg" | sed -E 's/^[a-z]+:[[:space:]]*//'
}

# ------------------------------
# Impressão do changelog
# ------------------------------
print_changelog() {
    local output=""
    
    if [[ ${#versions[@]} -eq 0 ]]; then
        output="Nenhum commit encontrado no intervalo especificado."
        echo "$output"
        notify_info "$output"
        return
    fi
    
    for i in "${!versions[@]}"; do
        version="${versions[i]}"
        tag_date="${tag_dates[i]}"
        commits_block="${all_commits[i]}"
        
        if [[ "$version" == "versão não definida" ]]; then
            output+="### [versão não definida]\n"
        else
            output+="### $version (tag em $tag_date)\n"
        fi
        
        while IFS= read -r commit_line; do
            [[ -z "$commit_line" ]] && continue
            IFS='|' read -r date msg <<< "$commit_line"
            tipo=$(extract_type "$msg")
            desc=$(extract_description "$msg")
            output+="- $date – **$tipo**: $desc\n"
        done <<< "$commits_block"
        
        output+="\n"
    done
    
    echo -e "$output"
    
    if _has_display && command -v zenity >/dev/null; then
        echo -e "$output" | zenity --text-info \
            --title="Changelog Gerado" \
            --width=800 \
            --height=600 \
            --font="Monospace" \
            2>/dev/null
    else
        echo -e "$output"
    fi
}

# ------------------------------
# Função principal
# ------------------------------
main_changelog() {
    parse_args "$@"
    check_git_repo
    
    local log_file
    log_file=$(generate_git_log)
    
    process_log "$log_file"
    rm -f "$log_file"
    
    print_changelog
}

# ------------------------------
# Execução
# ------------------------------
main_changelog "$@"