#!/bin/bash
# =============================================================================
# git-ini.sh — Inicialização de repositório Git (idempotente)
# =============================================================================
# Prepara um repositório Git local do zero, mas é seguro executar múltiplas vezes:
#   - Não sobrescreve .gitignore, README.md ou arquivos de configuração existentes
#   - Não cria commits vazios
#   - Não duplica remotos
#
# Uso: ./git-ini.sh [nome-do-projeto]
# Data da versão: 2026-10-09
# Versão: 1.4.2 (idempotente)
# Objetivo da versão: o hook commit-msg passa a ser instalado em .githooks pelo
#   git-hook.sh; projetos que já tinham core.hooksPath=.githooks sem o hook
#   recebem o hook ao rodar o git-ini de novo.
# =============================================================================

source "$(dirname "$0")/git-lib.sh"

# -----------------------------------------------------------------------------
# Verificação inicial do Git
# -----------------------------------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
    notify_info "❌ Git não encontrado.\nInstale o Git e tente novamente."
    exit 1
fi

echo "🚀 Inicializando projeto Git..."

# -----------------------------------------------------------------------------
# Configura identidade do usuário (idempotente: só define se não existir)
# -----------------------------------------------------------------------------
if [ -z "$(git config --global user.name)" ]; then
    ask_required GIT_USER_NAME "Seu nome completo (para os commits)"
    git config --global user.name "$GIT_USER_NAME"
fi

if [ -z "$(git config --global user.email)" ]; then
    ask_required GIT_USER_EMAIL "Seu e-mail (para os commits)"
    git config --global user.email "$GIT_USER_EMAIL"
fi

# -----------------------------------------------------------------------------
# Inicializa o repositório (idempotente)
# -----------------------------------------------------------------------------
if [ ! -d ".git" ]; then
    git config --global init.defaultBranch main
    git init
    echo "✔ Repositório Git inicializado (branch main)"
else
    echo "ℹ Repositório já existe, reutilizando..."
fi

# -----------------------------------------------------------------------------
# Nome do projeto (usa argumento ou nome da pasta atual)
# -----------------------------------------------------------------------------
DEFAULT_NAME=$(basename "$PWD")
if [ -n "$1" ]; then
    PROJECT_NAME="$1"
else
    ask_required PROJECT_NAME "Nome do projeto (apenas letras, números, hífens ou underscores)" "$DEFAULT_NAME"
fi

if [[ "$PROJECT_NAME" == */* ]] || [[ "$PROJECT_NAME" == *\\* ]]; then
    notify_info "❌ Nome do projeto não deve conter barras. Use apenas um nome simples."
    exit 1
fi

# -----------------------------------------------------------------------------
# Cria .gitignore APENAS se não existir (idempotente)
# -----------------------------------------------------------------------------
if [ ! -f ".gitignore" ]; then
    cat > .gitignore <<'EOF'
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
else
    echo "ℹ .gitignore já existe, mantido"
fi

# -----------------------------------------------------------------------------
# Cria README.md APENAS se não existir (idempotente)
# -----------------------------------------------------------------------------
if [ ! -f "README.md" ]; then
    echo "# $PROJECT_NAME" > README.md
    echo "✔ README.md criado"
else
    echo "ℹ README.md já existe, mantido"
fi

# -----------------------------------------------------------------------------
# Executa git-config.sh (idempotente via marker em .git/)
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(dirname "$0")"
if [ -f "$SCRIPT_DIR/git-config.sh" ]; then
    if [ ! -f ".git/git-tools-configured" ]; then
        bash "$SCRIPT_DIR/git-config.sh" "$PROJECT_NAME" || exit 1
        touch ".git/git-tools-configured"
    else
        echo "ℹ git-config.sh já executado, ignorado"
    fi
else
    echo "⚠ git-config.sh não encontrado – configurações adicionais ignoradas"
fi

# -----------------------------------------------------------------------------
# Executa git-hook.sh (idempotente: só instala se o hook ainda não estiver ativo)
# -----------------------------------------------------------------------------
if [ -f "$SCRIPT_DIR/git-hook.sh" ]; then
    if [ "$(git config core.hooksPath)" != ".githooks" ] || [ ! -x ".githooks/commit-msg" ]; then
        bash "$SCRIPT_DIR/git-hook.sh" || exit 1
    else
        echo "ℹ Hooks já instalados, ignorados"
    fi
else
    echo "⚠ git-hook.sh não encontrado – hooks não instalados"
fi

# -----------------------------------------------------------------------------
# Adiciona arquivos e cria commit inicial SOMENTE se houver mudanças e não houver commits
# -----------------------------------------------------------------------------
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    git add .
    if git diff --cached --quiet; then
        echo "ℹ Nenhuma alteração para commitar."
    else
        echo ""
        echo "📁 Arquivos que serão incluídos no commit inicial:"
        git status --short
        echo ""

        ask_confirm CONFIRM "Confirmar criação do commit inicial?"
        if [ "$CONFIRM" = "s" ]; then
            git commit -m "feat: inicialização do projeto $PROJECT_NAME"
            git branch -M main
            echo "✔ Commit inicial realizado"
        else
            notify_info "❌ Commit inicial cancelado pelo usuário"
            exit 0
        fi
    fi
else
    echo "ℹ Repositório já possui commits. Nenhum commit inicial criado."
fi

# -----------------------------------------------------------------------------
# Configura remote e push (idempotente: só adiciona se não existir)
# -----------------------------------------------------------------------------
ask_optional REMOTE_URL "URL do repositório remoto (deixe em branco para pular)"
if [ -n "$REMOTE_URL" ]; then
    if git remote | grep -q "^origin$"; then
        echo "ℹ Remote 'origin' já existe. Atualizando URL..."
        git remote set-url origin "$REMOTE_URL"
    else
        git remote add origin "$REMOTE_URL"
    fi
    echo "🔄 Executando push para o remoto..."
    if git push -u origin main 2>/dev/null; then
        notify_info "✔ Push realizado com sucesso!"
    else
        notify_info "⚠ Falha no push. Verifique a URL e suas credenciais."
    fi
fi

notify_info "✔ Projeto $PROJECT_NAME inicializado com sucesso!"