#!/bin/bash
# =============================================================================
# git-lib.sh — Biblioteca utilitária para scripts Git
# =============================================================================
# Fornece funções auxiliares para:
#   - Leitura de parâmetros obrigatórios com fallback interativo
#   - Confirmação interativa padronizada
#   - Carregamento seguro de configurações por projeto (.gitproject)
#
# Uso: source git-lib.sh
#
# Versão: 1.1.0
# =============================================================================

ask_required() {
  local -n _out=$1
  local prompt="$2"
  local value="$3"

  if [ -z "$value" ]; then
    read -rp "$prompt: " value
  fi

  if [ -z "$value" ]; then
    echo "❌ Valor obrigatório" >&2
    return 1
  fi

  _out="$value"
}

ask_confirm() {
  local -n _out=$1
  local prompt="$2"
  local default="${3:-s}"

  read -rp "$prompt [S/n]: " _out
  _out="${_out:-$default}"
}

load_config() {
  [ -f ".gitproject" ] || return 0
  while IFS='=' read -r key value; do
    [[ "$key" =~ ^[A-Z_]+$ ]] && export "$key=$value"
  done < .gitproject
}