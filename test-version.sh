#!/bin/bash

# Teste para verificar se o script detecta a versão v0.14.3

echo "=== TESTANDO DETECÇÃO DE VERSÃO v0.14.3 ==="

# Primeiro, vamos ver se existe a tag v0.14.3
echo "1. Verificando se tag v0.14.3 existe:"
git show-ref --tags | grep v0.14.3

echo -e "\n2. Últimas tags:"
git describe --tags --abbrev=0

echo -e "\n3. Log com tags:"
git log --oneline -5 --decorate

echo -e "\n4. Testando extração de versão do seu script:"

# Função do seu script para extrair versão de tag
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

echo -e "\n5. Testando com commit real do v0.14.3:"
git log --pretty=format:"%ad|%D|%s" --date=format:"%Y-%m-%d %H:%M" | grep "v0.14.3" | head -2

echo -e "\n6. Executando uma linha específica:"
LINE="2026-04-09 10:06|tag: v0.14.3|chore: bump version para v0.14.3"
echo "Linha: $LINE"
IFS='|' read -r date refs msg <<< "$LINE"

echo "Data: $date"
echo "Refs: $refs"
echo "Msg: $msg"

tag_version=$(extract_version_from_tag "$refs")
echo "Versão da tag: '$tag_version'"

bump_version=$(extract_version_from_bump "$msg")
echo "Versão do bump: '$bump_version'"

echo -e "\n7. Verificando regex:"
if [[ "$refs" =~ tag:\ (v[0-9]+\.[0-9]+\.[0-9]+) ]]; then
    echo "Regex MATCH! Grupo 1: '${BASH_REMATCH[1]}'"
else
    echo "Regex NO MATCH!"
fi

if [[ "$msg" =~ chore:\ bump\ version\ para\ (v[0-9]+\.[0-9]+\.[0-9]+) ]]; then
    echo "Bump regex MATCH! Grupo 1: '${BASH_REMATCH[1]}'"
else
    echo "Bump regex NO MATCH!"
fi