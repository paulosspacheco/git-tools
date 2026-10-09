# git-tools

Conjunto de scripts Bash que simplifica o uso do Git. Cada operação (commit de funcionalidade, correção, release, changelog, reset) vira um comando curto que pergunta o necessário, monta a mensagem no padrão [Conventional Commits](https://www.conventionalcommits.org/) e calcula a versão ([SemVer](https://semver.org/)) a partir dos commits.

Os comandos funcionam no terminal, com diálogos gráficos (Zenity) quando há ambiente gráfico, a partir do menu de contexto do gerenciador de arquivos (Nemo, Nautilus ou Dolphin) e a partir do menu **Tools** do Lazarus.

> Este documento descreve o que os scripts fazem hoje. Se algum outro `.md` do repositório divergir, vale o código.

---

## Requisitos

- Linux com Bash 4.3 ou superior (a biblioteca usa `local -n`)
- Git instalado (o instalador e o `git-ini` não instalam o Git)
- `sudo`, pois os scripts são copiados para `/usr/local/bin`
- Opcionais: `zenity` (diálogos gráficos), `konsole` (integração com o Dolphin)

Sem ambiente gráfico ou sem `zenity`, todos os scripts usam perguntas no terminal.

---

## Instalação

```bash
git clone https://github.com/paulosspacheco/git-tools.git
cd git-tools
bash git-install.sh
source ~/.bashrc
```

Não use `sudo bash git-install.sh` nem execute como root: o instalador recusa e pede `sudo` sozinho nos pontos necessários.

O `git-install.sh` executa, nesta ordem:

1. Copia para `/usr/local/bin` os arquivos auxiliares (`git-lib.sh`, `git-config.sh`, `git-hook.sh`, `git-add-navigator-*.sh`, `git-tools.conf`) e todos os scripts listados no `git-tools.conf`. Se algum arquivo listado não existir na pasta, a instalação para com erro.
2. Gera `lazarus.git-tools.xml` na pasta do repositório.
3. Mostra como importar esse XML no Lazarus (a importação é manual).
4. Pede `user.name` e `user.email` globais do Git, caso ainda não existam.
5. Grava os aliases no `~/.bashrc`.
6. Executa a integração com os gerenciadores de arquivos encontrados.

### Desinstalação

Execute a partir da pasta do repositório:

```bash
bash git-uninstall.sh
```

Remove os scripts de `/usr/local/bin`, o XML do Lazarus, os aliases e os menus dos gerenciadores de arquivos. Veja os [pontos de atenção](#pontos-de-atenção) antes de usar.

---

## `git-tools.conf`

Define quais scripts são instalados e como aparecem nos menus. Cada linha tem o formato:

```
SCRIPT|TITULO_MENU|TITULO_LAZARUS|PARAMS
```

| Campo | Uso |
|-------|-----|
| `SCRIPT` | Arquivo `.sh` copiado para `/usr/local/bin` |
| `TITULO_MENU` | Texto no menu do gerenciador de arquivos. Vazio: não aparece lá |
| `TITULO_LAZARUS` | Texto no menu Tools do Lazarus. Vazio: não aparece lá |
| `PARAMS` | Parâmetros passados ao script (pode ficar vazio) |

Linhas iniciadas por `#` são ignoradas. Um alias só é criado para linhas que tenham pelo menos um dos dois títulos.

Para incluir um novo script: crie o arquivo, acrescente uma linha ao `git-tools.conf` e rode `git-install.sh` de novo.

---

## Uso

```bash
cd /meu/projeto
git-ini                          # prepara o repositório
git-feat "adiciona tela de login"
git-fix "corrige validação de senha"
git-release                      # calcula a versão, cria a tag
```

Os comandos abaixo existem como scripts no repositório. Os que viram alias e item de menu são os listados no `git-tools.conf`. Os aliases têm o formato `alias git-feat='bash "/usr/local/bin/git-feat.sh"'`.

### Commits

Os cinco scripts de commit seguem o mesmo roteiro:

1. Exigem um repositório Git na pasta atual.
2. Pedem o tipo de ação (lista no Zenity ou menu numerado no terminal), mesmo quando a mensagem é passada como argumento.
3. Usam a mensagem do argumento ou perguntam.
4. Montam `tipo: ação : mensagem` e pedem confirmação.
5. Executam `git add .` e `git commit`.

Como usam `git add .`, **todos os arquivos modificados e novos** da pasta entram no commit, exceto os ignorados pelo `.gitignore`.

| Script | Prefixo | Ações oferecidas | Efeito na versão |
|--------|---------|------------------|------------------|
| `git-feat.sh` | `feat:` | adiciona, implementa, integra, refatora | MINOR |
| `git-fix.sh` | `fix:` | corrige, ajusta, resolve, melhora | PATCH |
| `git-breaking.sh` | `feat!:` | remove, altera, renomeia, reestrutura | MAJOR |
| `git-refactor.sh` | `refactor:` | reorganiza, extrai, simplifica, renomeia | nenhum |
| `git-docs.sh` | `docs:` | adiciona, atualiza, corrige, remove, reorganiza | nenhum |

Exemplo de mensagem gerada: `feat: adiciona : tela de login`.

### `git-ini`

Prepara o projeto na pasta atual e pode ser executado várias vezes sem sobrescrever o que já existe:

- Exige o Git instalado.
- Define `user.name` e `user.email` globais se estiverem vazios.
- Roda `git init` com `init.defaultBranch main` (global), se ainda não houver `.git`.
- Usa o argumento ou pergunta o nome do projeto (sugere o nome da pasta; não aceita barras).
- Cria `.gitignore` (binários, arquivos Lazarus/FPC, temporários, segredos) e `README.md` (`# nome`), só se não existirem.
- Roda `git-config.sh`, que grava `.gitproject` com `PROJECT_NAME` e `VERSION=0.1.0`.
- Roda `git-hook.sh` e define `core.hooksPath` como `.githooks`.
- Se o repositório não tem commits, mostra os arquivos, pede confirmação e cria o commit `feat: inicialização do projeto <nome>`.
- Pergunta a URL do remoto; se informada, configura `origin` e faz `git push -u origin main`.

### Versão e release

**`git-version`** lê os commits desde a última tag `vX.Y.Z` (ou todos, se não houver tag), partindo da versão da tag ou do `VERSION` do `.gitproject`:

| Commit | Efeito |
|--------|--------|
| contém `feat!` | MAJOR (`1.4.2` → `2.0.0`) |
| começa com `feat:` | MINOR (`1.4.2` → `1.5.0`) |
| começa com `fix:` | PATCH (`1.4.2` → `1.4.3`) |
| outros tipos | não alteram |

Vale o maior nível encontrado. Depois de confirmar, o script atualiza o `VERSION` no `.gitproject`, cria o commit `chore: bump version to vX.Y.Z`, cria a tag `vX.Y.Z` e gera o `version-pas.inc`. Sem commits novos ou sem `feat`/`fix`, mantém a versão e apenas regenera o `version-pas.inc`.

**`version-pas.inc`**, gerado na pasta atual e commitado como `chore: update version-pas.inc to vX.Y.Z` quando muda:

```pascal
const
  VERSION_STR = '0.1.0';
  BUILD_DATE  = '2026-01-01 12:00:00';
```

Em projetos Lazarus/Free Pascal ele pode ser incluído com `{$I version-pas.inc}`.

**`git-release`** executa o `git-version.sh` e exibe a mensagem de sucesso com a versão. Quando não há ambiente gráfico, aguarda Enter.

### Changelog

| Script | O que faz |
|--------|-----------|
| `git-changelog.sh [-s DATA]` | Agrupa os commits por versão (tags `vX.Y.Z`) e exibe no Zenity ou no `less`. Sem argumento, pergunta a data inicial (`YYYY-MM-DD`); em branco mostra tudo |
| `git-changelog-summary.sh [--write] [versão]` | Agrupa por tipo (quebras de compatibilidade, funcionalidades, correções, documentação, refatoração, manutenção, outras). Sem opções imprime no terminal; `--write` salva `CHANGELOG.md`. O argumento `versão` (ex.: `v1.2.0`) limita às mudanças desde essa tag |

### Desfazer

| Script | O que faz |
|--------|-----------|
| `git-reset.sh` | Avisa e pede confirmação; executa `git reset --hard HEAD~1`, descartando o último commit e as alterações não commitadas. Se o commit removido era `chore: bump version...`, oferece apagar a tag mais recente |
| `git-undo-reset.sh` | Lista os 15 últimos itens do `reflog`, pergunta a posição (padrão `1`), confirma e executa `git reset --hard HEAD@{N}`. Depois, se a tag `v<VERSION do .gitproject>` não existir, oferece recriá-la |

Arquivos que nunca foram commitados não são recuperáveis por nenhum dos dois.

### Hook de commit

`git-hook.sh` grava `.git/hooks/commit-msg`, que só aceita mensagens começando por `feat:`, `feat!:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:` ou `style:`. Veja o [ponto de atenção](#pontos-de-atenção) sobre quando ele é de fato executado.

---

## Integrações

### Gerenciadores de arquivos

O instalador procura `nemo`, `nautilus` e `dolphin` e executa o script de integração de cada um que encontrar. Todos criam o menu a partir das entradas do `git-tools.conf` que têm `TITULO_MENU`. Em pastas que não são repositórios, os menus oferecem inicializar (`git-ini`) antes de executar o comando.

| Gerenciador | Script | Resultado |
|-------------|--------|-----------|
| Nemo | `git-add-navigator-nemo.sh` | Cria `~/.local/share/nemo/scripts/Git Tools.sh`, que abre uma lista no Zenity com os comandos. Acesso: botão direito → Scripts → Git Tools. Instala `zenity` e `git` via `apt` se faltarem |
| Nautilus | `git-add-navigator-nautilus.sh` | Cria a pasta `~/.local/share/nautilus/scripts/Git Tools/` com um script por comando. Acesso: botão direito → Scripts → Git Tools |
| Dolphin | `git-add-navigator-dolphin.sh` | Cria wrappers em `~/.local/share/git-tools/` e o menu de serviço `~/.local/share/kio/servicemenus/git-tools.desktop` (submenu **Git Tools**). Executa os comandos no `konsole`. Instala `zenity`, `git` e `konsole` via `apt` se faltarem |

`git-remove-navigator-nemo.sh` remove apenas a integração do Nemo. Os outros menus saem pelo `git-uninstall.sh`.

### Lazarus

O `git-install.sh` gera `lazarus.git-tools.xml` com as entradas do `git-tools.conf` que têm `TITULO_LAZARUS` (diretório de trabalho `$ProjPath()`). Para importar:

1. **Tools → Configure External Tools...**
2. **Import** e escolha o XML
3. **OK** e reinicie o Lazarus

`git-lazarus-integrate.sh` é um script avulso, não usado pelo instalador. Ele tem lista própria de ferramentas (não lê o `git-tools.conf`) e pode exportar o XML (`--export`) ou editar o `environmentoptions.xml` diretamente, com backup `.bak`.

---

## Arquivos do projeto

### Gerados nos projetos que usam o git-tools

```
meu-projeto/
├── .git/
├── .gitignore         # criado pelo git-ini se não existir
├── .gitproject        # PROJECT_NAME e VERSION
├── README.md          # criado pelo git-ini se não existir
└── version-pas.inc    # gerado pelo git-version / git-release
```

### Neste repositório

| Arquivo | Papel |
|---------|-------|
| `git-lib.sh` | Biblioteca carregada pelos demais scripts: `ask_required`, `ask_optional`, `ask_confirm`, `ask_select`, `notify_info`, `view_file`, `load_config`, `parse_config`. Usa Zenity ou terminal conforme o ambiente |
| `git-tools.conf` | Lista de scripts, títulos de menu e parâmetros |
| `git-install.sh`, `git-uninstall.sh` | Instalação e remoção |
| `git-add-navigator-*.sh`, `git-remove-navigator-nemo.sh` | Integração com gerenciadores de arquivos |
| `git-lazarus-integrate.sh` | Integração avulsa com o Lazarus |
| `git-lib-test.sh` | Pede `REPO` e `BRANCH` usando a biblioteca, para testar as funções de leitura |
| `test-version.sh`, `check-timeline.sh` | Scripts de diagnóstico que imprimem informações de commits e tags (referências fixas à tag `v0.14.3`) |

Os scripts que carregam `/usr/local/bin/git-lib.sh` (commits, `git-version`, `git-reset`, `git-undo-reset`, changelogs) só funcionam depois da instalação. `git-ini`, `git-config` e `git-release` carregam a biblioteca da própria pasta.

---

## Pontos de atenção

- **Hook de commit.** O `git-ini` roda o `git-hook.sh`, que grava em `.git/hooks/commit-msg`, e em seguida define `core.hooksPath` como `.githooks`. Nenhum script cria a pasta `.githooks`; com `core.hooksPath` definido o Git ignora `.git/hooks`, então a validação não roda nos projetos criados pelo `git-ini`. Para ativar em um projeto: `mkdir -p .githooks && cp .git/hooks/commit-msg .githooks/`.
- **`git add .`.** Os scripts de commit incluem tudo o que não estiver no `.gitignore`. Confira o `git status` antes de confirmar.
- **`git-reset`.** Usa `--hard`: alterações não commitadas são perdidas.
- **Desinstalação.**
  - Se não houver backup `environmentoptions.xml.bak`, o bloco `<ExternalTools>` inteiro do Lazarus é removido, inclusive ferramentas externas que não são do git-tools.
  - Do `~/.bashrc`, além do bloco do git-tools, são apagadas todas as linhas que começam com `alias git-` (um backup fica em `~/.bashrc.bak-uninstall`).

---

## Público e direção do projeto

Esta seção registra decisões de planejamento. Não descreve o comportamento atual dos scripts.

### Público

O git-tools não é só para quem programa. Ele serve a qualquer pessoa que mantém documentos, textos e páginas HTML e quer guardar cada versão do próprio trabalho, voltar a uma versão antiga e saber o que mudou e quando. Na divulgação (canção, descrição do vídeo), a mensagem deve falar em "trabalho" e "projeto", não em "código".

Limites a respeitar na divulgação:

- Arquivos de texto (Markdown, HTML, `.txt`) funcionam melhor. Arquivos Word, LibreOffice e PDF são versionados por inteiro, sem mostrar o que mudou dentro deles.
- Usar uma pasta por projeto. Os comandos de commit usam `git add .`, então não convém criar o repositório na pasta Documentos inteira.
- Hoje o `git-release` gera `version-pas.inc` em qualquer pasta. Para quem não usa Pascal isso é ruído; a ideia é gerar o arquivo só em projetos Pascal.

### Plataforma

O foco é **Linux**, que é o que já está feito. Windows e macOS ficam fora do escopo por enquanto. A divulgação deve dizer que o projeto é para Linux.

### Instalador gráfico (planejado)

Criar em Lazarus, como o instalador do CopyTo, um instalador com janelas para substituir o `bash git-install.sh`, que é o único passo que exige terminal. Ele deve fazer o mesmo que o `git-install.sh` faz hoje: copiar os scripts, configurar `user.name` e `user.email` do Git, criar os aliases, ligar o menu do gerenciador de arquivos e gerar o XML do Lazarus. Ponto a resolver: a permissão de administrador para gravar em `/usr/local/bin`, que hoje vem do `sudo` do script.

---

## Licença

Distribuído sob a licença MIT. O texto completo está no arquivo `LICENSE`, na raiz do repositório.