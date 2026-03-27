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
# Versão: 1.0.0
# Dependências: repositório Git inicializado (.git)
# =============================================================================

if [ ! -d ".git" ]; then
  echo "❌ Nenhum repositório Git encontrado. Execute git-ini.sh primeiro." >&2
  exit 1
fi

HOOK=".git/hooks/commit-msg"

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
echo "✔ Hook instalado"