#!/usr/bin/env bash

# git-version-report.sh
# Gera relatório organizado por versão a partir do log do Git,
# agrupando commits por tag ou bump de versão, com suporte a filtro de data inicial.

set -euo pipefail

# Função de ajuda
usage() {
    cat <<EOF
Uso: $0 [OPÇÕES]

Opções:
  -s, --since DATA  Inclui apenas commits a partir de DATA (formato YYYY-MM-DD)
  -h, --help        Exibe esta ajuda

O relatório é gerado a partir do repositório Git do diretório atual.
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
    echo "Erro: Este não é um repositório Git (ou está fora da árvore de trabalho)."
    exit 1
fi

# Monta comando git log
GIT_LOG_CMD="git log --reverse --pretty=format:'%ad|%D|%s' --date=format:'%Y-%m-%d %H:%M'"
if [[ -n "$SINCE" ]]; then
    GIT_LOG_CMD+=" --after='$SINCE'"
fi

# Função para extrair versão de uma referência (tag)
extract_version_from_tag() {
    local refs="$1"
    # Procura por "tag: vX.Y.Z" (suporta até 3 partes)
    if [[ "$refs" =~ tag:\ (v[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# Função para extrair versão de mensagem de bump
extract_version_from_bump() {
    local msg="$1"
    if [[ "$msg" =~ chore:\ bump\ version\ para\ (v[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# Função para extrair o tipo da mensagem (feat, fix, refactor, docs, chore, etc.)
extract_type() {
    local msg="$1"
    if [[ "$msg" =~ ^([a-z]+): ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "outro"
    fi
}

# Função para obter a descrição (mensagem sem o prefixo do tipo)
extract_description() {
    local msg="$1"
    # Remove o primeiro campo até ":" (incluindo espaço após, se houver)
    echo "$msg" | sed -E 's/^[a-z]+:[[:space:]]*//'
}

# Função para imprimir uma versão completa
print_version() {
    local version="$1"
    local tag_date="$2"
    shift 2
    local commits=("$@")  # array de strings no formato "data|mensagem"

    if [[ ${#commits[@]} -eq 0 ]]; then
        return
    fi

    echo "### $version (tag em $tag_date)"
    for entry in "${commits[@]}"; do
        IFS='|' read -r date msg <<< "$entry"
        tipo=$(extract_type "$msg")
        desc=$(extract_description "$msg")
        echo "- $date – **$tipo**: $desc"
    done
    echo ""
}

# Leitura do log
current_version=""
current_tag_date=""
current_commits=()
# Variável para controlar se já encontramos a primeira versão (para evitar imprimir versão vazia)
found_any_version=false

# Executa o log e processa linha a linha
eval "$GIT_LOG_CMD" | while IFS= read -r line; do
    # Remove aspas que podem ter sido inseridas pelo eval
    line="${line//\'/}"
    IFS='|' read -r date refs msg <<< "$line"

    # Verifica se este commit é um marcador de versão (tag ou bump)
    version=""
    is_marker=false
    tag_version=$(extract_version_from_tag "$refs")
    if [[ -n "$tag_version" ]]; then
        version="$tag_version"
        is_marker=true
    else
        bump_version=$(extract_version_from_bump "$msg")
        if [[ -n "$bump_version" ]]; then
            version="$bump_version"
            is_marker=true
        fi
    fi

    if [[ "$is_marker" == true ]]; then
        # Finaliza a versão anterior (se houver commits acumulados)
        if [[ ${#current_commits[@]} -gt 0 ]]; then
            print_version "$current_version" "$current_tag_date" "${current_commits[@]}"
            found_any_version=true
        fi
        # Inicia nova versão com este commit como o primeiro (e único até agora)
        current_version="$version"
        current_tag_date="$date"
        current_commits=()
        # Adiciona o próprio commit marcador à lista da nova versão
        current_commits+=("$date|$msg")
    else
        # Commit comum: adiciona à versão atual (se houver versão corrente)
        if [[ -n "$current_version" ]]; then
            current_commits+=("$date|$msg")
        else
            # Ainda não encontramos nenhuma versão; acumula commits soltos
            # (serão impressos como "versão não definida" ao final)
            current_commits+=("$date|$msg")
        fi
    fi
done

# Após o loop, imprime a última versão (se houver)
if [[ ${#current_commits[@]} -gt 0 ]]; then
    if [[ -n "$current_version" ]]; then
        print_version "$current_version" "$current_tag_date" "${current_commits[@]}"
    else
        # Commits que nunca foram associados a nenhuma versão
        echo "### [versão não definida]"
        for entry in "${current_commits[@]}"; do
            IFS='|' read -r date msg <<< "$entry"
            tipo=$(extract_type "$msg")
            desc=$(extract_description "$msg")
            echo "- $date – **$tipo**: $desc"
        done
        echo ""
    fi
fi

if [[ "$found_any_version" == false ]] && [[ ${#current_commits[@]} -eq 0 ]]; then
    echo "Nenhum commit encontrado no intervalo especificado."
fi