# `git-add-navigator-nautilus.sh` — Integração git-tools no Nautilus

**Versão:** 1.1.0

## Visão geral

O `git-add-navigator-nautilus.sh` instala a integração das ferramentas `git-tools` no gerenciador de arquivos Nautilus. Ele gera scripts (wrappers) no diretório de scripts do Nautilus, a partir das entradas definidas em `/usr/local/bin/git-tools.conf`.

Após a instalação, o usuário pode clicar com o botão direito em qualquer pasta, acessar **Scripts → Git Tools** e escolher a operação desejada.

## Pré-requisitos

- Nautilus instalado (gerenciador de arquivos do GNOME).
- `zenity` e `git` instalados.
- `git-lib.sh` disponível em `/usr/local/bin/`, com a função `parse_config`.
- O arquivo de configuração `/usr/local/bin/git-tools.conf`, gerado previamente pelo `git-install.sh`.

## Como utilizar

```bash
./git-add-navigator-nautilus.sh
```

O script não aceita parâmetros. Deve ser executado uma vez para instalar a integração.

Após a execução, reinicie o Nautilus:

```bash
nautilus -q && nautilus &
```

### Como usar no Nautilus

1. Clique com o botão direito em qualquer pasta ou arquivo.
2. Vá em **Scripts → Git Tools**.
3. Escolha a operação desejada.

## Como funciona

1. Carrega as funções auxiliares de `/usr/local/bin/git-lib.sh`. Se o arquivo não existir, encerra com erro.
2. Remove instalações anteriores do Git Tools no diretório de scripts do Nautilus (variações de nome).
3. Lê as entradas do `git-tools.conf` por meio da função `parse_config`, filtrando as que possuem título de menu definido.
4. Para cada entrada, cria um wrapper em `~/.local/share/nautilus/scripts/Git Tools/`.
5. Torna cada wrapper executável.
6. Exibe instruções para reiniciar o Nautilus.

### Funcionamento dos wrappers

Cada wrapper gerado:

- Define variáveis de ambiente de display (`DISPLAY`, `DBUS_SESSION_BUS_ADDRESS`, `XDG_RUNTIME_DIR`), pois o Nautilus não as propaga.
- Obtém a pasta selecionada a partir de `NAUTILUS_SCRIPT_SELECTED_FILE_PATHS` e muda para ela.
- Verifica se a pasta é um repositório Git. Se não for, oferece a opção de inicializá-la com `git-ini.sh`, exceto para o próprio `git-ini.sh`.
- Executa o script correspondente em `/usr/local/bin/`, com os parâmetros definidos no `git-tools.conf`.

## Comportamento e segurança

- **Instalação idempotente:** execuções repetidas removem e recriam os wrappers, sem acumular duplicatas.
- **Remoção restrita:** apenas diretórios com variações do nome "Git Tools" são removidos do diretório de scripts do Nautilus.
- **Sem instalação automática de dependências:** diferentemente da versão para Nemo, este script apenas avisa sobre dependências ausentes. A instalação deve ser feita manualmente.
- **Confirmação antes de inicializar repositório:** se a pasta selecionada não for um repositório Git, o wrapper pergunta ao usuário antes de executar `git-ini.sh`.
- **Erro de display:** se as variáveis de display não estiverem corretas, as caixas de diálogo do `zenity` podem não aparecer.

## Arquivos envolvidos

- `~/.local/share/nautilus/scripts/Git Tools/*.sh` — wrappers gerados.
- `/usr/local/bin/git-tools.conf` — fonte das entradas para os wrappers.
- `/usr/local/bin/git-lib.sh` — biblioteca com a função `parse_config`.
- `/usr/local/bin/git-ini.sh` — usado pelos wrappers para inicializar repositórios.

## Solução de problemas

- **`❌ git-lib.sh não encontrado`** — execute `git-install.sh` antes deste script.
- **`⚠ Dependências ausentes`** — instale com `sudo apt install zenity git`.
- **Menu Scripts não aparece no Nautilus** — verifique se o Nautilus está configurado para exibir scripts no menu de contexto. Em algumas versões, isso pode exigir ajuste via `gsettings` ou extensão.
- **Submenu Git Tools não aparece** — reinicie o Nautilus com `nautilus -q && nautilus &`. Se necessário, faça logout e login.
- **`Falha ao inicializar repositório`** — verifique as permissões da pasta e se o `git-ini.sh` está instalado corretamente.
- **Caixas de diálogo do `zenity` não aparecem** — as variáveis de display podem não estar acessíveis. Verifique se `DISPLAY` e `DBUS_SESSION_BUS_ADDRESS` estão definidos no ambiente gráfico.