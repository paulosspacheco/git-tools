#!/bin/bash
# =============================================================================
# git-version.sh — Atualização automática de versão do projeto + Pascal
# =============================================================================

# =============================================================================
# CORREÇÃO PARA NEMO/NAUTILUS/DOLPHIN - Propagar variáveis de display
# =============================================================================
# Garante que zenity funcione quando executado por gerenciadores de arquivos
export DISPLAY="${DISPLAY:-:0}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Se ainda assim não funcionar, tenta usar o display padrão
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0
fi
# =============================================================================

source "/usr/local/bin/git-lib.sh"
load_config

# =============================================================================
# Função para gerar version-pas.inc (incorporada do version-pas-inc.sh)
# =============================================================================
generate_pas_inc() {
  local version="$1"
  local build_date=$(date "+%Y-%m-%d %H:%M:%S")
  
  echo ""
  echo "🔧 Gerando version-pas.inc para Pascal/Lazarus..."
  
  # Gera o arquivo
  cat > version-pas.inc <<EOF
const
  VERSION_STR = '$version';
  BUILD_DATE  = '$build_date';
EOF
  
  # Adiciona ao Git se o arquivo existir
  if [ -f version-pas.inc ]; then
    git add version-pas.inc
    
    # Verifica se houve mudança antes de commitar
    if ! git diff --cached --quiet version-pas.inc; then
      if git commit -m "chore: update version-pas.inc to v$version"; then
        echo "  ✔ version-pas.inc gerado e commitado"
      else
        echo "  ⚠ Falha no commit do version-pas.inc"
      fi
    else
      echo "  ℹ version-pas.inc já está atualizado"
    fi
  else
    echo "  ⚠ version-pas.inc gerado mas não adicionado ao Git"
  fi
  
  echo "     Versão: $version"
  echo "     Data:   $build_date"
}

# =============================================================================
# Script principal
# =============================================================================

if [ ! -d ".git" ]; then
  # Usar notify_error se disponível, ou zenity diretamente
  if command -v zenity >/dev/null 2>&1; then
    zenity --error --title="Git Tools" --text="Nenhum repositório Git encontrado.\n\nExecute git-ini.sh primeiro." --width=380
  else
    echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  fi
  exit 1
fi

if [ -z "$VERSION" ]; then
  if command -v zenity >/dev/null 2>&1; then
    zenity --error --title="Git Tools" --text="VERSION não definida em .gitproject" --width=380
  else
    notify_info "❌ VERSION não definida em .gitproject"
  fi
  exit 1
fi

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LAST_TAG" ]; then
  notify_info "ℹ Nenhuma tag encontrada — analisando todos os commits"
  COMMITS=$(git log --pretty=format:"%s" 2>/dev/null)
  IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
else
  COMMITS=$(git log "${LAST_TAG}..HEAD" --pretty=format:"%s" 2>/dev/null)
  IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_TAG#v}"
fi

if [ -z "$COMMITS" ]; then
  notify_info "⚠ Nenhum commit novo desde v$VERSION — versão mantida"
  generate_pas_inc "$VERSION"
  exit 0
fi

BUMP_MAJOR=0
BUMP_MINOR=0
BUMP_PATCH=0

while read -r line; do
  if [[ "$line" == *"feat!"* ]]; then
    BUMP_MAJOR=1
  elif [[ "$line" == feat:* ]]; then
    BUMP_MINOR=1
  elif [[ "$line" == fix:* ]]; then
    BUMP_PATCH=1
  fi
done <<< "$COMMITS"

if [ $BUMP_MAJOR -eq 1 ]; then
  ((MAJOR++)); MINOR=0; PATCH=0
elif [ $BUMP_MINOR -eq 1 ]; then
  ((MINOR++)); PATCH=0
elif [ $BUMP_PATCH -eq 1 ]; then
  ((PATCH++))
else
  notify_info "⚠ Nenhum commit relevante (feat/fix) — versão mantida: $MAJOR.$MINOR.$PATCH"
  generate_pas_inc "$VERSION"
  exit 0
fi

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Confirma - Usa zenity diretamente para garantir que funcione no Nemo
if command -v zenity >/dev/null 2>&1; then
  zenity --question \
    --title="Git Tools" \
    --text="Confirma a atualização de versão?\n\nv$VERSION → v$NEW_VERSION" \
    --ok-label="Confirmar" \
    --cancel-label="Cancelar" \
    --width=380 || exit 0
else
  ask_confirm CONFIRM "Confirma a atualização de versão?\n\nv$VERSION → v$NEW_VERSION"
  if [ "$CONFIRM" != "s" ]; then
    notify_info "❌ Atualização cancelada"
    exit 0
  fi
fi

# Atualiza .gitproject
sed -i "s/^VERSION=.*/VERSION=$NEW_VERSION/" .gitproject
git add .gitproject
git commit -m "chore: bump version to v$NEW_VERSION"
git tag "v$NEW_VERSION"

# Gera o arquivo version-pas.inc com a nova versão
generate_pas_inc "$NEW_VERSION"

# Mensagem final - com zenity para GUI
if command -v zenity >/dev/null 2>&1; then
  zenity --info \
    --title="Git Tools" \
    --text="✔ Versão atualizada com sucesso!\n\nv$VERSION → v$NEW_VERSION\n\ne também gerado:\nversion-pas.inc" \
    --width=380
else
  notify_info "✔ Versão atualizada: v$VERSION → v$NEW_VERSION"
fi