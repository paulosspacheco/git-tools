#!/bin/bash
# =============================================================================
# mover-para-semuso.sh — Move para a pasta semuso os arquivos fora do projeto
# =============================================================================
# Uso: ./mover-para-semuso.sh [-n|--simular]
#
# Data da versão: 2026-10-09
# Versão: 1.0.0
# Objetivo da versão: tirar da raiz do projeto os arquivos de depuração, de
#   configuração pessoal e gerados, sem apagar nada.
# Observações:
#   - Executar na pasta do projeto, onde está o git-lib.sh
#   - A lista de arquivos fica na variável ARQUIVOS; edite para incluir ou
#     retirar nomes
#   - Arquivo que já está no Git é retirado do controle (git rm --cached) e
#     movido; depois é preciso fazer o commit
#   - A pasta semuso/ é acrescentada ao .gitignore
#   - Para devolver um arquivo: mv semuso/arquivo .
#   - Com --simular apenas mostra o que seria movido
# Dependências: git-lib.sh
# =============================================================================

source "$(dirname "$0")/git-lib.sh"

cd "$(dirname "$0")" || exit 1

DESTINO="semuso"

ARQUIVOS=(
  install.log
  tree.txt
  check-timeline.sh
  test-version.sh
  git-add-navigator-nemo-versao-menor-que_5.sh
  git-tools.md
  git-tools.code-workspace
  resumo.jpeg
)

SIMULAR=false
case "${1:-}" in
  -n|--simular) SIMULAR=true ;;
  "") ;;
  *)
    echo "Uso: $0 [-n|--simular]" >&2
    exit 1
    ;;
esac

encontrados=()
for f in "${ARQUIVOS[@]}"; do
  [ -e "$f" ] && encontrados+=("$f")
done

if [ ${#encontrados[@]} -eq 0 ]; then
  notify_info "Nenhum arquivo para mover."
  exit 0
fi

lista=$(printf '  • %s\n' "${encontrados[@]}")

if [ "$SIMULAR" = true ]; then
  echo "Seriam movidos para $DESTINO/:"
  echo "$lista"
  exit 0
fi

ask_confirm CONFIRMA "Mover para $DESTINO/ os arquivos abaixo?\n\n$lista\n\nOs que estão no Git deixam de ser versionados e $DESTINO/ entra no .gitignore."

if [ "${CONFIRMA,,}" != "s" ]; then
  notify_info "Operação cancelada."
  exit 0
fi

mkdir -p "$DESTINO"

movidos=0
pulados=0
saidos_git=0
dentro_git=false
git rev-parse --is-inside-work-tree >/dev/null 2>&1 && dentro_git=true

for f in "${encontrados[@]}"; do
  if [ -e "$DESTINO/$f" ]; then
    echo "⚠ $DESTINO/$f já existe — $f mantido"
    pulados=$((pulados + 1))
    continue
  fi

  if [ "$dentro_git" = true ] && git ls-files --error-unmatch -- "$f" >/dev/null 2>&1; then
    git rm --cached -q -- "$f" && saidos_git=$((saidos_git + 1))
  fi

  mv -- "$f" "$DESTINO/" && movidos=$((movidos + 1))
done

if ! grep -qxF "$DESTINO/" .gitignore 2>/dev/null; then
  printf '\n%s/\n' "$DESTINO" >> .gitignore
fi

msg="✔ $movidos arquivo(s) movido(s) para $DESTINO/"
[ "$pulados" -gt 0 ] && msg+="\n⚠ $pulados já existiam no destino e foram mantidos"
[ "$saidos_git" -gt 0 ] && msg+="\n\n$saidos_git saíram do controle do Git. Faça o commit com git-refactor (reorganiza)."

notify_info "$msg"