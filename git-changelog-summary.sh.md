# `git-changelog-summary.sh` — Geração de CHANGELOG a partir dos commits Git

**Versão:** 1.3.1
**Data da versão:** 2026-10-09

## Visão geral

O `git-changelog-summary.sh` gera um CHANGELOG agrupado por tipo de commit, seguindo o padrão Conventional Commits. O resultado pode ser exibido no terminal ou salvo em `CHANGELOG.md` e, opcionalmente, em `CHANGELOG.html`.

## Pré-requisitos

- Bash.
- Um repositório Git inicializado no diretório atual (deve existir a pasta `.git`).
- `git-lib.sh` disponível em `/usr/local/bin/git-lib.sh`, com a função `ask_confirm`.
- `pandoc` — opcional, necessário apenas para gerar o `CHANGELOG.html`.

## Como utilizar

```bash
git-changelog-summary.sh [opções] [versão]
```

### Opções

| Opção | Descrição |
|---|---|
| `--write` | Salva o resultado em `CHANGELOG.md`. |
| `--html` | Salva em `CHANGELOG.md` e gera `CHANGELOG.html` (requer `pandoc`). |
| `--help` | Exibe a ajuda. |

### Argumento

- **`versão`** — tag de referência, com ou sem o prefixo `v` (ex.: `v1.2.0` ou `1.2.0`). Se omitida, lista todo o histórico.

### Exemplos

```bash
./git-changelog-summary.sh                 # exibe todo o histórico no terminal
./git-changelog-summary.sh v0.2.0          # mudanças desde a tag v0.2.0
./git-changelog-summary.sh --write         # salva em CHANGELOG.md
./git-changelog-summary.sh --html          # gera CHANGELOG.md e CHANGELOG.html
./git-changelog-summary.sh --html v0.2.0   # gera desde a tag v0.2.0
```

## Como funciona

1. Verifica se o diretório `.git` existe.
2. Lê os argumentos: `--write`, `--html`, `--help` ou uma versão.
3. Se uma versão foi informada e a tag correspondente existe, define o intervalo `vX.Y.Z..HEAD`. Caso contrário, usa todo o histórico.
4. Para cada tipo de commit reconhecido, filtra os commits e monta uma seção do changelog.
5. Commits que não se encaixam em nenhum tipo são reunidos em **Outras mudanças**.
6. Exibe o resultado no terminal ou grava em arquivo, conforme as opções.
7. Com `--write`, pergunta se o usuário deseja visualizar o arquivo e tenta abri-lo em um terminal gráfico disponível.
8. Com `--html`, gera o HTML via `pandoc`.

### Tipos de commit reconhecidos

| Prefixo | Seção |
|---|---|
| `feat!:` | ⚠ Alterações que quebram compatibilidade |
| `fix!:` | ⚠ Alterações que quebram compatibilidade |
| `feat:` | ➕ Funcionalidades |
| `fix:` | 🐛 Correções |
| `docs:` | 📚 Documentação |
| `refactor:` | ♻️ Refatoração |
| `chore:` | 🔧 Manutenção |

Commits com mensagens de bump de versão (`bump version ... para v...` ou `atualiza version.inc ... para v...`) são excluídos do changelog. Só essa forma em português é reconhecida: os commits que o `git-version.sh` atual cria (`chore: bump version to vX.Y.Z` e `chore: update <arquivos> to vX.Y.Z`) **aparecem** na seção Manutenção.

## Comportamento e segurança

- **Somente leitura no repositório:** o script não cria commits nem altera o histórico Git.
- **Sobrescrita de arquivos:** com `--write` ou `--html`, o `CHANGELOG.md` e o `CHANGELOG.html` existentes são sobrescritos sem confirmação.
- **Visualização opcional:** após gravar o `CHANGELOG.md`, o script pergunta se o usuário deseja visualizá-lo. A abertura depende de um terminal gráfico disponível (`x-terminal-emulator`, `gnome-terminal`, `konsole` ou `xfce4-terminal`).
- **`pandoc` ausente:** o `CHANGELOG.html` não é gerado, mas o `.md` é gravado normalmente.
- **Versão inexistente:** se a tag informada não existir, o script cai no modo de histórico completo, sem aviso de erro.

## Arquivos envolvidos

- `CHANGELOG.md` — criado ou sobrescrito com `--write` ou `--html`.
- `CHANGELOG.html` — criado ou sobrescrito com `--html`, se o `pandoc` estiver disponível.
- `git-lib.sh` — biblioteca externa, exigida em `/usr/local/bin/`.

## Solução de problemas

- **`❌ Nenhum repositório Git encontrado`** — execute o script dentro de um repositório Git inicializado.
- **`⚠ pandoc não encontrado`** — instale o `pandoc` para gerar o HTML, ou use apenas `--write`.
- **`⚠ Nenhum terminal gráfico encontrado`** — o `CHANGELOG.md` foi gravado, mas não pôde ser aberto automaticamente. Abra-o manualmente.
- **Seções ausentes no HTML** — a versão 1.3.1 corrige problemas de formatação que afetavam a geração dos títulos pelo `pandoc`. Verifique se está usando essa versão.
- **Tag não reconhecida** — confirme se a tag existe no repositório (`git tag`). Se não existir, o script gera o histórico completo.
- **Commits `bump version to v...` na seção Manutenção** — o filtro só reconhece a forma `para v`. Eles são esperados com o `git-version.sh` atual.