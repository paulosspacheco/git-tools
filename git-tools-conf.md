# `git-tools.conf` — Lista de scripts e menus do git-tools

**Versão:** 1.3.0  
**Data:** 2026-10-08

## Visão geral

O `git-tools.conf` define quais scripts o git-tools instala e como cada um aparece nos aliases do terminal, no menu do gerenciador de arquivos e no menu **Tools** do Lazarus. Para incluir ou retirar um comando, basta editar este arquivo e rodar o instalador de novo.

## Formato

Cada linha descreve um script, com campos separados por `|`:

```text
SCRIPT | TITULO_MENU | TITULO_LAZARUS | PARAMS
```

| Campo | Uso |
|-------|-----|
| `SCRIPT` | Arquivo `.sh` que será copiado para `/usr/local/bin` |
| `TITULO_MENU` | Texto no menu do gerenciador de arquivos. Vazio: não aparece lá |
| `TITULO_LAZARUS` | Texto no menu **Tools** do Lazarus. Vazio: não aparece lá |
| `PARAMS` | Parâmetros passados ao script. Pode ficar vazio |

Regras:

- Linhas iniciadas por `#` e linhas em branco são ignoradas.
- Espaços ao redor dos campos são descartados.
- Mantenha o `|` final, como nas linhas existentes, mesmo com `PARAMS` vazio.
- Não use `/` nos títulos: eles viram nome de arquivo nos menus.
- Um alias só é criado para linhas que tenham pelo menos um dos dois títulos.

O prefixo numérico do `TITULO_MENU` (`01 - `, `02 - `...) é só uma convenção de ordem. O Nemo o oculta na lista exibida.

## Scripts configurados

| Nº | Script | Título no menu | Parâmetros |
|----|--------|----------------|------------|
| 01 | `git-ini.sh` | Inicializar repositório (ini) | — |
| 02 | `git-feat.sh` | Nova funcionalidade (feat) | — |
| 03 | `git-fix.sh` | Correção (fix) | — |
| 04 | `git-breaking.sh` | Breaking change | — |
| 05 | `git-refactor.sh` | Refatoração (refactor) | — |
| 06 | `git-docs.sh` | Commit de documentação (docs) | — |
| 07 | `git-version.sh` | Calcular próxima versão | — |
| 08 | `git-release.sh` | Fazer release | — |
| 09 | `git-changelog.sh` | Gerar CHANGELOG | — |
| 10 | `git-changelog-summary.sh` | Resumo do CHANGELOG-html | `--html` |
| 11 | `git-reset.sh` | Desfazer último commit (reset) | — |
| 12 | `git-undo-reset.sh` | Recuperar commit desfeito (undo reset) | — |
| 13 | `git-github.sh` | Enviar ou atualizar no GitHub (github) | — |

Os títulos do Lazarus são versões em português corrido dos títulos de menu, sem o número.

## Quem usa este arquivo

| Programa | O que faz com ele |
|----------|-------------------|
| `git-install.sh` | Copia todos os scripts listados, cria os aliases no `~/.bashrc` e gera o XML do Lazarus |
| `git-add-navigator-nemo.sh`, `git-add-navigator-nautilus.sh`, `git-add-navigator-dolphin.sh` | Montam o menu **Git Tools** com as linhas que têm `TITULO_MENU` |
| `git-uninstall.sh` | Descobre quais scripts remover de `/usr/local/bin` |

O `git-lazarus-integrate.sh` **não** lê este arquivo: ele tem uma lista própria de ferramentas.

## Como funciona

- Os aliases têm o nome do script sem `.sh`, e levam os `PARAMS` da linha. Exemplo: `git-changelog-summary` equivale a `bash /usr/local/bin/git-changelog-summary.sh --html`.
- Os menus do gerenciador de arquivos também executam o script com os `PARAMS`.
- Os menus e o desinstalador leem a cópia instalada em `/usr/local/bin/git-tools.conf`, não a da pasta do repositório.

## Como adicionar um script

1. Coloque o arquivo `.sh` na pasta do repositório, junto do `git-install.sh`.
2. Acrescente uma linha ao `git-tools.conf`:

   ```text
   git-novo.sh | 14 - Meu novo script | Meu novo script |
   ```

3. Rode o instalador como usuário comum, sem `sudo`:

   ```bash
   bash git-install.sh
   source ~/.bashrc
   ```

O novo comando passa a aparecer nos aliases, nos menus e no XML do Lazarus. O XML precisa ser importado de novo no Lazarus.

## Comportamento e segurança

- **Cópia instalada:** a cada instalação, `/usr/local/bin/git-tools.conf` é sobrescrito pela cópia do repositório. Alterações feitas direto na cópia instalada se perdem.
- **Arquivo ausente:** se um script listado não existir na pasta do repositório, a instalação para com erro.
- **Scripts fora da lista:** um `.sh` que não esteja neste arquivo (nem entre os arquivos auxiliares do instalador, como `git-lib.sh` e `git-config.sh`) não é instalado.
- **Remoção de linha:** retirar uma linha não apaga o script já instalado em `/usr/local/bin`. O alias e o menu só desaparecem na próxima instalação.

## Arquivos envolvidos

- `git-tools.conf` — este arquivo, na pasta do repositório.
- `/usr/local/bin/git-tools.conf` — cópia instalada.
- `~/.bashrc` — recebe os aliases.
- `lazarus.git-tools.xml` — gerado na pasta do repositório.