# `git-add-navigator-nemo.sh` — Integração git-tools no Nemo

- **Data da versão:** 2026-10-14
- **Versão:** 4.0.0
- **Objetivo da versão:** o item **Git Tools** aparece direto no menu de contexto do Nemo (Nemo Action), sem passar pelo submenu **Scripts**
- **Observações:** a versão acompanha a do `git-add-navigator-nemo.sh`; se este texto divergir do código, vale o código

## Visão geral

O `git-add-navigator-nemo.sh` instala a integração das ferramentas `git-tools` no gerenciador de arquivos Nemo. Ele cria uma Nemo Action que adiciona o item **Git Tools** ao menu de contexto do Nemo, reunindo todas as operações Git disponíveis em um só lugar.

Após a instalação, o usuário pode clicar com o botão direito numa pasta, num arquivo ou no fundo da pasta aberta, escolher **Git Tools** e selecionar a operação desejada.

## Pré-requisitos

- Nemo instalado (gerenciador de arquivos do Cinnamon).
- `zenity` e `git` — se ausentes, o script tenta instalá-los via `apt`.
- O arquivo de configuração `git-tools.conf` em `/usr/local/bin/`, gerado previamente pelo `git-install.sh`.
- Permissão de `sudo` para instalar dependências ausentes.

## Como utilizar

```bash
./git-add-navigator-nemo.sh
```

O script não aceita parâmetros. Deve ser executado uma vez para instalar a integração.

Após a execução, reinicie o Nemo:

```bash
nemo -q && nemo &
```

### Como usar no Nemo

1. Clique com o botão direito numa pasta, num arquivo ou no fundo da pasta aberta.
2. Escolha **Git Tools**.
3. Confira, no topo da lista, a pasta onde a operação será feita.
4. Escolha a operação desejada.

## Como funciona

1. Verifica se `zenity` e `git` estão instalados. Se faltar algum, tenta instalá-lo com `apt`.
2. Verifica se o arquivo `/usr/local/bin/git-tools.conf` existe. Sem ele, o script encerra com erro.
3. Remove instalações anteriores: actions `git-*.nemo_action`, o script mestre antigo `~/.local/share/nemo/scripts/Git Tools.sh` e pastas com nomes alternativos do Git Tools em `~/.local/share/nemo/scripts`.
4. Cria o script mestre `~/.local/share/nemo/actions/git-tools-nemo.sh`.
5. Cria a Nemo Action `~/.local/share/nemo/actions/git-tools.nemo_action`.
6. Exibe instruções finais de uso e reinício do Nemo.

### A Nemo Action

A action coloca o item **Git Tools** no menu de contexto e chama o script mestre, passando a pasta atual do Nemo e os itens selecionados. Ela aparece com qualquer seleção, inclusive sem seleção (clique no fundo da pasta), e só é exibida se `zenity` e `git` estiverem instalados.

### Funcionamento do script mestre

O script mestre chamado pela action:

- Determina o diretório de trabalho a partir do primeiro item selecionado. Se for um arquivo, usa a pasta onde ele está. Se não houver seleção, usa a pasta aberta no Nemo.
- Lê as operações disponíveis do arquivo `git-tools.conf` (formato `script|título|...|parâmetros`).
- Exibe a lista de operações via `zenity`, com a pasta de trabalho no topo.
- Antes de executar operações que não sejam `git-ini.sh`, verifica se a pasta é um repositório Git. Se não for, oferece a opção de inicializá-la.
- Executa o script escolhido com os parâmetros definidos na configuração.

O script mestre fica na pasta de actions do Nemo porque a pasta `~/.local/share/git-tools` é apagada e recriada pelo `git-add-navigator-dolphin.sh`.

## Comportamento e segurança

- **Instalação de dependências:** o script pode executar `sudo apt update` e `sudo apt install` automaticamente se `zenity` ou `git` estiverem ausentes.
- **Remoção de instalações anteriores:** o script apaga actions `git-*.nemo_action`, o arquivo `Git Tools.sh` e pastas com variações do nome "Git Tools" em `~/.local/share/nemo/scripts`. A remoção é restrita a esses alvos.
- **Scripts e actions de terceiros preservados:** outros scripts e actions do Nemo não são afetados.
- **Menu Scripts do Nemo:** o instalador não altera mais essa preferência, porque o item **Git Tools** não depende dela.
- **Execução dos scripts Git:** os scripts são executados com `bash`, herdando o diretório de trabalho resolvido.

## Arquivos envolvidos

- `~/.local/share/nemo/actions/git-tools.nemo_action` — item **Git Tools** no menu de contexto.
- `~/.local/share/nemo/actions/git-tools-nemo.sh` — script mestre chamado pela action.
- `/usr/local/bin/git-tools.conf` — arquivo de configuração lido pelo script mestre. Deve existir antes da execução.
- `/usr/local/bin/git-ini.sh` — usado pelo script mestre para inicializar repositórios quando necessário.
- `/usr/local/bin/<outros scripts>` — scripts referenciados pelo `git-tools.conf`.
- `~/.local/share/nemo/scripts/Git Tools.sh` — script mestre das versões anteriores, removido durante a limpeza.

## Solução de problemas

- **`❌ Arquivo de configuração não encontrado`** — execute `git-install.sh` antes deste script para gerar `/usr/local/bin/git-tools.conf`.
- **`⚠ Dependências ausentes`** — o script tenta instalar automaticamente. Se falhar, instale `zenity` e `git` manualmente.
- **Item Git Tools não aparece** — reinicie o Nemo com `nemo -q && nemo &`. Confira também se `zenity` e `git` estão instalados, porque a action fica oculta sem eles.
- **Item aparece mas não abre a lista** — feche o Nemo com `nemo -q`, abra-o pelo terminal com `nemo` e clique no item; o erro aparece no terminal. Se for `git-tools-nemo.sh: Arquivo ou diretório inexistente`, rode este instalador de novo.
- **Item Git Tools ainda aparece dentro de Scripts** — rode este instalador de novo; ele remove o `Git Tools.sh` antigo.
- **`Script não encontrado`** — verifique se o script referenciado no `git-tools.conf` está presente em `/usr/local/bin/`.
- **`Não foi possível determinar o diretório de trabalho`** — use o item a partir de uma pasta válida.
- **`Falha ao inicializar o repositório`** — verifique as permissões da pasta e se o `git-ini.sh` está instalado corretamente.
- **Remover a integração** — execute `git-remove-navigator-nemo.sh`. O `git-uninstall.sh` ainda não remove a Nemo Action.