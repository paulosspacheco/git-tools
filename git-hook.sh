#!/bin/bash
# =============================================================================
# git-hook.sh — Instalação de hooks Git do projeto
# =============================================================================
# Instala o hook commit-msg que valida o formato das mensagens de commit
# seguindo o padrão Conventional Commits:
#   fix:, feat:, feat!:, docs:, chore:, refactor:, test:, style:
#
# Uso: ./git-hook.sh
#
# Data da versão: 2026-10-09
# Versão: 1.1.0
# Objetivo da versão: gravar o hook em .githooks/commit-msg e definir
#   core.hooksPath, para que a validação de fato execute (antes ficava em
#   .git/hooks, ignorado quando core.hooksPath aponta para .githooks).
# Observações:
#   - Executar na raiz do repositório
#   - .githooks/ é versionada: quem clonar o projeto recebe o hook, mas precisa
#     rodar este script (ou git config core.hooksPath .githooks) uma vez
#   - Sobrescreve .githooks/commit-msg se já existir
# Dependências: repositório Git inicializado (.git)
# =============================================================================

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

HOOK_DIR=".githooks"
HOOK="$HOOK_DIR/commit-msg"

mkdir -p "$HOOK_DIR" || exit 1

cat > "$HOOK" <<'EOF'
#!/bin/bash
MSG=$(cat "$1")
if [[ "$MSG" =~ ^(feat|feat!|fix|docs|chore|refactor|test|style): ]]; then
  exit 0
else
  echo "❌ Mensagem de commit inválida!"
  echo "   Use um dos prefixos: feat:, fix:, docs:, chore:, refactor:, test:, style:, feat!:"
  echo "   Exemplo: feat: adiciona tela de login"
  exit 1
fi
EOF

chmod +x "$HOOK"
git config core.hooksPath "$HOOK_DIR"
echo "✔ Hook instalado em $HOOK"