# git-tools.conf

Arquivo de configuração central do projeto git-tools. Define a lista de scripts, títulos e parâmetros usados por todos os instaladores e integradores do projeto.

**Versão:** 1.2.0  
**Localização após instalação:** `/usr/local/bin/git-tools.conf`  
**Lido por:** `git-install.sh`, `git-add-navigator-nemo.sh`, `git-add-navigator-dolphin.sh`, `git-lazarus-integrate.sh`

---

## Formato

Cada linha define um script no formato:

```
SCRIPT|TITULO_MENU|TITULO_LAZARUS|PARAMS
```

| Campo | Descrição |
|-------|-----------|
| `SCRIPT` | Nome do arquivo `.sh` a instalar |
| `TITULO_MENU` | Nome exibido no Nemo — inclui número de ordem (vazio = não aparece no menu) |
| `TITULO_LAZARUS` | Nome amigável exibido no menu Tools do Lazarus (vazio = não aparece) |
| `PARAMS` | Parâmetros passados ao script (vazio = nenhum) |

Linhas começando com `#` são comentários e são ignoradas.  
O campo `PARAMS` pode estar vazio — a linha deve terminar com `|` mesmo sem parâmetro.

---

## Arquivo

```bash
# git-tools.conf
# Formato: SCRIPT|TITULO_MENU|TITULO_LAZARUS|PARAMS

# --- Inicialização ------------------------------------------------------------
git-ini.sh|01 - Inicializar repositório (ini)|Inicializar repositório|

# --- Commits ------------------------------------------------------------------
git-feat.sh|02 - Nova funcionalidade (feat)|Adicionar funcionalidade|
git-fix.sh|03 - Correção (fix)|Corrigir problema|
git-breaking.sh|04 - Breaking change|Alteração importante|
git-refactor.sh|05 - Refatoração (refactor)|Refatorar código|
git-docs.sh|06 - Commit de documentação (docs)|Adicionar documentação|

# --- Versionamento ------------------------------------------------------------
git-version.sh|07 - Calcular próxima versão|Calcular versão|
git-version-pas-inc.sh|08 - Incrementar versão|Atualizar informações da versão para ser usada em pascal|
git-generator-lcl.sh|09 - Gerar version.inc Lazarus|Gerar versão Lazarus|

# --- Release ------------------------------------------------------------------
git-release.sh|10 - Fazer release|Gerar versão do sistema|

# --- Changelog ----------------------------------------------------------------
git-changelog.sh|11 - Gerar CHANGELOG|Git Changelog|
git-changelog-summary.sh|12 - Resumo do CHANGELOG|Git Changelog Resumo|

# --- Recuperação --------------------------------------------------------------
git-reset.sh|13 - Desfazer último commit (reset)|Git Reset|
git-undo-reset.sh|14 - Recuperar commit desfeito (undo reset)|Git Undo Reset|
```

---

## Diferença entre TITULO_MENU e TITULO_LAZARUS

O Nemo/Dolphin e o Lazarus têm convenções diferentes de apresentação:

| | Nemo / Dolphin | Lazarus |
|--|----------------|---------|
| Estilo | Numerado, técnico | Amigável, em português |
| Exemplo | `02 - Nova funcionalidade (feat)` | `Adicionar funcionalidade` |
| Ordenação | Pelo número prefixado | Pela ordem no arquivo |

---

## Como os instaladores usam este arquivo

Todos os instaladores usam a função `parse_config` da `git-lib.sh`:

```bash
parse_config "menu"    "_callback"   # filtra por TITULO_MENU não vazio
parse_config "lazarus" "_callback"   # filtra por TITULO_LAZARUS não vazio
parse_config "all"     "_callback"   # todos os scripts
```

### `git-install.sh` — instala os scripts

Copia para `/usr/local/bin` todos os scripts listados:

```bash
_install_script() {
  local script="$1"
  sudo cp "$SCRIPT_DIR/$script" "$INSTALL_DIR/$script"
  sudo chmod +x "$INSTALL_DIR/$script"
  echo "  ✔ $script"
}
parse_config "all" "_install_script"
```

### `git-add-navigator-nemo.sh` — cria wrappers no Nemo

Usa `TITULO_MENU` como nome do wrapper:

```bash
_install_wrapper() {
  local script="$1" title_menu="$2" title_laz="$3" params="$4"
  make_wrapper_git "${title_menu}.sh" "bash \"$INSTALL_DIR/$script\" $params"
}
parse_config "menu" "_install_wrapper"
```

### `git-add-navigator-dolphin.sh` — cria wrappers no Dolphin

Usa `TITULO_MENU` como nome da entrada no `.desktop`:

```bash
_install_wrapper() {
  local script="$1" title_menu="$2" title_laz="$3" params="$4"
  make_wrapper_git "$(basename $script .sh)-wrapper.sh" "$script" "$params"
}
parse_config "menu" "_install_wrapper"
```

### `git-lazarus-integrate.sh` — gera XML para o Lazarus

Usa `TITULO_LAZARUS` como título da ferramenta:

```bash
_add_tool() {
  local script="$1" title_menu="$2" title_laz="$3" params="$4"
  # gera entrada <ToolN> no XML com $title_laz
}
parse_config "lazarus" "_add_tool"
```

---

## Como adicionar um novo script

1. Crie o script seguindo o padrão do projeto
2. Adicione uma linha no `git-tools.conf`:
   ```
   git-novo.sh|15 - Meu novo script|Meu Script|
   ```
3. Execute os instaladores:
   ```bash
   ./git-install.sh
   ./git-add-navigator-nemo.sh
   ./git-add-navigator-dolphin.sh
   ./git-lazarus-integrate.sh
   ```

O novo script aparecerá automaticamente em todos os menus sem precisar editar nenhum outro arquivo.

---

## Compatibilidade

| Ambiente | Suporte |
|----------|---------|
| Linux (Bash 4.3+) | ✅ |
| macOS (Bash 5 via Homebrew) | ✅ |
| Git Bash / MSYS2 (Windows) | ✅ |
| WSL | ✅ |