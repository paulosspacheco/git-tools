#!/usr/bin/env bash

# Versão simplificada que funciona

set -euo pipefail

# Função de ajuda
usage() {
    cat <<EOF
Uso: $0 [OPÇÕES]

Opções:
  -s, --since DATA  Inclui apenas commits a partir de DATA (formato YYYY-MM-DD)
  -h, --help        Exibe esta ajuda

Exemplo:
  $0 --since 2026-04-01
EOF
    exit 0
}

# Parsing de argumentos
SINCE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--since)
            SINCE="$2"
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

# Verifica se está dentro de um repositório git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Erro: Este não é um repositório Git."
    exit 1
fi

# Monta comando git log
GIT_LOG_CMD="git log --pretty=format:'%ad|%D|%s' --date=format:'%Y-%m-%d %H:%M'"
if [[ -n "$SINCE" ]]; then
    GIT_LOG_CMD+=" --after='$SINCE'"
fi

# Processa o log e salva em arquivo temporário
TMP_FILE=$(mktemp)
eval "$GIT_LOG_CMD" > "$TMP_FILE"

# Arrays para armazenar dados
declare -a versions
declare -a tag_dates
declare -a all_commits

# Variáveis temporárias
current_version=""
current_tag_date=""
declare -a current_commits

# Lê do arquivo temporário (evita problema de subshell)
while IFS= read -r line; do
    line="${line//\'/}"
    IFS='|' read -r date refs msg <<< "$line"

    # Verifica se é tag
    if [[ "$refs" =~ tag:\ (v[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        version="${BASH_REMATCH[1]}"
        
        # Se já tem uma versão acumulada, salva
        if [[ -n "$current_version" ]]; then
            versions+=("$current_version")
            tag_dates+=("$current_tag_date")
            # Salva commits como string
            commits_str=$(printf '%s\n' "${current_commits[@]}")
            all_commits+=("$commits_str")
        fi
        
        # Começa nova versão
        current_version="$version"
        current_tag_date="$date"
        current_commits=("$date|$msg")
        
    # Verifica se é bump version
    elif [[ "$msg" =~ chore:\ bump\ version\ para\ (v[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        version="${BASH_REMATCH[1]}"
        
        # Se já tem uma versão acumulada, salva
        if [[ -n "$current_version" ]]; then
            versions+=("$current_version")
            tag_dates+=("$current_tag_date")
            commits_str=$(printf '%s\n' "${current_commits[@]}")
            all_commits+=("$commits_str")
        fi
        
        # Começa nova versão
        current_version="$version"
        current_tag_date="$date"
        current_commits=("$date|$msg")
        
    else
        # Commit normal
        if [[ -n "$current_version" ]]; then
            current_commits+=("$date|$msg")
        else
            current_commits+=("$date|$msg")
        fi
    fi
done < "$TMP_FILE"

# Salva a última versão
if [[ -n "$current_version" ]]; then
    versions+=("$current_version")
    tag_dates+=("$current_tag_date")
    commits_str=$(printf '%s\n' "${current_commits[@]}")
    all_commits+=("$commits_str")
fi

# Limpa arquivo temporário
rm "$TMP_FILE"

# Função para extrair tipo
extract_type() {
    local msg="$1"
    if [[ "$msg" =~ ^([a-z]+): ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "outro"
    fi
}

# Função para extrair descrição
extract_description() {
    local msg="$1"
    echo "$msg" | sed -E 's/^[a-z]+:[[:space:]]*//'
}

# Imprime as versões
for i in "${!versions[@]}"; do
    version="${versions[i]}"
    tag_date="${tag_dates[i]}"
    commits_block="${all_commits[i]}"
    
    echo "### $version (tag em $tag_date)"
    
    # Lê commits do bloco
    while IFS= read -r commit_line; do
        [[ -z "$commit_line" ]] && continue
        IFS='|' read -r date msg <<< "$commit_line"
        tipo=$(extract_type "$msg")
        desc=$(extract_description "$msg")
        echo "- $date – **$tipo**: $desc"
    done <<< "$commits_block"
    
    echo ""
done

# Se não encontrou versões
if [[ ${#versions[@]} -eq 0 ]] && [[ ${#current_commits[@]} -gt 0 ]]; then
    echo "### [versão não definida]"
    for commit_line in "${current_commits[@]}"; do
        IFS='|' read -r date msg <<< "$commit_line"
        tipo=$(extract_type "$msg")
        desc=$(extract_description "$msg")
        echo "- $date – **$tipo**: $desc"
    done
    echo ""
fi

if [[ ${#versions[@]} -eq 0 ]] && [[ ${#current_commits[@]} -eq 0 ]]; then
    echo "Nenhum commit encontrado no intervalo especificado."
fi