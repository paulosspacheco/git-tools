#!/bin/bash

echo "=== LINHA DO TEMPO DOS COMMITS ==="
git log --pretty=format:"%ad|%D|%s" --date=format:"%Y-%m-%d %H:%M" --reverse | tail -20

echo -e "\n=== COMMITS COM TAG v0.14.3 ==="
git log --pretty=format:"%ad|%D|%s" --date=format:"%Y-%m-%d %H:%M" | grep "v0.14.3"

echo -e "\n=== COMMIT DA TAG v0.14.3 ==="
git show-ref --tags -d | grep v0.14.3

echo -e "\n=== VERIFICANDO COMMIT ESPECÍFICO ==="
COMMIT_HASH=$(git show-ref --tags -d | grep v0.14.3 | head -1 | awk '{print $1}')
echo "Hash do commit da tag: $COMMIT_HASH"
git log --pretty=format:"%ad|%D|%s" --date=format:"%Y-%m-%d %H:%M" -1 $COMMIT_HASH

echo -e "\n=== TODAS AS TAGS ==="
git tag -l | sort -V