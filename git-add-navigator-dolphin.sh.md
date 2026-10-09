# `git-add-navigator-dolphin.sh` — Integração git-tools no Dolphin (KDE)

**Versão:** 2.3.0

## Visão geral

O `git-add-navigator-dolphin.sh` instala a integração das ferramentas `git-tools` no gerenciador de arquivos Dolphin (KDE). Ele cria wrappers individuais para cada operação definida em `git-tools.conf` e um arquivo `.desktop` que adiciona o submenu **Git Tools** ao menu de contexto do Dolphin.

Após a instalação, o usuário pode clicar com o botão direito em uma pasta, acessar **Git Tools** e escolher a operação desejada. Cada operação é executada em uma janela do Konsole.

## Pré-requisitos

- Dolphin instalado (KDE).
- `zenity`, `git` e `konsole` — se ausentes, o script tenta instalá-los via `apt`.
- `git-lib.sh` disponível em `/usr/local/bin/`, com a função `parse_config`.
- O arquivo de configuração `/usr/local/bin/git-tools.conf`, gerado previamente pelo `git-install.sh`.
- Permissão de `sudo` para instalar dependências ausentes.

## Como utilizar

```bash
./git-add-navigator-dolphin.sh
```

O script não aceita parâmetros. Deve ser executado uma vez para instalar a integração.

Após a execução, reinicie o Dolphin:

```bash
dolphin --quit && dolphin &
```

### Como usar no Dolphin

1. Clique com o botão direito em uma pasta.
2. Vá em **Git Tools**.
3. Escolha a operação desejada.

## Como funciona

1. Carrega as funções auxiliares de `git-lib.sh`.
2. Verifica se `zenity`, `git` e `konsole` estão instalados. Se faltar algum, tenta instalá-lo com `apt`.
3. Lê as entradas do `git-tools.conf` e conta quantas serão processadas.
4. Remove instalações anteriores (wrappers e arquivo `.desktop`).
5. Cria um wrapper para cada entrada:
   - Para `git-ini.sh`, gera um wrapper simples.
   - Para os demais scripts, inclui uma verificação de repositório Git antes da execução.
6. Gera o arquivo `.desktop` com o submenu **Git Tools** e as ações correspondentes.
7. Atualiza o cache de serviços do KDE com `kbuildsycoca5`, se disponível.
8. Exibe instruções para reiniciar o Dolphin.

### Funcionamento dos wrappers

Cada wrapper gerado:

- Define as variáveis `DISPLAY` e `WAYLAND_DISPLAY`.
- Recebe a pasta selecionada como primeiro argumento (`%d` no `.desktop`).
- Muda para a pasta selecionada.
- Para scripts que não sejam `git-ini.sh`, verifica se a pasta é um repositório Git. Se não for, oferece a opção de inicializá-la em uma janela do Konsole.
- Executa o script em uma janela do Konsole com `--noclose`, mantendo-a aberta após o término.

## Comportamento e segurança

- **Instalação de dependências:** o script pode executar `sudo apt update` e `sudo apt install` automaticamente se `zenity`, `git` ou `konsole` estiverem ausentes.
- **Reinstalação limpa:** a cada execução, o diretório `~/.local/share/git-tools` e o arquivo `git-tools.desktop` são removidos e recriados. Não há acúmulo de versões antigas.
- **Confirmação antes de inicializar repositório:** se a pasta selecionada não for um repositório Git, o wrapper pergunta ao usuário antes de executar `git-ini.sh`.
- **Execução em Konsole:** todas as operações são executadas em uma janela do Konsole, que permanece aberta após o término do script.
- **Atualização do cache KDE:** se `kbuildsycoca5` estiver disponível, o cache é atualizado automaticamente.

## Arquivos envolvidos

- `~/.local/share/git-tools/*-wrapper.sh` — wrappers criados para cada operação.
- `~/.local/share/kio/servicemenus/git-tools.desktop` — arquivo que adiciona o submenu **Git Tools** ao Dolphin.
- `/usr/local/bin/git-tools.conf` — fonte das entradas para os wrappers e o `.desktop`.
- `/usr/local/bin/git-lib.sh` — biblioteca com a função `parse_config`.
- `/usr/local/bin/git-ini.sh` — usado pelos wrappers para inicializar repositórios.

## Solução de problemas

- **`⚠ Dependências ausentes`** — o script tenta instalar automaticamente. Se falhar, instale `zenity`, `git` e `konsole` manualmente.
- **Submenu Git Tools não aparece** — reinicie o Dolphin com `dolphin --quit && dolphin &`. Se necessário, faça logout e login.
- **`⚠ kbuildsycoca5 não encontrado`** — atualize o cache de serviços do KDE manualmente ou reinicie a sessão.
- **`Nenhum diretório selecionado`** — o wrapper não recebeu a pasta como argumento. Verifique se o arquivo `.desktop` está instalado corretamente.
- **`Falha ao inicializar repositório`** — verifique as permissões da pasta e se o `git-ini.sh` está instalado corretamente.
- **Wrappers não executam** — confirme se os arquivos em `~/.local/share/git-tools/` têm permissão de execução.