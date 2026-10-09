# `git-add-navigator-nemo.sh` — Integração git-tools no Nemo

**Versão:** 3.2.0

## Visão geral

O `git-add-navigator-nemo.sh` instala a integração das ferramentas `git-tools` no gerenciador de arquivos Nemo. Ele cria um script mestre que adiciona o submenu **Git Tools** ao menu de contexto do Nemo, reunindo todas as operações Git disponíveis em um só lugar.

Após a instalação, o usuário pode clicar com o botão direito em qualquer pasta, acessar **Scripts → Git Tools** e escolher a operação desejada.

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

1. Clique com o botão direito em qualquer pasta.
2. Vá em **Scripts → Git Tools**.
3. Escolha a operação desejada no submenu.

## Como funciona

1. Verifica se `zenity` e `git` estão instalados. Se faltar algum, tenta instalá-lo com `apt`.
2. Verifica se o arquivo `/usr/local/bin/git-tools.conf` existe. Sem ele, o script encerra com erro.
3. Remove instalações anteriores (actions antigas e pastas com nomes alternativos do Git Tools).
4. Cria o script mestre `~/.local/share/nemo/scripts/Git Tools.sh`.
5. Tenta habilitar o menu de scripts do Nemo via `gsettings`.
6. Exibe instruções finais de uso e reinício do Nemo.

### Funcionamento do script mestre

O script mestre instalado no Nemo:

- Determina o diretório de trabalho a partir da pasta ou arquivo selecionado. Se não houver seleção, usa a URI atual do Nemo.
- Lê as operações disponíveis do arquivo `git-tools.conf` (formato `script|título|...|parâmetros`).
- Exibe um submenu com as operações via `zenity`.
- Antes de executar operações que não sejam `git-ini.sh`, verifica se a pasta é um repositório Git. Se não for, oferece a opção de inicializá-la.
- Executa o script escolhido com os parâmetros definidos na configuração.

## Comportamento e segurança

- **Instalação de dependências:** o script pode executar `sudo apt update` e `sudo apt install` automaticamente se `zenity` ou `git` estiverem ausentes.
- **Remoção de instalações anteriores:** o script apaga actions antigas (`git-*.nemo_action`) e pastas com variações do nome "Git Tools" em `~/.local/share/nemo/scripts`. A remoção é restrita a esses alvos.
- **Scripts de terceiros preservados:** apenas o arquivo `Git Tools.sh` é removido; outros scripts do Nemo não são afetados.
- **Alteração de configuração do Nemo:** o script tenta alterar a preferência `show-scripts-in-context-menus` (ou chave equivalente) via `gsettings`. Se a chave não existir, a alteração é ignorada.
- **Execução dos scripts Git:** os scripts são executados com `bash`, herdando o diretório de trabalho resolvido.

## Arquivos envolvidos

- `~/.local/share/nemo/scripts/Git Tools.sh` — script mestre criado pelo instalador.
- `/usr/local/bin/git-tools.conf` — arquivo de configuração lido pelo script mestre. Deve existir antes da execução.
- `/usr/local/bin/git-ini.sh` — usado pelo script mestre para inicializar repositórios quando necessário.
- `/usr/local/bin/<outros scripts>` — scripts referenciados pelo `git-tools.conf`.
- `~/.local/share/nemo/actions/git-*.nemo_action` — actions antigas removidas durante a limpeza.

## Solução de problemas

- **`❌ Arquivo de configuração não encontrado`** — execute `git-install.sh` antes deste script para gerar `/usr/local/bin/git-tools.conf`.
- **`⚠ Dependências ausentes`** — o script tenta instalar automaticamente. Se falhar, instale `zenity` e `git` manualmente.
- **Menu Scripts não aparece no Nemo** — ative manualmente em **Nemo → Editar → Preferências → Comportamento → Mostrar scripts no menu de contexto**.
- **Submenu Git Tools não aparece** — reinicie o Nemo com `nemo -q && nemo &`.
- **`Script não encontrado`** — verifique se o script referenciado no `git-tools.conf` está presente em `/usr/local/bin/`.
- **`Não foi possível determinar o diretório de trabalho`** — execute o submenu a partir de uma pasta válida, não da área de trabalho ou de um local sem URI reconhecida.
- **`Falha ao inicializar o repositório`** — verifique as permissões da pasta e se o `git-ini.sh` está instalado corretamente.
- **Remover a integração** — o `git-uninstall.sh` e o `git-remove-navigator-nemo.sh` só apagam pastas. Para remover o item **Git Tools**, apague o arquivo: `rm "$HOME/.local/share/nemo/scripts/Git Tools.sh"`.