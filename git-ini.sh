#!/bin/bash
# =============================================================================
# git-ini.sh — Inicialização de projeto Git
# =============================================================================
# Prepara um repositório Git local do zero para usuários sem experiência:
#   - Instala Git se ausente (Debian/Ubuntu)
#   - Configura identidade do usuário Git se necessário
#   - Inicializa repositório com branch main
#   - Gera .gitignore básico
#   - Aplica configurações via git-config.sh
#   - Instala hooks via git-hook.sh (com core.hooksPath)
#   - Cria commit inicial com README.md
#   - Configura remote e faz push inicial (opcional)
#
# Uso: ./git-ini.sh [nome-do-projeto]
#
# Versão: 1.2.0
# Dependências: git-lib.sh, git-config.sh, git-hook.sh
# =============================================================================

source "$(dirname "$0")/git-lib.sh"

echo "🚀 Inicializando projeto"

# --- Git ---
if ! command -v git >/dev/null; then
  echo "Instalando Git..."
  sudo apt update && sudo apt install -y git
fi

# --- Identidade do usuário ---
if [ -z "$(git config --global user.name)" ]; then
  ask_required GIT_USER_NAME "Seu nome completo"
  git config --global user.name "$GIT_USER_NAME"
fi

if [ -z "$(git config --global user.email)" ]; then
  ask_required GIT_USER_EMAIL "Seu e-mail"
  git config --global user.email "$GIT_USER_EMAIL"
fi

# --- Repositório ---
if [ ! -d ".git" ]; then
  git config --global init.defaultBranch main
  git init
fi

# --- Nome do projeto ---
DEFAULT_NAME=$(basename "$PWD")
ask_required PROJECT_NAME "Nome do projeto" "${1:-$DEFAULT_NAME}"

if [[ "$PROJECT_NAME" == /* || "$PROJECT_NAME" == */* ]]; then
  echo "❌ Nome do projeto não deve ser um caminho, apenas um nome simples." >&2
  exit 1
fi

# --- .gitignore ---
if [ ! -f ".gitignore" ]; then
  cat > .gitignore <<EOF
# Binários e compilados
*.o
*.a
*.so
*.exe
*.out

# Lazarus / FPC
*.compiled
*.bak
*.lps
*.ppu
*.or
lib/

# Temporários
*.tmp
*.log
*~

# Segredos
.env
*.key
*.pem
EOF
  echo "✔ .gitignore criado"
fi

# --- Configurações do projeto ---
"$(dirname "$0")/git-config.sh" "$PROJECT_NAME" || exit 1

# --- Hooks ---
"$(dirname "$0")/git-hook.sh" || exit 1
git config core.hooksPath .githooks

# --- Commit inicial ---
echo "# $PROJECT_NAME" > README.md
git add .

echo ""
echo "Arquivos que serão incluídos no commit inicial:"
git status --short
echo ""
read -rp "Confirmar? [S/n]: " CONFIRM
[[ "$CONFIRM" =~ ^[Nn]$ ]] && exit 0

git commit -m "feat: inicialização do projeto"
git branch -M main

# --- Remote (opcional) ---
read -rp "URL do repositório remoto (Enter para pular): " REMOTE_URL
if [ -n "$REMOTE_URL" ]; then
  git remote add origin "$REMOTE_URL"
  git push -u origin main && echo "✔ Push realizado" || echo "⚠ Push falhou — verifique a URL e suas credenciais"
fi

echo "✔ Projeto pronto"