#!/bin/bash
# =============================================================================
# git-lib.sh — Biblioteca utilitária para scripts Git
# =============================================================================
# Fornece funções auxiliares para:
#   - Leitura de parâmetros obrigatórios com fallback interativo
#   - Confirmação interativa padronizada (terminal ou zenity)
#   - Carregamento seguro de configurações por projeto (.gitproject)
#
# Uso: source git-lib.sh
#
# Versão: 1.2.0
# =============================================================================

_has_display() {
  [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]
}

ask_required() {
  local -n _out=$1
  local prompt="$2"
  local value="$3"

  if [ -z "$value" ]; then
    if _has_display && command -v zenity >/dev/null; then
      value=$(zenity --entry --title="Git Tools" --text="$prompt:" --width=400) || return 1
    else
      read -rp "$prompt: " value
    fi
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

  if _has_display && command -v zenity >/dev/null; then
    if zenity --question \
              --title="Git Tools" \
              --text="$prompt" \
              --ok-label="Sim" \
              --cancel-label="Não" \
              --width=380 2>/dev/null; then
      _out="s"
    else
      _out="n"
    fi
  else
    read -rp "$prompt [S/n]: " _out
    _out="${_out:-$default}"
  fi
}

load_config() {
  [ -f ".gitproject" ] || return 0
  while IFS='=' read -r key value; do
    [[ "$key" =~ ^[A-Z_]+$ ]] && export "$key=$value"
  done < .gitproject
}

notify_info() {
  local msg="$1"

  if _has_display && command -v zenity >/dev/null; then
    zenity --info \
           --title="Git Tools" \
           --text="$msg" \
           --width=400 2>/dev/null
  else
    echo -e "$msg"
  fi
}

view_file() {
  local file="$1"

  if _has_display && command -v zenity >/dev/null; then
    zenity --text-info \
           --title="$file" \
           --filename="$file" \
           --width=700 \
           --height=500 2>/dev/null
  else
    less "$file"
  fi
}

ask_select() {
  local -n _out=$1
  local title="$2"
  shift 2
  local options=("$@")

  if _has_display && command -v zenity >/dev/null; then
    _out=$(zenity --list \
      --title="Git Tools" \
      --text="$title" \
      --column="Opção" \
      "${options[@]}" \
      --height=300 --width=400 2>/dev/null) || return 1
  else
    echo "$title"
    select opt in "${options[@]}"; do
      if [ -n "$opt" ]; then
        _out="$opt"
        break
      fi
    done
  fi
}